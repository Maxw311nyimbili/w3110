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
    final roleIconInfo = _getRoleIconInfo(comment.authorRole);
    // Only show type label if it's not generic
    final typeLabel = comment.commentType != CommentType.general ? comment.typeLabel : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Minimal Avatar/Icon
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.backgroundElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(roleIconInfo, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (comment.authorProfession != null) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${comment.authorProfession}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatTime(comment.createdAt),
                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                
                // Optional Type Badge (Subtle)
                if (typeLabel != null && comment.lineId != 'general') ...[
                  const SizedBox(height: 4),
                  Text(
                    typeLabel.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accentPrimary.withOpacity(0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
                const SizedBox(height: 6),

                // Content
                Text(
                  comment.text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    height: 1.5, 
                    color: AppColors.textPrimary
                  ),
                ),
                
                // Footer (Reply)
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: onReply,
                  child: Text(
                    'Reply',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRoleIconInfo(CommentRole role) {
    switch (role) {
      case CommentRole.clinician: return Icons.local_hospital_outlined;
      case CommentRole.mother: return Icons.face_4_outlined;
      case CommentRole.community: return Icons.person_outline;
      default: return Icons.chat_bubble_outline_rounded;
    }
  }
  
  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
