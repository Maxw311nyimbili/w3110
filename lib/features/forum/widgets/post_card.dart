import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';

class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.currentUserId,
  });

  final ForumPost post;
  final VoidCallback? onTap;
  final String? currentUserId;

  String _formatTime(DateTime time) {
    final difference = DateTime.now().difference(time);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _PressableScale(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Clean Byline
            Row(
              children: [
                _buildAuthorAvatar(context, post.authorName),
                const SizedBox(width: 10),
                Text(
                  post.authorName,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 3,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(post.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                if (currentUserId == post.authorId) _buildActions(context),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              post.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
            ),
            const SizedBox(height: 8),

            // Content Preview
            Text(
              post.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
            ),

            // Footer: Tags and Comments Count
            const SizedBox(height: 16),
            Row(
              children: [
                if (post.tags.isNotEmpty)
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: post.tags
                            .map((tag) => _buildTag(context, tag))
                            .toList(),
                      ),
                    ),
                  ),
                if (post.commentCount > 0) ...[
                  const SizedBox(width: 12),
                  _buildStat(
                    context,
                    Icons.chat_bubble_outline_rounded,
                    post.commentCount.toString(),
                  ),
                ],
                const SizedBox(width: 12),
                _buildStat(
                  context,
                  post.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  post.likeCount.toString(),
                  color: post.isLiked
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorAvatar(BuildContext context, String name) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.1)),
      ),
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: Theme.of(context).textTheme.bodySmall?.color,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          _showEditDialog(context);
        } else if (value == 'delete') {
          _showDeleteDialog(context);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 18, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: post.title);
    final contentController = TextEditingController(text: post.content);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              minLines: 3,
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ForumCubit>().updatePost(
                localId: post.localId,
                title: titleController.text,
                content: contentController.text,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ForumCubit>().deletePost(post.localId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String tag) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.05)),
      ),
      child: Text(
        '#$tag',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
      ),
    );
  }

  Widget _buildStat(BuildContext context, IconData icon, String value, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color ?? Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}

class _PressableScale extends StatefulWidget {
  const _PressableScale({required this.child, this.onTap});
  final Widget child;
  final VoidCallback? onTap;

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
