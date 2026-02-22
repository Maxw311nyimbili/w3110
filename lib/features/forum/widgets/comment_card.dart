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
    this.currentUserId,
    this.onEdit,
    this.onDelete,
  });

  final String? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final roleIconInfo = _getRoleIconInfo(comment.authorRole);
    final typeLabel = comment.commentType != CommentType.general ? comment.typeLabel : null;
    final isExpert = comment.authorRole == CommentRole.clinician || comment.authorRole == CommentRole.supportPartner;
    final isClinician = comment.authorRole == CommentRole.clinician;

    final isReply = comment.parentCommentId != null;

    return Padding(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: isReply ? 16.0 : 0.0,
      ),
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
                  width: isReply ? 28 : 36,
                  height: isReply ? 28 : 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isExpert 
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.backgroundElevated,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    roleIconInfo, 
                    size: isReply ? 14 : 18, 
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
                      child: Icon(
                        Icons.check,
                        size: isReply ? 8 : 10,
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
                          fontSize: isReply ? 12 : 14,
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
                              fontSize: isReply ? 9 : 10,
                              color: isClinician ? AppColors.success : AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatTime(comment.createdAt),
                        style: AppTextStyles.caption.copyWith(
                          fontSize: isReply ? 9 : 10,
                          color: AppColors.textTertiary
                        ),
                      ),
                      if (currentUserId == comment.authorId) ...[
                        const SizedBox(width: 4),
                        _buildCommentActions(context),
                      ],
                    ],
                  ),

                  // Profession (if available)
                  if (comment.authorProfession != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      comment.authorProfession!,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: isReply ? 9 : 10,
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
                        fontSize: isReply ? 8 : 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),

                  // Content
                  Text(
                    comment.text,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: isReply ? 13 : 14,
                      height: 1.4, 
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  // Footer (Reply) - Only show if not already a reply (limiting to 1 level for now like IG)
                  if (!isReply) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: onReply,
                      child: Text(
                        'Reply',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      icon: const Icon(Icons.more_horiz_rounded, size: 14, color: AppColors.textTertiary),
      onSelected: (value) {
        if (value == 'edit') {
           onEdit?.call();
        } else if (value == 'delete') {
           onDelete?.call();
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          height: 32,
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 14),
              SizedBox(width: 8),
              Text('Edit', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          height: 32,
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 14, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
          ),
        ),
      ],
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
