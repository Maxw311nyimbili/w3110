// lib/features/medscanner/view/medscanner_page.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/features/medscanner/cubit/cubit.dart';
import 'package:cap_project/features/medscanner/widgets/widgets.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:media_repository/media_repository.dart';

/// MedScanner page - camera and image analysis
class MedScannerPage extends StatelessWidget {
  const MedScannerPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const MedScannerPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MedScannerCubit(
        mediaRepository: context.read<MediaRepository>(),
      )..initialize(),
      child: Builder(
        builder: (context) {
          // Check for arguments after the cubit is created
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args == 'gallery') {
              context.read<MedScannerCubit>().pickImageFromGallery();
            }
          });
          return const MedScannerView();
        },
      ),
    );
  }
}

/// MedScanner view - wraps scanner body
class MedScannerView extends StatelessWidget {
  const MedScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedScannerCubit, MedScannerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(AppLocalizations.of(context).medScanner),
            centerTitle: true,
            actions: [
              // Show info button
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: AppLocalizations.of(context).howToUse,
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          body: const SafeArea(
            child: MedScannerBody(),
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Header
            Row(
              children: [
                const Icon(Icons.center_focus_strong_rounded, color: AppColors.accentPrimary, size: 28),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).scannerGuide,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Steps
            _buildInfoStep(
              context,
              '1',
              AppLocalizations.of(context).scannerStep1Title,
              AppLocalizations.of(context).scannerStep1Desc,
            ),
            _buildInfoStep(
              context,
              '2',
              AppLocalizations.of(context).scannerStep2Title,
              AppLocalizations.of(context).scannerStep2Desc,
            ),
            _buildInfoStep(
              context,
              '3',
              AppLocalizations.of(context).scannerStep3Title,
              AppLocalizations.of(context).scannerStep3Desc,
            ),

            const SizedBox(height: 32),

            // Close button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.accentPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(AppLocalizations.of(context).startScanning),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(
      BuildContext context,
      String number,
      String title,
      String description,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: AppColors.accentPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
