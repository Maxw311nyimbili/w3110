import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';

class AppBentoCard extends StatelessWidget {
  const AppBentoCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.color,
    this.height,
    this.icon,
    super.key,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;
  final double? height;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.accentPrimary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          height: height,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? themeColor.withOpacity(0.08)
                : themeColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? themeColor : themeColor.withOpacity(0.12),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: themeColor.withOpacity(0.12),
                      blurRadius: 40,
                      offset: const Offset(0, 12),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 28,
                  color: isSelected ? themeColor : AppColors.textTertiary,
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: AppTextStyles.labelSmall.copyWith(
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? themeColor : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
