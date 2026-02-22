import 'package:flutter/material.dart';

class BrandLogo extends StatefulWidget {
  final double size;
  final bool isBreathing;
  final Duration duration;

  const BrandLogo({
    super.key,
    this.size = 100,
    this.isBreathing = true,
    this.duration = const Duration(seconds: 2),
  });

  @override
  State<BrandLogo> createState() => _BrandLogoState();
}

class _BrandLogoState extends State<BrandLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.92, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutSine,
      ),
    );

    if (widget.isBreathing) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(BrandLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBreathing != oldWidget.isBreathing) {
      if (widget.isBreathing) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Image.asset(
        'assets/images/logo.png',
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.emergency_rounded,
          size: widget.size * 0.6,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
