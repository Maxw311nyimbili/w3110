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
                style: AppTextStyles.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: AppColors.textPrimary,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 16),
              
              // Author Info (Byline style)
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.accentPrimary.withOpacity(0.08),
                    child: Text(
                      post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
                        style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
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
                  children: post.tags.map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$tag',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )).toList(),
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
              _buildInteractiveContent(context, state),
              
              const SizedBox(height: 48),
              
              // Sources Section
              if (post.sources.isNotEmpty) ...[
                Text(
                  'Sources',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: post.sources.map((source) => _buildSourceCard(source)).toList(),
                  ),
                ),
                const SizedBox(height: 40),
              ],

              // Related Discussions
              Builder(
                builder: (context) {
                  // Safe handling: filter posts that share tags, exclude current
                  final relatedPosts = state.displayPosts.where((p) {
                    if (p.id == post.id) return false;
                    return p.tags.any((t) => post.tags.contains(t));
                  }).take(3).toList();

                  if (relatedPosts.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Related Discussions',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 16),
                      ...relatedPosts.map((related) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => context.read<ForumCubit>().selectPost(related),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.borderLight),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        related.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        related.content,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textTertiary),
                              ],
                            ),
                          ),
                        ),
                      )),
                      const SizedBox(height: 40),
                    ],
                  );
                }
              ),

              const Divider(color: AppColors.borderLight),
              const SizedBox(height: 24),
              
              // Engagement Metrics (Bottom)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildAction(
                        context,
                        post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        post.likeCount.toString(),
                        isActive: post.isLiked,
                        onTap: () {
                          final authStatus = context.read<AuthCubit>().state.status;
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
        style: AppTextStyles.bodyLarge.copyWith(
          height: 1.8,
          fontSize: 17,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.answerLines.map((line) {
        final isSelected = state.selectedLineId == line.lineId;
        final hasExpertActivity = line.commentCount > 0;
        
        return GestureDetector(
          onTap: () => context.read<ForumCubit>().toggleLineSelection(line.lineId),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: state.selectedLineId != null && !isSelected ? 0.4 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutQuart,
              margin: const EdgeInsets.only(bottom: 4),
              padding: EdgeInsets.fromLTRB(isSelected ? 16 : 0, 8, 12, 8),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.backgroundSurface
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: Border(
                  left: BorderSide(
                    color: isSelected 
                        ? AppColors.accentPrimary 
                        : (hasExpertActivity ? AppColors.success.withOpacity(0.4) : Colors.transparent),
                    width: isSelected ? 4 : 2,
                  ),
                ),
                boxShadow: const [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.bodyLarge.copyWith(
                              height: 1.8,
                              fontSize: 17,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              letterSpacing: isSelected ? -0.2 : 0,
                              color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                            ),
                            children: [
                              TextSpan(text: line.text),
                            ],
                          ),
                        ),
                      ),
                      if (hasExpertActivity && !isSelected)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, top: 4),
                          child: Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                            color: AppColors.success.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showLineCommentsModal(context, line),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.accentPrimary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.accentPrimary.withOpacity(0.1),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded, 
                                  size: 14, 
                                  color: AppColors.accentPrimary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  line.commentCount > 0 ? '${line.commentCount} expert insights' : 'Discuss line',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.accentPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (hasExpertActivity) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.verified, size: 12, color: AppColors.success),
                                const SizedBox(width: 4),
                                Text(
                                  'Expert Consensus',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.success,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSourceCard(ForumPostSource source) {
    return GestureDetector(
      onTap: () => _launchURL(source.url),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.link_rounded, size: 14, color: AppColors.accentPrimary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    Uri.parse(source.url).host.replaceAll('www.', ''),
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary, fontWeight: FontWeight.w600),
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
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction(
    BuildContext context, 
    IconData icon, 
    String label, 
    {bool isActive = false, VoidCallback? onTap}
  ) {
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
            style: AppTextStyles.labelLarge.copyWith(
              color: isActive ? AppColors.error : AppColors.textTertiary,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLineCommentsModal(BuildContext context, ForumAnswerLine line) {
    showModalBottomSheet(
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
