import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class ThreadLinePainter extends CustomPainter {
  final Color lineColor;
  final bool isLastChild;
  final double paddingLeft;
  final int depth;

  ThreadLinePainter({
    required this.lineColor,
    required this.isLastChild,
    required this.paddingLeft,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Nested avatar size is 24, center at 12
    const double avatarCenterY = 12.0; 
    const double radius = 10.0;
    
    // We assume the track is aligned in the middle of each 24px indent segment
    // Current segment start is (depth-1)*24.0
    // Let's place the track at 12px into that segment.
    final double trackX = (depth - 1) * 24.0 + 12.0;

    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2 // Thinner for compact look
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // 1. Draw ALL vertical lines for the tracks of intermediate parents
    // This creates the "Youtube style" continuous vertical lines for parent threads
    for (int i = 0; i < depth - 1; i++) {
      final double px = i * 24.0 + 12.0;
      path.moveTo(px, 0);
      path.lineTo(px, size.height);
    }

    // 2. Draw the vertical line and curve for the IMMEDIATE parent
    path.moveTo(trackX, 0);
    
    if (isLastChild) {
      // Curve to the right
      path.lineTo(trackX, avatarCenterY - radius);
      path.quadraticBezierTo(
        trackX, avatarCenterY, 
        trackX + radius, avatarCenterY,
      );
      // Extend to the edge (where the avatar starts)
      path.lineTo(size.width, avatarCenterY);
    } else {
      // Vertical line all the way down
      path.lineTo(trackX, size.height);
      
      // Horizontal branch
      path.moveTo(trackX, avatarCenterY);
      path.lineTo(size.width, avatarCenterY);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThreadLinePainter oldDelegate) {
    return oldDelegate.isLastChild != isLastChild || 
           oldDelegate.paddingLeft != paddingLeft ||
           oldDelegate.depth != depth;
  }
}
