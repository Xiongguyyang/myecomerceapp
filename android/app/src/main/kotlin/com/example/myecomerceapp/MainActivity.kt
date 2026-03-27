package com.example.myecomerceapp

import android.content.Context
import android.database.ContentObserver
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.PowerManager
import android.provider.Settings
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val METHOD_CHANNEL = "com.example.myecomerceapp/battery_saver"
    private val EVENT_CHANNEL  = "com.example.myecomerceapp/battery_saver_events"
    private val TAG = "BatterySaverDetector"

    // Keys that look like power-save keys but store thresholds / unrelated values.
    private val ignoredKeys = setOf(
        "low_power_trigger_level",
        "low_power_sticky",
        "battery_saver_schedule_level",
        "battery_saver_trigger_level",
        "battery_saver_end_percentage",
        "battery_percentage",
        "battery_saver_constants",
        "power_manager_constants",
    )

    // ── All known OEM keys ────────────────────────────────────────────────────
    // Format: Pair(settingsTable, key)  — "G" = Global, "Sy" = System
    private val knownGlobalKeys = listOf(
        // AOSP / stock Android
        "low_power",
        // Tecno HiOS 7
        "power_save_mode_enabled",
        // Tecno HiOS 8
        "enable_power_save",
        // Tecno HiOS 9+ (suspected — add new ones here when found via dump)
        "hios_power_save_mode",
        "hios_low_power_mode",
        "tecno_power_save",
        "transsion_low_power",
        "itel_power_save",
        // Xiaomi MIUI
        "POWER_SAVE_MODE_OPEN",
        // Samsung (older OneUI extreme)
        "extreme_power_save_mode_on",
        // Generic OEM variants
        "battery_saver_on",
        "power_save_mode_on",
        "power_saving_mode",
    )

    private val knownSystemKeys = listOf(
        // Huawei EMUI / HarmonyOS
        "super_power_save_mode",
        // Some MTK / Oppo / Vivo builds
        "power_save_mode",
        "low_power_mode",
    )

    // ── ContentObserver for real-time updates ─────────────────────────────────
    private var eventSink: EventChannel.EventSink? = null
    private var globalObserver: ContentObserver? = null
    private var systemObserver: ContentObserver? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Method channel — one-shot check + dump
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isBatterySaverEnabled" -> result.success(checkBatterySaver())
                    "dumpBatteryKeys"       -> result.success(dumpBatteryKeys())
                    else -> result.notImplemented()
                }
            }

        // Event channel — real-time stream via ContentObserver
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    registerObservers()
                }
                override fun onCancel(arguments: Any?) {
                    unregisterObservers()
                    eventSink = null
                }
            })
    }

    // ── ContentObserver registration ──────────────────────────────────────────

    private fun registerObservers() {
        val handler = Handler(Looper.getMainLooper())

        val onChange: () -> Unit = {
            eventSink?.success(checkBatterySaver())
        }

        globalObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) = onChange()
        }
        systemObserver = object : ContentObserver(handler) {
            override fun onChange(selfChange: Boolean) = onChange()
        }

        contentResolver.registerContentObserver(
            Settings.Global.CONTENT_URI, true, globalObserver!!
        )
        contentResolver.registerContentObserver(
            Settings.System.CONTENT_URI, true, systemObserver!!
        )
    }

    private fun unregisterObservers() {
        globalObserver?.let { contentResolver.unregisterContentObserver(it) }
        systemObserver?.let { contentResolver.unregisterContentObserver(it) }
        globalObserver = null
        systemObserver = null
    }

    // ── Core detection ────────────────────────────────────────────────────────

    fun checkBatterySaver(): Map<String, Any> {
        val pm = getSystemService(Context.POWER_SERVICE) as PowerManager

        // 1. Standard Android PowerManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && pm.isPowerSaveMode) {
            return result(true, "PowerManager.isPowerSaveMode()")
        }

        // 2. Targeted known-OEM Global keys
        for (key in knownGlobalKeys) {
            if (readGlobalInt(key) == 1) return result(true, "Settings.Global[$key]")
        }

        // 3. Targeted known-OEM System keys
        for (key in knownSystemKeys) {
            if (readSystemInt(key) == 1) return result(true, "Settings.System[$key]")
        }

        // 4. Full dynamic scan — catches unknown / future OEM keys
        val scanHit = scanTable(Settings.Global.CONTENT_URI, "Global")
            ?: scanTable(Settings.System.CONTENT_URI, "System")

        if (scanHit != null) return result(true, scanHit)

        return result(false, "none")
    }

    /** Scan every row, match power/battery/saver patterns with value "1". */
    private fun scanTable(uri: Uri, tableName: String): String? {
        val cursor = try {
            contentResolver.query(uri, null, null, null, null)
        } catch (e: Exception) { return null } ?: return null

        cursor.use { c ->
            val nameIdx  = c.getColumnIndex("name")
            val valueIdx = c.getColumnIndex("value")
            if (nameIdx == -1 || valueIdx == -1) return null

            while (c.moveToNext()) {
                val name  = c.getString(nameIdx)  ?: continue
                val value = c.getString(valueIdx) ?: continue
                if (name.lowercase() in ignoredKeys || value != "1") continue

                val lower = name.lowercase()
                if (lower.contains("low_power")    ||
                    lower.contains("power_sav")    ||
                    lower.contains("powersav")     ||
                    lower.contains("battery_sav")  ||
                    lower.contains("batterysav")   ||
                    lower.contains("power_save")   ||
                    lower.contains("enable_power") ||
                    lower.contains("batt_sav")) {
                    return "Settings.$tableName[$name] (scan)"
                }
            }
        }
        return null
    }

    // ── Dump tool — call this when a new device can't be detected ─────────────
    // Enable battery saver on the device, call dump, read Logcat for TAG.
    // The key whose value changes from 0→1 is the one to add to knownGlobalKeys.
    fun dumpBatteryKeys(): List<Map<String, String>> {
        val results = mutableListOf<Map<String, String>>()

        fun dumpUri(uri: Uri, tableName: String) {
            val cursor = try {
                contentResolver.query(uri, null, null, null, null)
            } catch (e: Exception) { return }

            cursor?.use { c ->
                val nameIdx  = c.getColumnIndex("name")
                val valueIdx = c.getColumnIndex("value")
                if (nameIdx == -1 || valueIdx == -1) return

                while (c.moveToNext()) {
                    val name  = c.getString(nameIdx)  ?: continue
                    val value = c.getString(valueIdx) ?: continue
                    val lower = name.lowercase()

                    val relevant = lower.contains("power")   ||
                                   lower.contains("battery") ||
                                   lower.contains("saver")   ||
                                   lower.contains("save")    ||
                                   lower.contains("low")

                    if (relevant) {
                        Log.d(TAG, "[$tableName] $name = $value")
                        results.add(mapOf("table" to tableName, "key" to name, "value" to value))
                    }
                }
            }
        }

        dumpUri(Settings.Global.CONTENT_URI, "Global")
        dumpUri(Settings.System.CONTENT_URI, "System")

        return results
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private fun readGlobalInt(key: String) = try {
        Settings.Global.getInt(contentResolver, key, 0)
    } catch (e: Exception) { 0 }

    private fun readSystemInt(key: String) = try {
        Settings.System.getInt(contentResolver, key, 0)
    } catch (e: Exception) { 0 }

    private fun result(active: Boolean, via: String): Map<String, Any> =
        mapOf("isActive" to active, "detectedVia" to via)
}
