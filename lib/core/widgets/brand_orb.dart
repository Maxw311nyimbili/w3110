import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BrandOrb extends StatefulWidget {
  final double size;
  final bool isThinking;

  const BrandOrb({
    super.key,
    this.size = 100,
    this.isThinking = false,
  });

  @override
  State<BrandOrb> createState() => _BrandOrbState();
}

class _BrandOrbState extends State<BrandOrb> with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _rotationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.1,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.1,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_breathingController);
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_breathingController, _rotationController]),
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _OrbPainter(
              progress: _breathingController.value,
              rotation: _rotationController.value,
              color: AppColors.accentPrimary,
              isThinking: widget.isThinking,
            ),
          ),
        );
      },
    );
  }
}

class _OrbPainter extends CustomPainter {
  final double progress;
  final double rotation;
  final Color color;
  final bool isThinking;

  _OrbPainter({
    required this.progress,
    required this.rotation,
    required this.color,
    required this.isThinking,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * 0.35;

    // 1. Draw outer glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.1 + (0.1 * progress))
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20 * progress);
    canvas.drawCircle(center, baseRadius * 1.4, glowPaint);

    // 2. Draw subtle "spikes" or energy rays if thinking
    if (isThinking) {
      final rayPaint = Paint()
        ..color = color.withOpacity(0.2 * progress)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      final count = 12;
      for (var i = 0; i < count; i++) {
        final angle = (i * 2 * math.pi / count) + (rotation * 2 * math.pi);
        final inner =
            center + Offset(math.cos(angle), math.sin(angle)) * baseRadius;
        final outer =
            center +
            Offset(math.cos(angle), math.sin(angle)) *
                (baseRadius * (1.2 + 0.2 * progress));
        canvas.drawLine(inner, outer, rayPaint);
      }
    }

    // 3. Draw main orb layers
    final mainPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.8),
          color.withOpacity(0.4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: baseRadius));

    canvas.drawCircle(center, baseRadius * (1.0 + 0.05 * progress), mainPaint);

    // 4. Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3 * (1 - progress));
    canvas.drawCircle(
      center + Offset(-baseRadius * 0.3, -baseRadius * 0.3),
      baseRadius * 0.2,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _OrbPainter oldDelegate) => true;
}
