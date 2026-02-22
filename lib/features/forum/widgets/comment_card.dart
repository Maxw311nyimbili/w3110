// lib/features/forum/widgets/comment_card.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:forum_repository/forum_repository.dart';

class CommentCard extends StatelessWidget {
  final String authorName;
  final String text;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;
  final String? authorRoleLabel;
  final String? profession;
  final bool isExpert;
  final bool isClinician;
  final IconData roleIcon;
  final String? typeLabel;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final int depth;
  final String? currentUserId;
  final String authorId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const CommentCard({
    super.key,
    required this.authorName,
    required this.text,
    required this.createdAt,
    required this.onReply,
    required this.onLike,
    required this.authorId,
    this.likeCount = 0,
    this.isLiked = false,
    this.authorRoleLabel,
    this.profession,
    this.isExpert = false,
    this.isClinician = false,
    this.roleIcon = Icons.person_outline,
    this.typeLabel,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
    this.depth = 0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIsExpert = isExpert;
    final effectiveIsClinician = isClinician;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Thread Line area
          if (depth > 0)
            Row(
              children: List.generate(depth, (index) => Container(
                width: 24, // Consistent indentation
                alignment: Alignment.centerLeft,
                child: VerticalDivider(
                  color: AppColors.borderLight,
                  thickness: 1.5,
                  width: 1,
                ),
              )),
            ),
          
          // Main Content
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  _buildAvatar(isExpert: effectiveIsExpert, isClinician: effectiveIsClinician, size: depth > 0 ? 28 : 34),
                  const SizedBox(width: 10),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        _buildHeader(context, isExpert: effectiveIsExpert, isClinician: effectiveIsClinician),
                        const SizedBox(height: 2),
                        
                        // Body
                        Text(
                          text,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: depth > 0 ? 13 : 14,
                            height: 1.4,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        // Actions
                        const SizedBox(height: 4),
                        _buildFooterActions(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isExpert, required bool isClinician, required double size}) {
    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isExpert 
                ? AppColors.success.withOpacity(0.1)
                : AppColors.backgroundElevated,
            shape: BoxShape.circle,
            border: isExpert ? Border.all(color: isClinician ? AppColors.success : AppColors.accentPrimary, width: 1) : null,
          ),
          child: Icon(
            roleIcon, 
            size: size * 0.5, 
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
              padding: const EdgeInsets.all(1.5),
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 8,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, {required bool isExpert, required bool isClinician}) {
    return Row(
      children: [
        Text(
          authorName,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: depth > 0 ? 12 : 13,
            color: isExpert 
                ? (isClinician ? AppColors.success : AppColors.accentPrimary)
                : AppColors.textPrimary,
          ),
        ),
        if (isExpert) ...[
          const SizedBox(width: 4),
          Text(
            '•',
            style: TextStyle(color: AppColors.textTertiary, fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            authorRoleLabel ?? 'Expert',
            style: AppTextStyles.caption.copyWith(
              fontSize: depth > 0 ? 9 : 10,
              color: isClinician ? AppColors.success : AppColors.accentPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        const Spacer(),
        Text(
          _formatTime(createdAt),
          style: AppTextStyles.caption.copyWith(
            fontSize: 9,
            color: AppColors.textTertiary
          ),
        ),
        if (currentUserId == authorId) ...[
          const SizedBox(width: 4),
          _buildCommentActions(context),
        ],
      ],
    );
  }

  Widget _buildFooterActions() {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                size: 13,
                color: isLiked ? Colors.red : AppColors.textTertiary,
              ),
              if (likeCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  likeCount.toString(),
                  style: AppTextStyles.caption.copyWith(
                    color: isLiked ? Colors.red : AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 16),
        GestureDetector(
          onTap: onReply,
          behavior: HitTestBehavior.opaque,
          child: Text(
            'Reply',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ),
      ],
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
