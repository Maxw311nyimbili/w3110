import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';
import '../cubit/forum_cubit.dart';
import '../cubit/forum_cubit.dart';

class CommentListItem extends StatelessWidget {
  const CommentListItem({
    required this.comment,
    super.key,
  });

  final ForumComment comment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                comment.authorName.isNotEmpty
                    ? comment.authorName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTimestamp(comment.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const Spacer(),
                    if (comment.isPendingSync)
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 14,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                // Comment text
                Text(
                  comment.content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                // Like action for comment
                GestureDetector(
                  onTap: () => context.read<ForumCubit>().toggleCommentLike(
                    comment.id,
                    isLineComment: false,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        comment.isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        size: 16,
                        color: comment.isLiked
                            ? Colors.pink
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        comment.likeCount.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: comment.isLiked
                              ? Colors.pink
                              : Theme.of(context).textTheme.bodySmall?.color,
                          fontWeight: comment.isLiked
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
