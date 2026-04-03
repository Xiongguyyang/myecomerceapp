import 'package:flutter/material.dart';

/// Single source of truth for every colour in the app.
///
/// Brand / status colours are static constants (unchanged between themes).
/// Surface / text / background colours depend on the active theme — access
/// them via [AppColors.of(context)] which returns the correct palette.
class AppColors {
  const AppColors._({
    required this.background,
    required this.surface,
    required this.surfaceLight,
    required this.card,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
  });

  // ── Theme-dependent instance fields ──────────────────────────────────────
  final Color background;
  final Color surface;
  final Color surfaceLight;
  final Color card;
  Color get cardBackground => card;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;

  // ── Brand (static — same in every theme) ─────────────────────────────────
  static const Color primary      = Color(0xFF004054);
  static const Color primaryDark  = Color(0xFF002A36);
  static const Color primaryLight = Color(0xFF00607D);
  static const Color accent       = Color(0xFF12AEC6);
  static const Color accentDark   = Color(0xFF00697A);
  static const Color accentLight  = accentDark;

  // ── Status (static — same in every theme) ────────────────────────────────
  static const Color success  = Color(0xFF4CAF50);
  static const Color error    = Color(0xFFEF5350);
  static const Color warning  = Color(0xFFFF9800);
  static const Color star     = Color(0xFFFFD700);
  static const Color badge    = Color(0xFFFF6D00);
  static const Color overlay  = Color(0x80000000);

  // ── Dark palette ─────────────────────────────────────────────────────────
  static const AppColors _dark = AppColors._(
    background:    Color(0xFF003344),
    surface:       Color(0xFF1C2C3B),
    surfaceLight:  Color(0xFF2A3E50),
    card:          Color(0xFF1A3A4A),
    inputFill:     Color(0x1AFFFFFF),
    textPrimary:   Color(0xFFFFFFFF),
    textSecondary: Color(0xFFB0BEC5),
    textHint:      Color(0xFF78909C),
    divider:       Color(0xFF37474F),
  );

  // ── Light palette ─────────────────────────────────────────────────────────
  static const AppColors _light = AppColors._(
    background:    Color(0xFFEFF3F8),
    surface:       Color(0xFFFFFFFF),
    surfaceLight:  Color(0xFFF5F8FC),
    card:          Color(0xFFFFFFFF),
    inputFill:     Color(0x0F000000),
    textPrimary:   Color(0xFF1A2733),
    textSecondary: Color(0xFF4A6070),
    textHint:      Color(0xFF8AA0B0),
    divider:       Color(0xFFD0DCE8),
  );

  /// Returns the colour palette that matches the active [ThemeMode].
  static AppColors of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}
