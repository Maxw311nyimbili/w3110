import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Animated "thinking" indicator shown while Thanzi AI is generating a response.
///
/// Shows:
///  - The word "thinking" with a diagonal left-to-right light-shimmer sweep
///  - Three dots that bounce up and down with staggered offsets
class ThinkingIndicator extends StatefulWidget {
  const ThinkingIndicator({super.key});

  @override
  State<ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<ThinkingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _shimmerCtrl;
  late final AnimationController _dotCtrl;

  // Shimmer gradient sweeps diagonally left → right
  late final Animation<double> _shimmerAnim;

  // Each dot bounces at a phase offset
  late final Animation<double> _dotAnim;

  final List<String> _words = ['thinking', 'searching', 'analyzing', 'verifying'];
  int _wordIndex = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();

    // Shimmer: 1.8s loop
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _shimmerAnim = CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear);

    // Dots: 900ms sine loop
    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    _dotAnim = CurvedAnimation(parent: _dotCtrl, curve: Curves.linear);

    // Word cycling timer: 2s per word
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _wordIndex = (_wordIndex + 1) % _words.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    _dotCtrl.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Logo
          Image.asset(
            'assets/images/logo.png',
            height: 24, // Slightly larger logo
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 10),

          // Cycling word with shimmer
          AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (context, _) {
              final shimmerPos = _shimmerAnim.value;
              return ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (bounds) {
                  // Diagonal left-to-right sweep; highlight is ~30% wide
                  final start = shimmerPos - 0.35;
                  final end = shimmerPos + 0.35;
                  return LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      max(0, start),
                      max(0, start + 0.01),
                      (start + end) / 2,
                      min(1, end - 0.01),
                      min(1, end),
                    ],
                    colors: [
                      AppColors.brandDarkTeal.withOpacity(0.45),
                      AppColors.brandDarkTeal.withOpacity(0.55),
                      Colors.white.withOpacity(0.95), // bright highlight
                      AppColors.brandDarkTeal.withOpacity(0.55),
                      AppColors.brandDarkTeal.withOpacity(0.45),
                    ],
                  ).createShader(bounds);
                },
                child: SizedBox(
                  width: 85, // Fixed width to prevent jumping
                  child: Text(
                    _words[_wordIndex],
                    style: AppTextStyles.labelMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: AppColors.brandDarkTeal, // masked by shader
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 2),

          // Three bouncing dots
          AnimatedBuilder(
            animation: _dotAnim,
            builder: (context, _) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 3),
                  _buildDot(1),
                  const SizedBox(width: 3),
                  _buildDot(2),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    // Stagger each dot by 1/3 of the cycle
    final phase = (_dotAnim.value + index / 3.0) % 1.0;
    // Sine → range 0..1; map to -5..0 vertical offset (up = negative)
    final offset = -sin(phase * pi) * 5.0;
    return Transform.translate(
      offset: Offset(0, offset),
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.brandDarkTeal.withOpacity(0.6 + sin(phase * pi) * 0.4),
        ),
      ),
    );
  }
}
