import 'package:flutter/material.dart';

/// Responsive helper — call these from build methods.
/// Baseline is iPhone 14 width (390px).
class R {
  R._();

  static double w(BuildContext context) => MediaQuery.sizeOf(context).width;
  static double h(BuildContext context) => MediaQuery.sizeOf(context).height;

  static bool isPhone(BuildContext context) => w(context) < 600;
  static bool isTablet(BuildContext context) =>
      w(context) >= 600 && w(context) < 900;
  static bool isDesktop(BuildContext context) => w(context) >= 900;

  /// Horizontal page padding — grows on wider screens
  static double hp(BuildContext context) {
    if (isDesktop(context)) return 64;
    if (isTablet(context)) return 32;
    return 16;
  }

  /// Product grid column count
  static int gridCols(BuildContext context) {
    if (isDesktop(context)) return 4;
    if (isTablet(context)) return 3;
    return 2;
  }

  /// Scale a font size proportionally to screen width
  static double sp(BuildContext context, double size) =>
      size * (w(context) / 390).clamp(0.85, 1.4);

  /// Scale a dimension proportionally to screen width
  static double wp(BuildContext context, double size) =>
      size * (w(context) / 390).clamp(0.85, 1.4);
}
