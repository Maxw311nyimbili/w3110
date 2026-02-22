import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/theme/app_spacing.dart';

enum AppButtonType { primary, secondary, outline }

/// Hope UI-inspired button with press-scale micro-animation.
class AppButton extends StatefulWidget {
  const AppButton({
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    super.key,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (widget.onPressed != null && !widget.isLoading) {
      _scaleController.forward();
    }
  }

  void _onTapUp(TapUpDetails _) => _scaleController.reverse();
  void _onTapCancel() => _scaleController.reverse();

  Color get _backgroundColor {
    if (widget.backgroundColor != null) return widget.backgroundColor!;
    if (widget.onPressed == null) return AppColors.backgroundElevated;
    switch (widget.type) {
      case AppButtonType.primary:
        return AppColors.accentPrimary;
      case AppButtonType.secondary:
        return AppColors.accentLight;
      case AppButtonType.outline:
        return Colors.transparent;
    }
  }

  Color get _foregroundColor {
    if (widget.foregroundColor != null) return widget.foregroundColor!;
    if (widget.onPressed == null) return AppColors.textTertiary;
    switch (widget.type) {
      case AppButtonType.primary:
        return AppColors.textInverted;
      case AppButtonType.secondary:
        return AppColors.accentPrimary;
      case AppButtonType.outline:
        return AppColors.accentPrimary;
    }
  }

  Border? get _border {
    if (widget.type == AppButtonType.outline) {
      return Border.all(color: AppColors.accentPrimary, width: 1.5);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppSpacing.radiusFull;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: SizedBox(
          width: widget.width ?? double.infinity,
          height: 52,
          child: Material(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: null,
              splashColor: _foregroundColor.withOpacity(0.08),
              highlightColor: _foregroundColor.withOpacity(0.04),
              child: Container(
                decoration: BoxDecoration(
                  border: _border,
                  borderRadius: BorderRadius.circular(radius),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                child: widget.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_foregroundColor),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: AppTextStyles.labelLarge.copyWith(
                          color: _foregroundColor,
                          letterSpacing: 0.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
