import 'package:flutter/material.dart';

/// Helper for Android-friendly animations
/// Uses linear curves and optimized durations for better Android rendering
class AndroidFriendlyAnimation {
  /// Create a fade animation optimized for Android
  static Animation<double> createFadeAnimation(
    AnimationController controller, {
    Duration delay = Duration.zero,
  }) {
    return Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
  }

  /// Create a slide animation optimized for Android
  static Animation<Offset> createSlideAnimation(
    AnimationController controller, {
    Offset begin = const Offset(0, 0.5),
    Duration delay = Duration.zero,
  }) {
    return Tween<Offset>(begin: begin, end: Offset.zero).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
  }

  /// Create a scale animation optimized for Android
  static Animation<double> createScaleAnimation(
    AnimationController controller, {
    double begin = 0.8,
    Duration delay = Duration.zero,
  }) {
    return Tween<double>(begin: begin, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.0, 1.0, curve: Curves.linear),
      ),
    );
  }
}

/// Widget that respects system text scale settings but limits them
class TextScaleLimiter extends StatelessWidget {
  final Widget child;
  final double maxScaleFactor;

  const TextScaleLimiter({
    required this.child,
    this.maxScaleFactor = 1.2, // Max 120% of default text size
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.of(context).textScaleFactor;

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: textScale > maxScaleFactor
            ? maxScaleFactor
            : textScale,
      ),
      child: child,
    );
  }
}

/// Optimized shadow for Android rendering
class AndroidOptimizedShadow extends StatelessWidget {
  final Widget child;
  final Color shadowColor;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;

  const AndroidOptimizedShadow({
    required this.child,
    required this.shadowColor,
    this.blurRadius = 4.0,
    this.spreadRadius = 0.0,
    this.offset = const Offset(0, 2),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // On Android, use subtler shadows to avoid rendering issues
    final isAndroid = Theme.of(context).platform == TargetPlatform.android;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(isAndroid ? 0.08 : 0.1),
            blurRadius: isAndroid ? blurRadius * 0.8 : blurRadius,
            spreadRadius: isAndroid ? 0 : spreadRadius,
            offset: isAndroid ? Offset(offset.dx, offset.dy * 0.8) : offset,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Wrapper for widgets that should have optimized rendering on Android
class AndroidOptimized extends StatelessWidget {
  final Widget child;

  const AndroidOptimized({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextScaleLimiter(
      child: child,
    );
  }
}
