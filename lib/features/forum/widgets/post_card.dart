// lib/features/forum/widgets/post_card.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:forum_repository/forum_repository.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
  });

  final ForumPost post;
  final VoidCallback? onTap;

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Avatar + Name + Time
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: AppColors.backgroundPrimary,
                  child: Text(
                    post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  post.authorName,
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '•',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(post.createdAt),
                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Title
            Text(
              post.title,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            // Content Preview
            Text(
              post.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Footer: Actions
            Row(
              children: [
                _buildAction(
                  Icons.arrow_upward_rounded,
                  post.likeCount.toString(),
                  isActive: post.isLiked,
                ),
                const SizedBox(width: 16),
                _buildAction(
                  Icons.chat_bubble_outline_rounded,
                  post.commentCount.toString(),
                ),
                const Spacer(),
                if (post.syncStatus != 'synced')
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, {bool isActive = false}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.textPrimary : AppColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
