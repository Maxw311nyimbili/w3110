// lib/features/forum/widgets/forum_body.dart
// PREMIUM DESIGN - Uses App Theme & Colors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'post_card.dart';
import 'comment_list_item.dart';
import 'comment_input.dart';

class ForumBody extends StatelessWidget {
  const ForumBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumCubit, ForumState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.read<ForumCubit>().clearError();
        }
      },
      child: BlocBuilder<ForumCubit, ForumState>(
        builder: (context, state) {
          if (state.view == ForumView.detail) {
            return _buildDetailView(context, state);
          }
          return _buildListView(context, state);
        },
      ),
    );
  }

  // ============================================================
  // LIST VIEW - All posts
  // ============================================================
  Widget _buildListView(BuildContext context, ForumState state) {
    if (state.isLoading && !state.hasPosts) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.accentPrimary,
          ),
        ),
      );
    }

    if (!state.hasPosts) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ForumCubit>().syncWithBackend(),
      color: AppColors.accentPrimary,
      backgroundColor: AppColors.backgroundSurface,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return PostCard(
            post: post,
            onTap: () => context.read<ForumCubit>().selectPost(post),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.forum_outlined,
                size: 32,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No posts yet',
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start a discussion',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DETAIL VIEW - Single post with comments
  // ============================================================
  Widget _buildDetailView(BuildContext context, ForumState state) {
    if (state.selectedPost == null) {
      return const Center(child: Text('Post not found'));
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPostHeader(context, state.selectedPost!),
                Divider(
                  height: 1,
                  color: AppColors.gray200,
                ),
                if (state.isLoading && !state.hasComments)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentPrimary,
                        ),
                      ),
                    ),
                  )
                else if (!state.hasComments)
                  _buildNoComments(context)
                else
                  _buildCommentsList(context, state),
              ],
            ),
          ),
        ),
        const CommentInput(),
      ],
    );
  }

  Widget _buildPostHeader(BuildContext context, ForumPost post) {
    return Container(
      color: AppColors.backgroundSurface,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    post.authorName[0].toUpperCase(),
                    style: TextStyle(
                      color: AppColors.accentPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _formatTimestamp(post.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (post.isPendingSync)
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 18,
                  color: AppColors.warning,
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          Text(
            post.title,
            style: AppTextStyles.displayMedium.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          // Content
          Text(
            post.content,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 16),

          // Stats
          Row(
            children: [
              _buildStatBadge(Icons.comment_outlined, post.commentCount),
              const SizedBox(width: 16),
              _buildStatBadge(Icons.favorite_outline, post.likeCount),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBadge(IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, ForumState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: state.comments.length,
      separatorBuilder: (context, index) => Divider(
        height: 20,
        color: AppColors.gray200,
      ),
      itemBuilder: (context, index) {
        return CommentListItem(comment: state.comments[index]);
      },
    );
  }

  Widget _buildNoComments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 28,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No comments yet',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Be the first to comment',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
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