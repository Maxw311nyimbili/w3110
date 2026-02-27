// lib/features/forum/widgets/forum_detail_view.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/general_comments_view.dart';
import 'package:cap_project/features/forum/widgets/line_comments_filtered_view.dart';
import 'package:cap_project/features/forum/widgets/thread_summary_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class ForumDetailView extends StatelessWidget {
  const ForumDetailView({super.key, required this.post});

  final ForumPost post;

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

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              // Title
              Text(
                post.title,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 16),

              // Author Info (Byline style)
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    child: Text(
                      post.authorName.isNotEmpty
                          ? post.authorName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              // Tags
              if (post.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: post.tags
                      .map(
                        (tag) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$tag',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
              const SizedBox(height: 24),

              // Thread Summary Header - Shows consensus, expert count, and depth
              ThreadSummaryHeader(
                post: post,
                comments: state.displayComments,
              ),
              const SizedBox(height: 24),

              // Content with Line-Level Discussion
              if (state.answerLines.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.touch_app_outlined,
                        size: 14,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Tap a sentence to discuss',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              _buildInteractiveContent(context, state),

              const SizedBox(height: 48),

              // Sources Section
              if (post.sources.isNotEmpty) ...[
                Text(
                  'Sources',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: post.sources
                        .map((source) => _buildSourceCard(context, source))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // Related Discussions
              Builder(
                builder: (context) {
                  // Safe handling: filter posts that share tags, exclude current
                  final relatedPosts = state.displayPosts
                      .where((p) {
                        if (p.id == post.id) return false;
                        return p.tags.any((t) => post.tags.contains(t));
                      })
                      .take(3)
                      .toList();

                  if (relatedPosts.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Related Discussions',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...relatedPosts.map(
                        (related) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () =>
                                context.read<ForumCubit>().selectPost(related),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(context).dividerColor.withOpacity(0.1),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          related.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          related.content,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 14,
                                    color: AppColors.textTertiary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                },
              ),

              Divider(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              const SizedBox(height: 24),

              // Engagement Metrics (Bottom)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAction(
                        context,
                        post.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        post.likeCount.toString(),
                        isActive: post.isLiked,
                        onTap: () {
                          final authStatus = context
                              .read<AuthCubit>()
                              .state
                              .status;
                          if (authStatus != AuthStatus.authenticated) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please log in to like posts'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }
                          context.read<ForumCubit>().togglePostLike(post.id);
                        },
                      ),
                      const SizedBox(width: 24),
                      _buildAction(
                        context,
                        Icons.chat_bubble_outline_rounded,
                        post.commentCount.toString(),
                        onTap: () => _showGeneralCommentsModal(context),
                      ),
                    ],
                  ),
                  _buildAction(
                    context,
                    Icons.visibility_outlined,
                    '${post.viewCount} views',
                  ),
                ],
              ),
              const SizedBox(height: 60),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInteractiveContent(BuildContext context, ForumState state) {
    if (state.answerLines.isEmpty) {
      return Text(
        post.content,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          height: 1.8,
          fontSize: 17,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.answerLines.map((line) {
        final isSelected = state.selectedLineId == line.lineId;
        final hasExpertActivity = line.commentCount > 0;

        return GestureDetector(
          onTap: () =>
              context.read<ForumCubit>().toggleLineSelection(line.lineId),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: isSelected
                ? InkWell(
                    onTap: () => _showLineCommentsModal(context, line),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.accentLight
                              : AppColors.borderDark,
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text content
                          Text(
                            line.text,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              height: 1.7,
                              fontSize: 16.5,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Comment icon and count in bottom-left
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 14,
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${line.commentCount}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          line.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.7,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      if (hasExpertActivity)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 14,
                                color: AppColors.success,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${line.commentCount}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.success,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSourceCard(BuildContext context, ForumPostSource source) {
    return GestureDetector(
      onTap: () => _launchURL(source.url),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.borderMedium.withOpacity(0.5)
                : AppColors.borderDark,
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.link_rounded,
                  size: 14,
                  color: AppColors.accentPrimary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    Uri.parse(source.url).host.replaceAll('www.', ''),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              source.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context,
    IconData icon,
    String label, {
    bool isActive = false,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: isActive ? AppColors.error : AppColors.textTertiary,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: isActive ? Theme.of(context).colorScheme.error : Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLineCommentsModal(
    BuildContext context,
    ForumAnswerLine line,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ForumCubit>(),
        child: LineCommentsFilteredView(
          lineId: line.lineId,
          lineNumber: line.lineNumber,
        ),
      ),
    );

    // Refresh lines after modal closes to update comment counts from backend
    if (context.mounted) {
      final cubit = context.read<ForumCubit>();
      final serverPostId = int.tryParse(post.id);

      if (serverPostId != null) {
        // Re-select the post to refresh lines with updated counts
        await cubit.selectPost(post);
      }
    }
  }

  void _showGeneralCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<ForumCubit>(),
        child: GeneralCommentsView(post: post),
      ),
    );
  }
}
