// lib/features/chat/widgets/confidence_indicator.dart

import 'package:flutter/material.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

/// Confidence indicator - shows AI response confidence level
class ConfidenceIndicator extends StatelessWidget {
  const ConfidenceIndicator({
    required this.confidence,
    required this.level,
    super.key,
  });

  final double confidence; // 0.0 - 1.0
  final ConfidenceLevel level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Confidence bar
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: confidence,
            child: Container(
              decoration: BoxDecoration(
                color: _getConfidenceColor(),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),

        const SizedBox(width: AppSpacing.sm),

        // Confidence label
        Text(
          _getConfidenceLabel(),
          style: AppTextStyles.labelSmall.copyWith(
            color: _getConfidenceColor(),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Info icon
        const SizedBox(width: AppSpacing.xs),
        GestureDetector(
          onTap: () => _showConfidenceInfo(context),
          child: Icon(
            Icons.info_outline,
            size: 14,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    switch (level) {
      case ConfidenceLevel.high:
        return AppColors.confidenceHigh;
      case ConfidenceLevel.medium:
        return AppColors.confidenceMedium;
      case ConfidenceLevel.low:
        return AppColors.confidenceLow;
      case ConfidenceLevel.none:
        return AppColors.gray400;
    }
  }

  String _getConfidenceLabel() {
    switch (level) {
      case ConfidenceLevel.high:
        return AppStrings.confidenceHigh;
      case ConfidenceLevel.medium:
        return AppStrings.confidenceMedium;
      case ConfidenceLevel.low:
        return AppStrings.confidenceLow;
      case ConfidenceLevel.none:
        return 'No confidence';
    }
  }

  void _showConfidenceInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confidence Score'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This indicates how confident the AI is in its response:',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildConfidenceExample(
              'High (80-100%)',
              'Based on well-established medical information',
              AppColors.confidenceHigh,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildConfidenceExample(
              'Medium (50-80%)',
              'General guidance; verify with healthcare provider',
              AppColors.confidenceMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildConfidenceExample(
              'Low (<50%)',
              'Uncertain; consult medical professional',
              AppColors.confidenceLow,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceExample(
    String title,
    String description,
    Color color,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                description,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
