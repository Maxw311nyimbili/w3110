// lib/features/medscanner/widgets/scan_result_widget.dart

import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../app/view/app_router.dart';

/// Scan result display - shows medication information after scanning
class ScanResultWidget extends StatelessWidget {
  const ScanResultWidget({
    required this.result,
    super.key,
  });

  final ScanResult result;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Success icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: AppColors.success,
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Medication name
          Text(
            result.medicationName,
            style: AppTextStyles.displayMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.md),

          // Confidence indicator
          _buildConfidenceBar(context),

          const SizedBox(height: AppSpacing.xl),

          // Barcode if detected
          if (result.barcode != null) ...[
            _buildInfoCard(
              context,
              icon: Icons.qr_code,
              title: AppLocalizations.of(context).barcode,
              content: result.barcode!,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Active ingredients
          if (result.activeIngredients.isNotEmpty) ...[
            _buildInfoCard(
              context,
              icon: Icons.science_outlined,
              title: AppLocalizations.of(context).activeIngredients,
              content: result.activeIngredients.join(', '),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Dosage information
          if (result.dosageInfo != null) ...[
            _buildInfoCard(
              context,
              icon: Icons.medication_outlined,
              title: AppLocalizations.of(context).dosage,
              content: result.dosageInfo!,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],

          // Warnings
          if (result.warnings.isNotEmpty) ...[
            _buildWarningsCard(context),
            const SizedBox(height: AppSpacing.xl),
          ],

          // Action buttons
          const SizedBox(height: AppSpacing.xl),

          // Send to chat button (primary action)
          ElevatedButton.icon(
            onPressed: () {
              // Smooth transition to Chat with the scan result context
              AppRouter.replaceTo<void>(
                context,
                AppRouter.chat,
                arguments: result,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context).openingChat),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline),
            label: Text(AppLocalizations.of(context).discussWithAi),
          ),

          const SizedBox(height: AppSpacing.md),

          // Scan again button (secondary)
          OutlinedButton.icon(
            onPressed: () {
              context.read<MedScannerCubit>().clearScan();
            },
            icon: const Icon(Icons.camera_alt),
            label: Text(AppLocalizations.of(context).scanAnother),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Disclaimer
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).medicalDisclaimer,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceBar(BuildContext context) {
    final percentage = (result.confidence * 100).toInt();
    final color = result.confidence >= 0.8
        ? AppColors.confidenceHigh
        : result.confidence >= 0.5
        ? AppColors.confidenceMedium
        : AppColors.confidenceLow;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_outlined,
              size: 16,
              color: color,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              '${percentage}% ${AppLocalizations.of(context).matchConfidence}',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: result.confidence,
            minHeight: 8,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String content,
      }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  content,
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber,
                size: 24,
                color: AppColors.error,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                AppLocalizations.of(context).importantWarnings,
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...result.warnings.map((warning) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    warning,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}