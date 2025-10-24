// lib/features/forum/widgets/comment_list_item.dart

import 'package:flutter/material.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Comment list item - displays a single comment
class CommentListItem extends StatelessWidget {
  const CommentListItem({
    required this.comment,
    super.key,
  });

  final ForumComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author avatar
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.accentPrimary.withOpacity(0.2),
            child: Text(
              comment.authorName[0].toUpperCase(),
              style: TextStyle(
                color: AppColors.accentPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author name and timestamp
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    // Sync indicator
                    if (comment.isPendingSync)
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 14,
                        color: AppColors.warning,
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Comment text
                Text(
                  comment.content,
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}