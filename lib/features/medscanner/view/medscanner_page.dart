// lib/features/medscanner/view/medscanner_page.dart

import 'package:cap_project/core/widgets/app_drawer.dart';
import 'package:cap_project/features/medscanner/cubit/cubit.dart';
import 'package:cap_project/features/medscanner/widgets/widgets.dart';
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
      child: const MedScannerView(),
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
          appBar: AppBar(
            title: const Text('Med Scanner'),
            actions: [
              // Show info button
              IconButton(
                icon: const Icon(Icons.info_outline_rounded),
                tooltip: 'How to use',
                onPressed: () => _showInfoDialog(context),
              ),
            ],
          ),
          drawer: const AppDrawer(),
          body: const SafeArea(
            child: MedScannerBody(),
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.camera_alt_rounded, color: Colors.blue),
            SizedBox(width: 8),
            Text('How to Use Med Scanner'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '1. Take a clear photo of your medication package',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 12),
            Text(
              '2. Make sure the text is readable',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 12),
            Text(
              '3. Our AI will identify the medication and provide information',
              style: TextStyle(fontSize: 15),
            ),
            SizedBox(height: 16),
            Text(
              '💡 Tip: Good lighting helps!',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
}