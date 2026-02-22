import 'package:flutter/material.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:forum_repository/forum_repository.dart';

/// Thread Summary Header
/// Shows consensus, expert highlights, and helps navigate deep discussions
class ThreadSummaryHeader extends StatelessWidget {
  final ForumPost post;
  final List<ForumComment> comments;
  final VoidCallback? onJumpToExperts;

  const ThreadSummaryHeader({
    required this.post,
    required this.comments,
    this.onJumpToExperts,
    super.key,
  });

  /// Count expert responses
  int get expertCount => comments
      .where(
        (c) =>
            c.authorRole == 'clinician' ||
            c.authorRole == 'doctor' ||
            c.authorRole == 'healthcare_professional',
      )
      .length;

  /// Calculate consensus from comment sentiment
  String _getConsensus() {
    final experts = comments
        .where(
          (c) =>
              c.authorRole == 'clinician' ||
              c.authorRole == 'doctor' ||
              c.authorRole == 'healthcare_professional',
        )
        .toList();

    if (comments.isEmpty) return 'Awaiting community insights';
    if (experts.isEmpty) return 'Active community discussion in progress';

    if (experts.length >= 3) {
      return 'Broad expert consensus established';
    } else if (experts.length >= 1) {
      return 'Expert clinical perspectives available';
    }

    return 'Consensus forming among members';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.accentPrimary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.accentPrimary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accentPrimary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${comments.length} responses',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (expertCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.success.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified,
                        size: 12,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$expertCount expert',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Consensus line
          Text(
            _getConsensus(),
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          // CTA: Jump to experts button
          if (expertCount > 0 && onJumpToExperts != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onJumpToExperts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.arrow_downward, size: 16),
                label: Text(
                  'See expert responses',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Expert Comment Highlight
/// Shows important expert responses prominently
class ExpertCommentHighlight extends StatelessWidget {
  final ForumComment comment;
  final int index;

  const ExpertCommentHighlight({
    required this.comment,
    required this.index,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expert badge
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.verified,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment.authorName,
                      style: AppTextStyles.labelMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (comment.authorProfession != null)
                      Text(
                        comment.authorProfession!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Comment text
          Text(
            comment.text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.5,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thread Depth Indicator
/// Shows user where they are in deep discussions
class ThreadDepthIndicator extends StatelessWidget {
  final int totalComments;
  final int currentPosition;

  const ThreadDepthIndicator({
    required this.totalComments,
    required this.currentPosition,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalComments > 0 ? currentPosition / totalComments : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Discussion depth',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '$currentPosition of $totalComments',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppColors.accentPrimary.withOpacity(0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Smart Comment Grouping
/// Groups comments by theme to reduce cognitive load
class CommentGroupHeader extends StatelessWidget {
  final String theme; // e.g., "Safety Concerns", "Alternative Treatments", etc.
  final int commentCount;
  final bool isExpanded;
  final VoidCallback onTap;

  const CommentGroupHeader({
    required this.theme,
    required this.commentCount,
    required this.isExpanded,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.backgroundElevated,
          border: Border(
            bottom: BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.accentPrimary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                theme,
                style: AppTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$commentCount',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
