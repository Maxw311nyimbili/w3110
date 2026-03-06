import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class ThreadLinePainter extends CustomPainter {
  final Color lineColor;
  final bool isLastChild;
  final double paddingLeft;
  final int depth;
  final List<bool> ancestorHasNext;

  ThreadLinePainter({
    required this.lineColor,
    required this.isLastChild,
    required this.paddingLeft,
    required this.depth,
    required this.ancestorHasNext,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (depth <= 0) return;

    // Nested avatar size is usually around 28-24, center it.
    // In CommentCard, depth > 0 size is 28. Center is 14.
    const double avatarCenterY = 20.0; // Adjusted for top padding of comment 
    const double radius = 12.0;
    const double indentWidth = 24.0;
    
    final paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final path = Path();
    
    // 1. Draw vertical tracks for all ancestors that have more siblings
    for (int i = 0; i < ancestorHasNext.length; i++) {
      if (ancestorHasNext[i]) {
        final double vx = i * indentWidth + indentWidth / 2;
        path.moveTo(vx, 0);
        path.lineTo(vx, size.height);
      }
    }

    // 2. Draw the branch for the current comment
    // The current comment's branch starts at the track of its immediate parent
    final double currentTrackX = (depth - 1) * indentWidth + indentWidth / 2;
    
    path.moveTo(currentTrackX, 0);
    
    if (isLastChild) {
      // Curved "L" shape
      path.lineTo(currentTrackX, avatarCenterY - radius);
      path.quadraticBezierTo(
        currentTrackX, avatarCenterY, 
        currentTrackX + radius, avatarCenterY,
      );
    } else {
      // "T" shape: vertical line continues, horizontal branch goes out
      path.lineTo(currentTrackX, size.height);
      
      path.moveTo(currentTrackX, avatarCenterY);
      path.lineTo(currentTrackX + radius, avatarCenterY);
    }
    
    // Extend the horizontal branch to the end of the indent area
    // The indent area ends at depth * indentWidth
    // Wait, the CommentCard Row has an Expanded area starting after depth * indentWidth.
    // So the painter should draw up to size.width.
    path.lineTo(size.width, avatarCenterY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant ThreadLinePainter oldDelegate) {
    return oldDelegate.isLastChild != isLastChild || 
           oldDelegate.depth != depth ||
           oldDelegate.ancestorHasNext != ancestorHasNext ||
           oldDelegate.lineColor != lineColor;
  }
}
