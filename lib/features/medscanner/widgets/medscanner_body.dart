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

        // Handle success - navigate back to chat with result
        if (state.status == MedScannerStatus.success && state.hasResult) {
          final result = state.scanResult!;
          // We need access to ChatCubit here. 
          // Since MedScannerPage is usually pushed from ChatPage, 
          // we can return the result via Navigator.pop
          Navigator.pop(context, result);
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
    return Stack(
      children: [
        // 1. Camera Preview (Full Screen)
        Positioned.fill(
          child: state.isCameraInitialized
              ? const CameraPreviewWidget()
              : _buildCameraInitializing(context),
        ),

        // 2. Gradient Overlay for Text Readability at Bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 200,
          child: Container(
             decoration: BoxDecoration(
               gradient: LinearGradient(
                 begin: Alignment.bottomCenter,
                 end: Alignment.topCenter,
                 colors: [
                   Colors.black.withOpacity(0.8),
                   Colors.transparent,
                 ],
               ),
             ),
          ),
        ),

        // 3. Floating Controls
        Positioned(
          bottom: 40,
          left: 24,
          right: 24,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tip Text
              Text(
                AppLocalizations.of(context).scanTips,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Controls Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   // Gallery Button (Glassy)
                  _GlassActionButton(
                    icon: Icons.photo_library_rounded,
                    onPressed: state.isProcessing
                        ? null
                        : () => context.read<MedScannerCubit>().pickImageFromGallery(),
                  ),

                  // Shutter Button (Premium)
                  _PremiumShutterButton(
                    onPressed: state.canCapture && !state.isProcessing
                        ? () => context.read<MedScannerCubit>().captureImage()
                        : null,
                    isProcessing: state.isProcessing,
                  ),

                  // Spacer/Placeholder for symmetry (or maybe Flash?)
                  // Let's add a placeholder glassy button or nothing for now.
                  // Actually, let's keep it balanced.
                  const SizedBox(width: 56), 
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

class _GlassActionButton extends StatelessWidget {
  const _GlassActionButton({
    required this.icon,
    this.onPressed,
  });

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: onPressed != null ? Colors.white : Colors.white38,
          size: 24,
        ),
      ),
    );
  }
}

class _PremiumShutterButton extends StatelessWidget {
  const _PremiumShutterButton({
    required this.onPressed,
    this.isProcessing = false,
  });

  final VoidCallback? onPressed;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 84,
        height: 84,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(4), // Gap between ring and button
        child: isProcessing
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              )
            : Container(
                decoration: BoxDecoration(
                  color: isEnabled ? Colors.white : Colors.white24,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
