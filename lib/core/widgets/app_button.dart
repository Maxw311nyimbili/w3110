import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';

enum AppButtonType { primary, secondary, outline }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final double? width;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppButton({
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.width,
    this.backgroundColor,
    this.foregroundColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBackgroundColor = backgroundColor ?? _getBackgroundColor();
    final effectiveForegroundColor = foregroundColor ?? _getForegroundColor();
    final border = _getBorder();

    return SizedBox(
      width: width ?? double.infinity,
      height: 56,
      child: Material(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          splashColor: effectiveForegroundColor.withOpacity(0.1),
          child: Container(
            decoration: BoxDecoration(
              border: border,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        effectiveForegroundColor,
                      ),
                    ),
                  )
                : Text(
                    text,
                    style: AppTextStyles.labelLarge.copyWith(
                      color: effectiveForegroundColor,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (onPressed == null) return AppColors.backgroundElevated;
    switch (type) {
      case AppButtonType.primary:
        return AppColors.accentPrimary;
      case AppButtonType.secondary:
        return AppColors.accentSecondary;
      case AppButtonType.outline:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor() {
    if (onPressed == null) return AppColors.textTertiary;
    switch (type) {
      case AppButtonType.primary:
        return AppColors.textInverted;
      case AppButtonType.secondary:
        return AppColors.textInverted;
      case AppButtonType.outline:
        return AppColors.accentPrimary;
    }
  }

  Border? _getBorder() {
    if (type == AppButtonType.outline) {
      return Border.all(color: AppColors.accentPrimary, width: 1.5);
    }
    return null;
  }
}
