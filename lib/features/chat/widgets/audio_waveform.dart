import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AudioWaveform extends StatefulWidget {
  const AudioWaveform({super.key});

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [0.2, 0.5, 0.8, 0.4, 0.9, 0.6, 0.3, 0.7, 0.5, 0.9, 0.4, 0.6];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_baseHeights.length, (index) {
            // Create a "dancing" effect like NotebookLM
            final double phase = (index * 0.4) + (_controller.value * 2 * pi);
            final double oscillation = (sin(phase) + 1) / 2; // 0.0 to 1.0
            
            // Compose base height with oscillation
            final double heightFactor = 0.1 + (oscillation * 0.9); 
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 4, // Thinner bars as requested
              height: 8 + (heightFactor * 40),
              decoration: BoxDecoration(
                color: index % 2 == 0 
                  ? AppColors.textPrimary.withOpacity(0.8)
                  : AppColors.textPrimary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        );
      },
    );
  }
}
