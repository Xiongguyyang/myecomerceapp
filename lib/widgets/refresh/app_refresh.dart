import 'package:flutter/material.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';

/// Reusable pull-to-refresh wrapper.
///
/// Usage with a regular [ScrollView]:
/// ```dart
/// AppRefresh(
///   onRefresh: () async { /* reload data */ },
///   child: ListView(...),
/// )
/// ```
///
/// Usage with a [CustomScrollView] / slivers:
/// ```dart
/// CustomScrollView(
///   slivers: [
///     AppRefresh.sliver(onRefresh: _reload),
///     ...
///   ],
/// )
/// ```
class AppRefresh extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Widget child;

  /// Stroke color of the spinner (defaults to [AppColors.accent]).
  final Color? color;

  /// Background of the refresh indicator pill.
  final Color? backgroundColor;

  const AppRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.color,
    this.backgroundColor,
  });

  /// Returns a [SliverToBoxAdapter] that injects the refresh trigger at the
  /// top of a [CustomScrollView] via [RefreshIndicator.noSpinner] trick.
  /// Place this as the **first** sliver.
  static Widget sliver({
    required Future<void> Function() onRefresh,
    Color color = AppColors.accent,
    Color backgroundColor = AppColors.surface,
  }) {
    return _SliverRefreshControl(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color ?? AppColors.accent,
      backgroundColor: backgroundColor ?? AppColors.surface,
      strokeWidth: 2.5,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      child: child,
    );
  }
}

/// Sliver-compatible refresh control for [CustomScrollView].
class _SliverRefreshControl extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Color color;
  final Color backgroundColor;

  const _SliverRefreshControl({
    required this.onRefresh,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: _RefreshTrigger(
        onRefresh: onRefresh,
        color: color,
        backgroundColor: backgroundColor,
      ),
    );
  }
}

/// Zero-height widget that owns a [RefreshIndicator] and exposes it to the
/// parent [CustomScrollView] through a shared [ScrollController].
class _RefreshTrigger extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final Color color;
  final Color backgroundColor;

  const _RefreshTrigger({
    required this.onRefresh,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Attaches to the nearest ancestor ScrollController so the
    // RefreshIndicator listens to the CustomScrollView's scroll position.
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: color,
      backgroundColor: backgroundColor,
      strokeWidth: 2.5,
      notificationPredicate: (n) => n.depth == 1,
      child: const SizedBox.shrink(),
    );
  }
}
