// lib/features/forum/widgets/comment_card.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:forum_repository/forum_repository.dart';

class CommentCard extends StatelessWidget {
  final ForumLineComment comment;
  final VoidCallback onReply;

  const CommentCard({
    super.key,
    required this.comment,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    final roleIcon = _getRoleIcon(comment.authorRole);
    final typeLabel = comment.typeLabel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author + role
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Text(roleIcon, style: const TextStyle(fontSize: 16)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.authorName,
                    style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (comment.authorProfession != null)
                    Text(
                      comment.authorProfession!,
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                ],
              ),
            ),
             Text(
              _formatTime(comment.createdAt),
              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Comment type badge
        if (comment.lineId != 'general') ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accentPrimary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              typeLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.accentPrimary,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Comment text
        Text(
          comment.text,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.5, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 12),

        // Actions (Reply)
        GestureDetector(
          onTap: onReply,
          child: Text(
            'Reply',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.accentPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  String _getRoleIcon(CommentRole role) {
    switch (role) {
      case CommentRole.clinician: return '⚕️';
      case CommentRole.mother: return '👩‍🤰';
      case CommentRole.community: return '👤';
      default: return '💬';
    }
  }
  
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'just now';
  }
}
