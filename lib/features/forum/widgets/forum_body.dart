// lib/features/forum/widgets/forum_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'post_card.dart';
import 'comment_list_item.dart';
import 'comment_input.dart';

/// Main forum body - switches between list view and detail view
class ForumBody extends StatelessWidget {
  const ForumBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumCubit, ForumState>(
      listener: (context, state) {
        // Show errors
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<ForumCubit>().clearError();
        }
      },
      child: BlocBuilder<ForumCubit, ForumState>(
        builder: (context, state) {
          // Switch between list and detail view
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
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!state.hasPosts) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<ForumCubit>().syncWithBackend(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
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
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'No posts yet',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Be the first to start a discussion',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
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
        // Post content + comments
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Post header
                _buildPostHeader(context, state.selectedPost!),

                const Divider(height: 1),

                // Comments section
                if (state.isLoading && !state.hasComments)
                  const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (!state.hasComments)
                  _buildNoComments(context)
                else
                  _buildCommentsList(context, state),
              ],
            ),
          ),
        ),

        // Comment input
        const CommentInput(),
      ],
    );
  }

  Widget _buildPostHeader(BuildContext context, ForumPost post) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author and timestamp
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.accentPrimary,
                child: Text(
                  post.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.authorName,
                      style: AppTextStyles.labelLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _formatTimestamp(post.createdAt),
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ),
              // Sync indicator
              if (post.isPendingSync)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Syncing...',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Title
          Text(
            post.title,
            style: AppTextStyles.headlineLarge,
          ),

          const SizedBox(height: AppSpacing.md),

          // Content
          Text(
            post.content,
            style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Post stats
          Row(
            children: [
              Icon(
                Icons.comment_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.commentCount}',
                style: AppTextStyles.labelMedium,
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(
                Icons.favorite_outline,
                size: 18,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '${post.likeCount}',
                style: AppTextStyles.labelMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, ForumState state) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: state.comments.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        return CommentListItem(comment: state.comments[index]);
      },
    );
  }

  Widget _buildNoComments(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No comments yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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