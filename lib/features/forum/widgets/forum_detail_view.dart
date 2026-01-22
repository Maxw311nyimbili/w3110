// lib/features/forum/widgets/forum_detail_view.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/general_comments_view.dart';
import 'package:cap_project/features/forum/widgets/line_comments_filtered_view.dart';
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
        return Column(
          children: [
            // Back Button Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () => context.read<ForumCubit>().backToList(),
                  ),
                  Text(
                    'Post Details',
                    style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_horiz_rounded),
                    onPressed: () {}, // Handle post actions
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Author Info
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.accentPrimary.withOpacity(0.1),
                          child: Text(
                            post.authorName.isNotEmpty ? post.authorName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatTime(post.createdAt),
                              style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      post.title,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Instruction for line selection
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.accentPrimary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tap any sentence to join the discussion on that specific point.',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.accentPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Content with Line-Level Discussion
                    _buildInteractiveContent(context, state),
                    
                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Sources Section
                    if (post.sources.isNotEmpty) ...[
                      Text(
                        'Sources & References',
                        style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: post.sources.map((source) => _buildSourceCard(source)).toList(),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                    
                    // Engagement Metrics
                    Row(
                      children: [
                        _buildAction(
                          context,
                          post.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          post.likeCount.toString(),
                          isActive: post.isLiked,
                          onTap: () => context.read<ForumCubit>().togglePostLike(post.id),
                        ),
                        const SizedBox(width: 24),
                        _buildAction(
                          context,
                          Icons.chat_bubble_outline_rounded,
                          post.commentCount.toString(),
                          onTap: () => _showGeneralCommentsModal(context),
                        ),
                        const SizedBox(width: 24),
                        _buildAction(
                          context,
                          Icons.visibility_outlined,
                          '${post.viewCount} views',
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInteractiveContent(BuildContext context, ForumState state) {
    if (state.answerLines.isEmpty) {
      return Text(
        post.content,
        style: AppTextStyles.bodyLarge.copyWith(height: 1.6),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.answerLines.map((line) {
        final isSelected = state.selectedLineId == line.lineId;
        
        return GestureDetector(
          onTap: () => context.read<ForumCubit>().toggleLineSelection(line.lineId),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.accentPrimary.withOpacity(0.08) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.6,
                      color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                    ),
                    children: [
                      TextSpan(text: line.text),
                    ],
                  ),
                ),
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: InkWell(
                      onTap: () => _showLineCommentsModal(context, line),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.accentPrimary),
                          const SizedBox(width: 4),
                          Text(
                            '${line.commentCount} discussion threads',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 14, color: AppColors.accentPrimary),
                        ],
                      ),
                    ),
                  ),
              ],
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
        width: 200,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              source.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelMedium.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.link_rounded, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    Uri.parse(source.url).host,
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
            size: 20,
            color: isActive ? Colors.pink : AppColors.textTertiary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? Colors.pink : AppColors.textTertiary,
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
