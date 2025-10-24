// lib/features/medscanner/widgets/camera_preview_widget.dart

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Camera preview widget - displays live camera feed
/// TODO: Replace with actual camera package implementation (camera, camera_platform_interface)
class CameraPreviewWidget extends StatelessWidget {
  const CameraPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // TODO: Uncomment when camera package is integrated
        /*
        // Actual camera preview
        CameraPreview(_cameraController),
        */

        // TEMPORARY: Mock camera preview for development
        Container(
          color: Colors.black87,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 80,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Camera Preview',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '(Will show live camera feed)',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Scanning frame overlay (helps user frame the medication)
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
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Align label within the frame',
                    style: TextStyle(
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