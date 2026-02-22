// lib/features/medscanner/widgets/camera_preview_widget.dart

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/l10n/l10n.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Camera preview widget - displays live camera feed
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<MedScannerCubit>();
    final controller = cubit.cameraController;

    // Simple check: if controller is null OR not initialized
    if (controller == null) {
      return _buildLoadingState(context);
    }

    if (controller.value.isInitialized == false) {
      return _buildLoadingState(context);
    }

    // Controller is ready - use it safely
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Live camera preview - forced to cover
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.previewSize?.height ?? 1,
                  height: controller.value.previewSize?.width ?? 1,
                  child: CameraPreview(controller),
                ),
              ),
            ),

            // Dark overlay
            Container(
              color: Colors.black.withOpacity(0.1),
            ),

            // Scanning frame overlay
            Center(
              child: _buildScanningFrame(context),
            ),

            // Top instruction banner
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context).alignLabelWithinFrame,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.accentPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).initializingCamera,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildScanningFrame(BuildContext context) {
    return Container(
      width: 280,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.accentPrimary,
          width: 3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Corner brackets for better visual guidance
          _buildCornerBracket(
            Alignment.topLeft,
            const BorderRadius.only(topLeft: Radius.circular(12)),
          ),
          _buildCornerBracket(
            Alignment.topRight,
            const BorderRadius.only(topRight: Radius.circular(12)),
          ),
          _buildCornerBracket(
            Alignment.bottomLeft,
            const BorderRadius.only(bottomLeft: Radius.circular(12)),
          ),
          _buildCornerBracket(
            Alignment.bottomRight,
            const BorderRadius.only(bottomRight: Radius.circular(12)),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerBracket(Alignment alignment, BorderRadius radius) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.accentPrimary,
          borderRadius: radius,
        ),
      ),
    );
  }
}
