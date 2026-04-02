import 'package:flutter/material.dart';

/// Single source of truth for every color in the app.
/// Use AppColors.xxx everywhere — never write a raw Color() in UI files.
class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF004054);
  static const Color primaryDark  = Color(0xFF002A36);
  static const Color primaryLight = Color(0xFF00607D);
  static const Color accent       = Color(0xFF12AEC6);
  static const Color accentDark   = Color(0xFF00697A);
  static const Color accentLight  = accentDark; // alias

  // ── Background / Surface ───────────────────────────────────────────────────
  static const Color background   = Color(0xFF003344);
  static const Color surface      = Color(0xFF1C2C3B);
  static const Color surfaceLight = Color(0xFF2A3E50);
  static const Color card         = Color(0xFF1A3A4A);
  static const Color cardBackground = card; // alias
  static const Color inputFill    = Color(0x1AFFFFFF); // white 10 %

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint      = Color(0xFF78909C);

  // ── Status ─────────────────────────────────────────────────────────────────
  static const Color success  = Color(0xFF4CAF50);
  static const Color error    = Color(0xFFEF5350);
  static const Color warning  = Color(0xFFFF9800);
  static const Color star     = Color(0xFFFFD700);
  static const Color badge    = Color(0xFFFF6D00); // cart badge

  // ── Misc ───────────────────────────────────────────────────────────────────
  static const Color divider  = Color(0xFF37474F);
  static const Color overlay  = Color(0x80000000); // black 50 %
}
