import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/widgets/thread_line_painter.dart';
import 'package:flutter/material.dart';

class HideRepliesButton extends StatelessWidget {
  final int depth;
  final List<bool> ancestorHasNext;
  final VoidCallback onTap;

  const HideRepliesButton({
    super.key,
    required this.depth,
    required this.ancestorHasNext,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const double indentWidth = 24.0;
    final Color lineColor = Theme.of(context).brightness == Brightness.light
        ? Colors.grey[400]!
        : Colors.grey[600]!;

    return IntrinsicHeight(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (depth > 0)
              SizedBox(
                width: depth * indentWidth,
                child: CustomPaint(
                  painter: ThreadLinePainter(
                    lineColor: lineColor,
                    isLastChild: true,
                    paddingLeft: 0,
                    depth: depth,
                    ancestorHasNext: ancestorHasNext,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 12),
                child: InkWell(
                  onTap: onTap,
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 1.5,
                        margin: const EdgeInsets.only(left: 12), // Align with where avatar was
                        color: lineColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hide replies',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
