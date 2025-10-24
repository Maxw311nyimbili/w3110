// lib/features/medscanner/widgets/medscanner_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
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
          child: Column(
            children: [
              // Instructions
              Text(
                'Point at medicine label or barcode',
                style: AppTextStyles.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Ensure good lighting and hold steady',
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(0.6),
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
                    label: 'Gallery',
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: AppSpacing.lg),
          Text('Initializing camera...'),
        ],
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
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
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
            color: Theme.of(context).colorScheme.primary,
            width: 4,
          ),
        ),
        child: Center(
          child: isProcessing
              ? const CircularProgressIndicator()
              : Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}