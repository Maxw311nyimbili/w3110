// lib/features/medscanner/widgets/medscanner_body.dart

import 'package:cap_project/features/medscanner/widgets/widgets.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import 'camera_preview_widget.dart';
import 'scan_result_widget.dart';

/// Main scanner body - camera preview or scan results
class MedScannerBody extends StatelessWidget {
  const MedScannerBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<MedScannerCubit, MedScannerState>(
      listener: (context, state) {
        // Show errors
        if (state.error != null) {
          final l10n = AppLocalizations.of(context);
          String message;

          // Map error key to localized string
          switch (state.error) {
            case 'cameraPermissionDenied':
              message = l10n.cameraPermissionDenied;
              break;
            case 'noCameraFound':
              message = l10n.noCameraFound;
              break;
            case 'uploadFailed':
              message = l10n.uploadFailed;
              break;
            case 'analysisFailed':
              message = l10n.analysisFailed;
              break;
            case 'fileTooLarge':
              message = l10n.fileTooLarge;
              break;
            default:
              message = l10n.genericError;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.read<MedScannerCubit>().clearError();
        }
      },
      child: BlocBuilder<MedScannerCubit, MedScannerState>(
        builder: (context, state) {
          // Show scan results if available
          if (state.hasResult) {
            return ScanResultWidget(result: state.scanResult!);
          }

          // Show camera interface
          return _buildCameraInterface(context, state);
        },
      ),
    );
  }

  Widget _buildCameraInterface(BuildContext context, MedScannerState state) {
    return Column(
      children: [
        // Camera preview
        Expanded(
          child: state.isCameraInitialized
              ? const CameraPreviewWidget()
              : _buildCameraInitializing(context),
        ),

        // Instructions and controls
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Instructions
              Text(
                AppLocalizations.of(context).scanInstructions,
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                AppLocalizations.of(context).scanTips,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery button
                  _ActionButton(
                    icon: Icons.photo_library,
                    label: AppLocalizations.of(context).gallery,
                    onPressed: state.isProcessing
                        ? null
                        : () => context
                        .read<MedScannerCubit>()
                        .pickImageFromGallery(),
                  ),

                  // Capture button (primary)
                  _CaptureButton(
                    onPressed: state.canCapture && !state.isProcessing
                        ? () =>
                        context.read<MedScannerCubit>().captureImage()
                        : null,
                    isProcessing: state.isProcessing,
                  ),

                  // Placeholder for symmetry
                  const SizedBox(width: 80),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCameraInitializing(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              AppLocalizations.of(context).initializingCamera,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action button (Gallery, Flash, etc.)
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, size: 32),
          onPressed: onPressed,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.backgroundElevated,
            foregroundColor: AppColors.accentPrimary,
            disabledBackgroundColor: AppColors.gray200,
            disabledForegroundColor: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}

/// Large capture button
class _CaptureButton extends StatelessWidget {
  const _CaptureButton({
    required this.onPressed,
    this.isProcessing = false,
  });

  final VoidCallback? onPressed;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: onPressed != null
                ? AppColors.accentPrimary
                : AppColors.borderLight,
            width: 4,
          ),
          boxShadow: onPressed != null
              ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Center(
          child: isProcessing
              ? CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.accentPrimary,
            ),
          )
              : Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: onPressed != null
                  ? AppColors.accentPrimary
                  : AppColors.borderLight,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
