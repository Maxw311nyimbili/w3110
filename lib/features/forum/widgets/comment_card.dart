// lib/features/forum/widgets/comment_card.dart

import 'package:cap_project/features/forum/widgets/thread_line_painter.dart';
import 'package:flutter/material.dart';

class CommentCard extends StatelessWidget {
  const CommentCard({
    super.key,
    required this.authorName,
    required this.authorId,
    required this.text,
    required this.createdAt,
    required this.onReply,
    required this.onLike,
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
    this.isLastChild = false,
    this.hasReplies = false,
    this.isExpanded = true,
    this.onExpand,
    this.replyCount = 0,
  });

  final String authorName;
  final String authorId;
  final String text;
  final DateTime createdAt;
  final VoidCallback onReply;
  final VoidCallback onLike;
  final int likeCount;
  final bool isLiked;
  final String? authorRoleLabel;
  final String? profession;
  final bool isExpert;
  final bool isClinician;
  final IconData roleIcon;
  final String? typeLabel;
  final String? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final int depth;
  final bool isLastChild;
  final bool hasReplies;
  final bool isExpanded;
  final VoidCallback? onExpand;
  final int replyCount;

  @override
  Widget build(BuildContext context) {
    final isOwnComment = currentUserId == authorId;
    const double indentWidth = 24.0;
    const double parentPadding = 12.0;

    return IntrinsicHeight(
      child: Padding(
        padding: EdgeInsets.only(
          left: depth > 0 ? 0 : parentPadding, 
          right: parentPadding, 
          top: 4, 
          bottom: 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Indentation area with Curved Lines
            if (depth > 0)
              SizedBox(
                width: depth * indentWidth,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: SizedBox(
                        width: depth * indentWidth,
                        child: CustomPaint(
                          painter: ThreadLinePainter(
                            lineColor: Theme.of(context).dividerColor.withOpacity(0.2),
                            isLastChild: isLastChild,
                            paddingLeft: 0,
                            depth: depth,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
  
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      _buildAvatar(context),
                      const SizedBox(width: 10),
                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, isOwnComment),
                            const SizedBox(height: 1),
                            Text(
                              text,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                                height: 1.4,
                                fontSize: depth > 0 ? 14 : 15,
                              ),
                            ),
                            const SizedBox(height: 5),
                            _buildActions(context),
                            
                            // "View More" for collapsed threads (Instagram Style)
                            // "Hide replies" button is now handled by the parent view at the end of the thread
                            if (hasReplies && !isExpanded && onExpand != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8, bottom: 4),
                                child: InkWell(
                                  onTap: onExpand,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 18,
                                        height: 1.2,
                                        color: Theme.of(context).dividerColor.withOpacity(0.2),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'View $replyCount more replies',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    final double size = depth > 0 ? 24 : 34;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          roleIcon,
          size: size * 0.55,
          color: isExpert
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.labelSmall?.color,
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isOwnComment) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                authorName,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: depth > 0 ? 13 : 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              if (isExpert)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withAlpha(77),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    authorRoleLabel ?? 'Expert',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                      fontSize: 8,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              Text(
                '• ${_formatTime(createdAt)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        if (isOwnComment)
          _buildMenu(context),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_horiz_rounded,
        size: 18,
        color: Theme.of(context).textTheme.labelSmall?.color,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete') onDelete?.call();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Text('Edit'),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onLike,
          child: Row(
            children: [
              Icon(
                isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 15,
                color: isLiked ? Colors.red : Theme.of(context).textTheme.bodySmall?.color,
              ),
              if (likeCount > 0) ...[
                const SizedBox(width: 4),
                Text(
                  likeCount.toString(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: onReply,
          child: Text(
            'Reply',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).textTheme.bodySmall?.color,
              fontWeight: FontWeight.w800,
              fontSize: 11,
            ),
          ),
        ),
        if (typeLabel != null) ...[
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
            ),
            child: Text(
              typeLabel!.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).textTheme.labelSmall?.color,
                fontSize: 8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}
