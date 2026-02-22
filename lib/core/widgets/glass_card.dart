import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

/// Hope UI-inspired glass card.
/// Frosted glass effect with warm tint, crisp border, and teal-tinted shadow.
class GlassCard extends StatelessWidget {
  const GlassCard({
    required this.child,
    this.padding,
    this.borderRadius,
    this.blur = 20.0,
    this.tintOpacity = 0.72,
    this.borderOpacity = 0.6,
    this.shadows = AppShadows.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final double blur;
  final double tintOpacity;
  final double borderOpacity;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusXl;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface.withOpacity(tintOpacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: AppColors.glassBorder.withOpacity(borderOpacity),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
