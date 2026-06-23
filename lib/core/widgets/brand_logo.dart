// lib/core/widgets/brand_logo.dart
// Naiia animated brand mark — real SVG paths via flutter_svg.
//
// Two-layer approach from IMPLEMENTATION.md:
//   assets/svgs/naiia-core.svg   — taupe heart-hands body
//   assets/svgs/naiia-sparks.svg — slate-blue corner sparks
//
// Breathing animation  : core scale 1.0 → 1.022, 3.4s ease-in-out
// Spark twinkling      : opacity 0.55 → 1.0 → 0.55, same duration

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BrandLogo extends StatefulWidget {
  final double size;
  final bool isBreathing;

  /// 3.4s ease-in-out from IMPLEMENTATION.md naiia-logo-pulse spec
  final Duration duration;

  const BrandLogo({
    super.key,
    this.size = 100,
    this.isBreathing = true,
    this.duration = const Duration(milliseconds: 3400),
  });

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  // Core breathe: 1.0 → 1.022 (from logo-pulse CSS `.breath` spec)
  late final Animation<double> _breathe;

  // Sparks twinkle: 0.55 → 1.0 → 0.55 (from logo-pulse `@keyframes tw` spec)
  late final Animation<double> _sparkOpacity;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);

    _breathe = Tween<double>(begin: 1.0, end: 1.022).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOutSine),
    );

    // tw keyframes: 0%,100% opacity 0.55; 45% opacity 1.0
    _sparkOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.55, end: 1.0), weight: 45),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.55), weight: 55),
    ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOutSine));

    if (widget.isBreathing) _c.repeat(reverse: false);
  }

  @override
  void didUpdateWidget(BrandLogo old) {
    super.didUpdateWidget(old);
    if (widget.isBreathing != old.isBreathing) {
      if (widget.isBreathing) {
        _c.repeat(reverse: false);
      } else {
        _c.stop();
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Core mark — gentle breathing scale (bottom layer, same as SVG source order)
              Transform.scale(
                scale: widget.isBreathing ? _breathe.value : 1.0,
                child: SvgPicture.asset(
                  'assets/svgs/naiia-core.svg',
                  width: widget.size,
                  height: widget.size,
                  fit: BoxFit.contain,
                ),
              ),
              // Sparks layer — on top, twinkling opacity
              Opacity(
                opacity: widget.isBreathing ? _sparkOpacity.value : 0.7,
                child: Transform.scale(
                  scale: widget.isBreathing ? _breathe.value : 1.0,
                  child: SvgPicture.asset(
                    'assets/svgs/naiia-sparks.svg',
                    width: widget.size,
                    height: widget.size,
                    fit: BoxFit.contain,
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
