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

class GeneralCommentsView extends StatelessWidget {
  final ForumPost post;

  const GeneralCommentsView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.backgroundSurface,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ========== HEADER ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Discussion',
                              style: AppTextStyles.headlineSmall.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
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
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded, 
                                  size: 32, // Reduced from 48
                                  color: AppColors.borderMedium,
                                ),
                                const SizedBox(height: 8), // Reduced from 12
                                Text(
                                  'No discussions yet',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                                const SizedBox(height: 4), // Reduced from 8
                                Text(
                                  'Tap below to start one',
                                  style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: _buildThreadedComments(context, comments),
                      );
                    },
                  ),
                ),

                // ========== REPLY INPUT ==========
                const Divider(height: 1, color: AppColors.borderLight),
                ReplyInputFieldForModal(
                  isGeneral: true,
                  postId: post.id,
                ), 
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildThreadedComments(BuildContext context, List<ForumComment> allComments) {
    // 1. Group by parentLocalId (backend returns parent_comment_id as string, which maps to localId)
    // We need to ensure we map properly.
    final Map<String?, List<ForumComment>> grouped = {};
    for (final comment in allComments) {
      // Backend's parent_comment_id now matches our localId (UUID or legacy ID string)
      final pid = comment.parentCommentId;
      grouped.containsKey(pid) ? grouped[pid]!.add(comment) : grouped[pid] = [comment];
    }

    // 2. Recursive builder
    List<Widget> buildTree(String? parentId, int depth) {
      final children = grouped[parentId] ?? [];
      children.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final List<Widget> items = [];
      for (final comment in children) {
        items.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<String>(
              future: context.read<ForumCubit>().getCurrentUserId(),
              builder: (context, snapshot) {
                final userId = snapshot.data ?? '';
                final isClinician = comment.authorRole.toLowerCase().contains('clinician');
                final isExpert = isClinician || comment.authorRole.toLowerCase().contains('healthcare') || comment.authorRole.toLowerCase().contains('support');

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
                  onLike: () {
                    // Use id (preferring non-empty) for the like action, backend resolves both
                    final idToUse = comment.id.isNotEmpty ? comment.id : comment.localId;
                    context.read<ForumCubit>().toggleCommentLike(idToUse, isLineComment: false);
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
                  },
                  onEdit: () => _showEditCommentDialog(context, comment),
                  onDelete: () => _showDeleteCommentDialog(context, comment.localId),
                );
              },
            ),
          ),
        );

        if (depth == 0) {
          items.add(const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.borderLight));
        }

        // Recursive call using the current comment's localId as the parentId for children
        items.addAll(buildTree(comment.localId, depth + 1));
      }
      return items;
    }

    // Root level comments have parentId == null (or possibly empty/0 strings from legacy)
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
