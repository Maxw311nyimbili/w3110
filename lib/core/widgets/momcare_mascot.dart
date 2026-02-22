import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'dart:math' as math;

class MomCareMascot extends StatefulWidget {
  const MomCareMascot({
    this.size = 200,
    super.key,
  });

  final double size;

  @override
  State<MomCareMascot> createState() => _MomCareMascotState();
}

class _MomCareMascotState extends State<MomCareMascot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
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
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulse 1
              _MascotRing(
                progress: _controller.value,
                delay: 0.0,
                baseColor: AppColors.accentSecondary,
                size: widget.size,
              ),
              // Outer Pulse 2
              _MascotRing(
                progress: _controller.value,
                delay: 0.5,
                baseColor: AppColors.accentPrimary,
                size: widget.size,
              ),
              // The Core
              Container(
                width: widget.size * 0.4,
                height: widget.size * 0.4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.textPrimary,
                      AppColors.accentPrimary.withOpacity(0.8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPrimary.withOpacity(0.3),
                      blurRadius:
                          20 *
                          (1 + math.sin(_controller.value * 2 * math.pi) * 0.2),
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.lens_blur_rounded,
                    color: Colors.white.withOpacity(0.9),
                    size: widget.size * 0.15,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MascotRing extends StatelessWidget {
  const _MascotRing({
    required this.progress,
    required this.delay,
    required this.baseColor,
    required this.size,
  });

  final double progress;
  final double delay;
  final Color baseColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    double p = (progress + delay) % 1.0;
    double opacity = (1.0 - p).clamp(0.0, 1.0);
    double scale = 0.4 + (p * 0.6);

    return Opacity(
      opacity: opacity * 0.3,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: baseColor,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
