import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AudioWaveform extends StatefulWidget {
  final bool isRecording;
  final double amplitude;

  const AudioWaveform({
    super.key,
    this.isRecording = false,
    this.amplitude = -160.0,
  });

  @override
  State<AudioWaveform> createState() => _AudioWaveformState();
}

class _AudioWaveformState extends State<AudioWaveform> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // Increase bar count for a smoother look
  final int _barCount = 20;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isRecording) _controller.repeat();
  }

  @override
  void didUpdateWidget(AudioWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording && !oldWidget.isRecording) {
      _controller.repeat();
    } else if (!widget.isRecording && oldWidget.isRecording) {
      _controller.stop();
    }
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
          children: List.generate(_barCount, (index) {
            double heightFactor;
            
            if (widget.isRecording) {
              // Reactive mode: Compose base oscillation with real amplitude
              // Normalizing amplitude (-160 to 0) to a 0.1 - 1.0 range
              final double normalizedAmp = (widget.amplitude + 160) / 160;
              final double phase = (index * 0.5) + (_controller.value * 2 * pi);
              final double oscillation = (sin(phase) + 1) / 2;
              
              heightFactor = 0.05 + (oscillation * normalizedAmp * 0.95);
            } else {
              // Idle mode: Flat dots
              heightFactor = 0.02;
            }
            
            return AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 3, 
              height: widget.isRecording ? 4 + (heightFactor * 40) : 4,
              decoration: BoxDecoration(
                color: widget.isRecording 
                  ? AppColors.accentPrimary.withOpacity(index % 2 == 0 ? 0.8 : 0.4)
                  : AppColors.textTertiary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}
