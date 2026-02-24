// lib/features/forum/widgets/line_comments_filtered_view.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import 'package:forum_repository/forum_repository.dart';
import 'comment_card.dart';
import 'reply_input_field_for_modal.dart';

class LineCommentsFilteredView extends StatefulWidget {
  final String lineId;
  final int lineNumber;

  const LineCommentsFilteredView({
    super.key,
    required this.lineId,
    required this.lineNumber,
  });

  @override
  State<LineCommentsFilteredView> createState() =>
      _LineCommentsFilteredViewState();
}

class _LineCommentsFilteredViewState extends State<LineCommentsFilteredView> {
  final Set<String> _expandedCommentIds = {};

  void _toggleExpanded(String commentId) {
    setState(() {
      if (_expandedCommentIds.contains(commentId)) {
        _expandedCommentIds.remove(commentId);
      } else {
        _expandedCommentIds.add(commentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ========== HEADER ==========
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 12, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Discussion',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: Theme.of(context).textTheme.headlineMedium?.color,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceVariant,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),

                // ========== SCROLLABLE CONTENT ==========
                Expanded(
                  child: BlocBuilder<ForumCubit, ForumState>(
                    builder: (context, state) {
                      if (state.isLoading && state.lineComments.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final comments = state.lineComments;
                      final lineText = state.getLineText(widget.lineId);

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          // 1. Quoted Line (Scrolls away)
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.format_quote_rounded,
                                      size: 18,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Line ${widget.lineNumber}',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).textTheme.bodySmall?.color,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ).copyWith(fontSize: 10),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  lineText,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    height: 1.5,
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Divider(
                            height: 1,
                            color: Theme.of(context).dividerColor.withOpacity(0.1),
                          ),

                          // 3. Comments List
                          if (comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chat_bubble_outline_rounded,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                  ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Help figure this out',
                                    style: AppTextStyles.headlineSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'No perspectives shared for this line yet.',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._buildThreadedComments(context, comments),
                        ],
                      );
                    },
                  ),
                ),

                // ========== FIXED REPLY INPUT ==========
                Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ReplyInputFieldForModal(lineId: widget.lineId),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThreadedComments(
    BuildContext context,
    List<ForumLineComment> allComments,
  ) {
    final Map<String?, List<ForumLineComment>> grouped = {};
    for (final comment in allComments) {
      final pid = comment.parentCommentId;
      grouped.containsKey(pid)
          ? grouped[pid]!.add(comment)
          : grouped[pid] = [comment];
    }

    List<Widget> buildTree(String? parentId, int depth) {
      final children = grouped[parentId] ?? [];
      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final List<Widget> items = [];
      for (int i = 0; i < children.length; i++) {
        final comment = children[i];
        final isLast = i == children.length - 1;
        final hasReplies = grouped.containsKey(comment.localId);
        final isExpanded = _expandedCommentIds.contains(comment.localId);
        final replyCount = grouped[comment.localId]?.length ?? 0;

        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FutureBuilder<String>(
              future: context.read<ForumCubit>().getCurrentUserId(),
              builder: (context, snapshot) {
                final userId = snapshot.data ?? '';
                return CommentCard(
                  authorName: comment.authorName,
                  text: comment.text,
                  createdAt: comment.createdAt,
                  likeCount: comment.likeCount,
                  isLiked: comment.isLiked,
                  authorId: comment.authorId,
                  currentUserId: userId,
                  depth: depth,
                  isExpert:
                      comment.authorRole == CommentRole.clinician ||
                      comment.authorRole == CommentRole.supportPartner,
                  isClinician: comment.authorRole == CommentRole.clinician,
                  profession: comment.authorProfession,
                  typeLabel: comment.typeLabel,
                  roleIcon: _getRoleIcon(comment.authorRole),
                  isLastChild: isLast,
                  hasReplies: hasReplies,
                  isExpanded: isExpanded,
                  replyCount: replyCount,
                  onExpand: () => _toggleExpanded(comment.localId),
                  onLike: () {
                    context.read<ForumCubit>().toggleCommentLike(
                      comment.id,
                      isLineComment: true,
                    );
                  },
                  onReply: () {
                    context.read<ForumCubit>().setReplyingTo(
                      ForumReplyTarget(
                        id: comment.id,
                        localId: comment.localId,
                        authorName: comment.authorName,
                        isLineComment: true,
                      ),
                    );
                    if (!isExpanded) _toggleExpanded(comment.localId);
                  },
                  onEdit: () => _showEditCommentDialog(context, comment),
                  onDelete: () =>
                      _showDeleteCommentDialog(context, comment.localId),
                );
              },
            ),
          ),
        );

        if (isExpanded) {
          items.addAll(buildTree(comment.localId, depth + 1));

          // After all children are built, add the "Hide replies" button at the END
          if (hasReplies) {
            // Match the horizontal alignment of the parent comment's text
            final double basePadding = 16.0;
            final double cardPadding = depth > 0 ? 0.0 : 12.0;
            final double avatarArea = depth > 0 ? 34.0 : 44.0;
            final double totalIndent = depth * 24.0;

            items.add(
              Padding(
                padding: EdgeInsets.only(
                  left: basePadding + cardPadding + totalIndent + avatarArea,
                  top: 4,
                  bottom: 12,
                ),
                child: InkWell(
                  onTap: () => _toggleExpanded(comment.localId),
                  child: Row(
                    children: [
                      Container(
                        width: 18,
                        height: 1.2,
                        color: AppColors.borderMedium,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hide replies',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }

        if (depth == 0 && !isLast) {
          items.add(
            const Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.borderLight,
            ),
          );
        }
      }
      return items;
    }

    return buildTree(null, 0);
  }

  IconData _getRoleIcon(CommentRole role) {
    switch (role) {
      case CommentRole.clinician:
        return Icons.local_hospital_outlined;
      case CommentRole.mother:
        return Icons.face_4_outlined;
      case CommentRole.community:
        return Icons.person_outline;
      case CommentRole.supportPartner:
        return Icons.handshake_outlined;
      default:
        return Icons.chat_bubble_outline_rounded;
    }
  }

  void _showEditCommentDialog(BuildContext context, ForumLineComment comment) {
    final controller = TextEditingController(text: comment.text);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your comment...'),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ForumCubit>().updateLineComment(
                localId: comment.localId,
                serverId: comment.id,
                text: controller.text,
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCommentDialog(BuildContext context, String localId) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<ForumCubit>().deleteLineComment(localId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
