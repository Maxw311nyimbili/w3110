// lib/features/forum/widgets/general_comments_view.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';
import 'comment_card.dart';
import 'reply_input_field_for_modal.dart';

class GeneralCommentsView extends StatefulWidget {
  final ForumPost post;

  const GeneralCommentsView({super.key, required this.post});

  @override
  State<GeneralCommentsView> createState() => _GeneralCommentsViewState();
}

class _GeneralCommentsViewState extends State<GeneralCommentsView> {
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

                // ========== COMMENTS LIST ==========
                Expanded(
                  child: BlocBuilder<ForumCubit, ForumState>(
                    builder: (context, state) {
                      if (state.isLoading && state.comments.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final comments = state.comments;

                      if (comments.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
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
                                  'Be the first to speak',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Theme.of(context).textTheme.bodyLarge?.color,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start the conversation by adding a comment below.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: _buildThreadedComments(context, comments),
                      );
                    },
                  ),
                ),

                // ========== REPLY INPUT ==========
                Divider(height: 1, color: Theme.of(context).dividerColor.withOpacity(0.1)),
                ReplyInputFieldForModal(
                  isGeneral: true,
                  postId: widget.post.id,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThreadedComments(
    BuildContext context,
    List<ForumComment> allComments,
  ) {
    final Map<String, List<ForumComment>> grouped = {};
    for (final comment in allComments) {
      final pid = comment.parentCommentId;
      if (pid == null || pid.isEmpty) {
        grouped.putIfAbsent(null.toString(), () => []).add(comment);
      } else {
        grouped.putIfAbsent(pid, () => []).add(comment);
      }
    }

    List<Widget> buildTree(String? parentId, int depth) {
      // Try to find by the provided ID (could be server ID or local ID)
      final key = parentId ?? null.toString();
      final children = grouped[key] ?? [];
      
      // If we didn't find any children but we have a parentId, 
      // it's possible some children reference the localId while we were given the server id (or vice versa)
      if (children.isEmpty && parentId != null) {
        // Find the parent comment to get its sibling ID
        try {
          final parent = allComments.firstWhere((c) => c.id == parentId || c.localId == parentId);
          final alternativeId = (parent.id == parentId) ? parent.localId : parent.id;
          if (alternativeId.isNotEmpty) {
            final altChildren = grouped[alternativeId] ?? [];
            children.addAll(altChildren);
          }
        } catch (_) {}
      }
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
                final isClinician = comment.authorRole.toLowerCase().contains(
                  'clinician',
                );
                final isExpert =
                    isClinician ||
                    comment.authorRole.toLowerCase().contains('healthcare') ||
                    comment.authorRole.toLowerCase().contains('support');

                return CommentCard(
                  authorName: comment.authorName,
                  text: comment.content,
                  createdAt: comment.createdAt,
                  likeCount: comment.likeCount,
                  isLiked: comment.isLiked,
                  authorId: comment.authorId,
                  currentUserId: userId,
                  depth: depth,
                  isExpert: isExpert,
                  isClinician: isClinician,
                  profession: comment.authorProfession,
                  authorRoleLabel: comment.authorRole,
                  roleIcon: _getRoleIcon(comment.authorRole),
                  isLastChild: isLast,
                  hasReplies: hasReplies,
                  isExpanded: isExpanded,
                  replyCount: replyCount,
                  onExpand: () => _toggleExpanded(comment.localId),
                  onLike: () {
                    final idToUse = comment.id.isNotEmpty
                        ? comment.id
                        : comment.localId;
                    context.read<ForumCubit>().toggleCommentLike(
                      idToUse,
                      isLineComment: false,
                    );
                  },
                  onReply: () {
                    context.read<ForumCubit>().setReplyingTo(
                      ForumReplyTarget(
                        id: comment.id,
                        localId: comment.localId,
                        authorName: comment.authorName,
                        isLineComment: false,
                      ),
                    );
                    // Automatically expand if replying
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

  IconData _getRoleIcon(String role) {
    final r = role.toLowerCase();
    if (r.contains('clinician')) return Icons.local_hospital_outlined;
    if (r.contains('mother')) return Icons.face_4_outlined;
    if (r.contains('support')) return Icons.handshake_outlined;
    return Icons.person_outline;
  }

  void _showEditCommentDialog(BuildContext context, ForumComment comment) {
    final controller = TextEditingController(text: comment.content);
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
              context.read<ForumCubit>().updateComment(
                localId: comment.localId,
                serverId: comment.id,
                content: controller.text,
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
              context.read<ForumCubit>().deleteComment(localId);
              Navigator.pop(dialogContext);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
