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
    final typeLabel = comment.commentType != CommentType.general ? comment.typeLabel : null;
    final isExpert = comment.authorRole == CommentRole.clinician || comment.authorRole == CommentRole.supportPartner;
    final isClinician = comment.authorRole == CommentRole.clinician;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: isExpert 
              ? (isClinician ? AppColors.success.withOpacity(0.04) : AppColors.accentPrimary.withOpacity(0.04))
              : AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isExpert 
                ? (isClinician ? AppColors.success.withOpacity(0.15) : AppColors.accentPrimary.withOpacity(0.15))
                : AppColors.borderLight,
            width: isExpert ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with expert highlight
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isExpert 
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.backgroundElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    roleIconInfo, 
                    size: 18, 
                    color: isExpert 
                        ? (isClinician ? AppColors.success : AppColors.accentPrimary)
                        : AppColors.textSecondary,
                  ),
                ),
                if (isExpert)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 10,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with expert badge
                  Row(
                    children: [
                      Text(
                        comment.authorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isExpert 
                              ? (isClinician ? AppColors.success : AppColors.accentPrimary)
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isExpert) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isClinician ? 'Expert' : 'Support',
                            style: AppTextStyles.caption.copyWith(
                              color: isClinician ? AppColors.success : AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatTime(comment.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                      ),
                    ],
                  ),

                  // Profession (if available)
                  if (comment.authorProfession != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      comment.authorProfession!,
                      style: AppTextStyles.caption.copyWith(
                        color: isExpert 
                            ? (isClinician ? AppColors.success : AppColors.accentPrimary)
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  
                  // Optional Type Badge
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
                  const SizedBox(height: 8),

                  // Content
                  Text(
                    comment.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      height: 1.5, 
                      color: AppColors.textPrimary,
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
      ),
    );
  }

  IconData _getRoleIconInfo(CommentRole role) {
    switch (role) {
      case CommentRole.clinician: return Icons.local_hospital_outlined;
      case CommentRole.mother: return Icons.face_4_outlined;
      case CommentRole.community: return Icons.person_outline;
      case CommentRole.supportPartner: return Icons.handshake_outlined;
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
