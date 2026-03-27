import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

enum _BatteryCheckStatus { idle, checking, on, off }

class LearnStatePage extends StatefulWidget {
  const LearnStatePage({super.key});

  @override
  State<LearnStatePage> createState() => _LearnStatePageState();
}

class _LearnStatePageState extends State<LearnStatePage> with WidgetsBindingObserver {
  static const _methodChannel = MethodChannel('com.example.myecomerceapp/battery_saver');
  static const _eventChannel  = EventChannel('com.example.myecomerceapp/battery_saver_events');

  _BatteryCheckStatus _batteryStatus = _BatteryCheckStatus.idle;
  String _detectedVia = '';
  StreamSubscription<dynamic>? _eventSub;

  PermissionStatus _batteryPermStatus = PermissionStatus.denied;
  PermissionStatus _locationPermStatus = PermissionStatus.denied;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
    // Start real-time listener on Android
    if (Platform.isAndroid) _startRealTimeListener();
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshPermissions();
  }

  // ── Real-time ContentObserver stream ───────────────────────────────────────

  void _startRealTimeListener() {
    _eventSub = _eventChannel.receiveBroadcastStream().listen((event) {
      if (!mounted || event is! Map) return;
      final isActive = event['isActive'] as bool? ?? false;
      final via      = event['detectedVia'] as String? ?? '';
      // Only update if the status actually changed
      final newStatus = isActive ? _BatteryCheckStatus.on : _BatteryCheckStatus.off;
      if (_batteryStatus == newStatus) return;
      setState(() {
        _batteryStatus = newStatus;
        _detectedVia   = via;
      });
      if (isActive) _showBatterySaverModal();
    });
  }

  // ── Permissions ────────────────────────────────────────────────────────────

  Future<void> _refreshPermissions() async {
    final battery = Platform.isAndroid
        ? await Permission.ignoreBatteryOptimizations.status
        : PermissionStatus.granted;
    final location = await Permission.locationWhenInUse.status;
    if (!mounted) return;
    setState(() {
      _batteryPermStatus  = battery;
      _locationPermStatus = location;
    });
  }

  Future<void> _requestBatteryPermission() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.ignoreBatteryOptimizations.request();
    if (!mounted) return;
    setState(() => _batteryPermStatus = status);
    if (status.isPermanentlyDenied) openAppSettings();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (!mounted) return;
    setState(() => _locationPermStatus = status);
    if (status.isPermanentlyDenied) openAppSettings();
  }

  // ── One-shot check ─────────────────────────────────────────────────────────

  Future<void> _checkBatterySaverMode() async {
    setState(() {
      _batteryStatus = _BatteryCheckStatus.checking;
      _detectedVia   = '';
    });
    try {
      final raw = await _methodChannel.invokeMethod('isBatterySaverEnabled');
      if (!mounted) return;
      _applyResult(raw);
      if (_batteryStatus == _BatteryCheckStatus.on) _showBatterySaverModal();
    } catch (_) {
      if (!mounted) return;
      setState(() => _batteryStatus = _BatteryCheckStatus.idle);
    }
  }

  void _applyResult(dynamic raw) {
    bool isActive;
    String via;
    if (raw is Map) {
      isActive = raw['isActive'] as bool? ?? false;
      via      = raw['detectedVia'] as String? ?? '';
    } else {
      isActive = raw as bool? ?? false;
      via      = isActive ? 'ProcessInfo.isLowPowerModeEnabled' : '';
    }
    setState(() {
      _batteryStatus = isActive ? _BatteryCheckStatus.on : _BatteryCheckStatus.off;
      _detectedVia   = via;
    });
  }

  // ── Dump tool ──────────────────────────────────────────────────────────────

  Future<void> _showDumpSheet() async {
    List<Map> rows = [];
    try {
      final raw = await _methodChannel.invokeMethod<List>('dumpBatteryKeys');
      rows = raw?.cast<Map>() ?? [];
    } catch (_) {}

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, controller) => Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.bug_report, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text('Battery Key Dump',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  Spacer(),
                  Text('Enable battery saver THEN dump',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Divider(),
            if (rows.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text('No battery-related keys found.',
                    style: TextStyle(color: Colors.grey)),
              )
            else
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: rows.length,
                  separatorBuilder: (_, i) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final row = rows[i];
                    final key   = row['key'] as String? ?? '';
                    final value = row['value'] as String? ?? '';
                    final table = row['table'] as String? ?? '';
                    final isOne = value == '1';
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: isOne
                            ? Colors.orange.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                        child: Text(
                          table.substring(0, 2),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: isOne ? Colors.orange : Colors.grey,
                          ),
                        ),
                      ),
                      title: Text(key,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isOne ? Colors.orange : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(value,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isOne ? Colors.white : Colors.black54,
                            )),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Modal ──────────────────────────────────────────────────────────────────

  void _showBatterySaverModal() {
    final isIOS = Platform.isIOS;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.battery_saver, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text('Battery Saver Active'),
          ],
        ),
        content: Text(
          'Battery Saver mode is currently enabled on your device. '
          'This may limit background activity and affect app performance.\n\n'
          '${isIOS ? 'Tap "Go to Settings" then navigate to Battery > Low Power Mode to disable it.' : 'Tap "Go to Settings" to disable Battery Saver.'}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (isIOS) {
                await AppSettings.openAppSettings(type: AppSettingsType.device);
              } else {
                await AppSettings.openAppSettings(type: AppSettingsType.batteryOptimization);
              }
            },
            icon: const Icon(Icons.settings, color: Colors.white),
            label: const Text('Go to Settings', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  bool get _canCheck =>
      (Platform.isIOS || _batteryPermStatus.isGranted) &&
      _locationPermStatus.isGranted;

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text('Battery Saver Detector',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  // Dump button — Android only
                  if (Platform.isAndroid)
                    IconButton(
                      tooltip: 'Dump battery keys (debug)',
                      icon: const Icon(Icons.bug_report, color: Colors.deepPurple),
                      onPressed: _showDumpSheet,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Expanded(
                    child: Text('Grant permissions, then tap Check.',
                        style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ),
                  // Real-time listener badge
                  if (Platform.isAndroid && _eventSub != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sensors, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text('Live', style: TextStyle(fontSize: 11, color: Colors.green)),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Permissions ────────────────────────────────────────────
              const Text('Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              if (Platform.isAndroid) ...[
                _PermissionCard(
                  icon: Icons.battery_charging_full,
                  title: 'Battery Optimization',
                  subtitle: 'Deep battery saver detection across all Android OEMs.',
                  status: _batteryPermStatus,
                  onRequest: _requestBatteryPermission,
                ),
                const SizedBox(height: 12),
              ],

              _PermissionCard(
                icon: Icons.location_on,
                title: 'Location',
                subtitle: 'Required for location-based features.',
                status: _locationPermStatus,
                onRequest: _requestLocationPermission,
              ),

              const SizedBox(height: 32),

              // ── Battery Status ─────────────────────────────────────────
              const Text('Battery Saver Status',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),

              _StatusCard(status: _batteryStatus),

              if (_detectedVia.isNotEmpty && _detectedVia != 'none') ...[
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white70, size: 13),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'via: $_detectedVia',
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canCheck ? Colors.orange : Colors.grey,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _batteryStatus == _BatteryCheckStatus.checking
                    ? null
                    : (_canCheck ? _checkBatterySaverMode : null),
                icon: _batteryStatus == _BatteryCheckStatus.checking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.search, color: Colors.white),
                label: Text(
                  _batteryStatus == _BatteryCheckStatus.checking
                      ? 'Checking...'
                      : _canCheck
                          ? 'Check Battery Saver'
                          : 'Grant Permissions First',
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),

              if (_batteryStatus != _BatteryCheckStatus.idle) ...[
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => setState(() {
                      _batteryStatus = _BatteryCheckStatus.idle;
                      _detectedVia   = '';
                    }),
                    child: const Text('Reset', style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Permission Card ────────────────────────────────────────────────────────────

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.onRequest,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final PermissionStatus status;
  final VoidCallback onRequest;

  Color get _color {
    if (status.isGranted) return Colors.green;
    if (status.isPermanentlyDenied) return Colors.red;
    return Colors.orange;
  }

  String get _label {
    if (status.isGranted) return 'Granted';
    if (status.isPermanentlyDenied) return 'Permanently Denied';
    if (status.isRestricted) return 'Restricted';
    return 'Not Granted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.black54)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      status.isGranted ? Icons.check_circle : Icons.error_outline,
                      size: 14, color: _color,
                    ),
                    const SizedBox(width: 4),
                    Text(_label,
                        style: TextStyle(
                            fontSize: 12, color: _color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          if (!status.isGranted) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _color,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: onRequest,
              child: Text(
                status.isPermanentlyDenied ? 'Settings' : 'Allow',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Battery Status Card ────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.status});

  final _BatteryCheckStatus status;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: switch (status) {
        _BatteryCheckStatus.idle     => _buildIdle(),
        _BatteryCheckStatus.checking => _buildChecking(),
        _BatteryCheckStatus.on => _buildResult(
            icon: Icons.battery_saver,
            iconColor: Colors.orange,
            bgColor: const Color(0xFFFFF3E0),
            borderColor: Colors.orange,
            label: 'Battery Saver is ON',
            sublabel: 'Your device is in power-saving mode.',
            badgeText: 'ACTIVE',
            badgeColor: Colors.orange,
          ),
        _BatteryCheckStatus.off => _buildResult(
            icon: Icons.battery_full,
            iconColor: Colors.green,
            bgColor: const Color(0xFFE8F5E9),
            borderColor: Colors.green,
            label: 'Battery Saver is OFF',
            sublabel: 'Your device is running normally.',
            badgeText: 'INACTIVE',
            badgeColor: Colors.green,
          ),
      },
    );
  }

  Widget _buildIdle() => Container(
        key: const ValueKey('idle'),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          children: [
            Icon(Icons.battery_unknown, size: 56, color: Colors.grey),
            SizedBox(height: 10),
            Text('Status Unknown',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
            SizedBox(height: 4),
            Text('Grant permissions and tap Check.',
                style: TextStyle(fontSize: 13, color: Colors.grey)),
          ],
        ),
      );

  Widget _buildChecking() => Container(
        key: const ValueKey('checking'),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(color: Colors.orange),
            SizedBox(height: 14),
            Text('Detecting...',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          ],
        ),
      );

  Widget _buildResult({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color borderColor,
    required String label,
    required String sublabel,
    required String badgeText,
    required Color badgeColor,
  }) =>
      Container(
        key: ValueKey(label),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 56, color: iconColor),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badgeText,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1)),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.bold, color: iconColor)),
            const SizedBox(height: 4),
            Text(sublabel,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ],
        ),
      );
}
