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

                      return ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderLight),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          // Adapt ForumComment to ForumLineComment for the card
                          final lineComment = ForumLineComment(
                            id: comment.id,
                            localId: comment.localId,
                            lineId: 'general',
                            authorId: comment.authorId,
                            authorName: comment.authorName,
                            authorRole: CommentRole.community, 
                            commentType: CommentType.general, // Correct type for post-level discussions
                            text: comment.content,
                            createdAt: comment.createdAt,
                            syncStatus: comment.syncStatus,
                          );

                          return FutureBuilder<String>(
                            future: context.read<ForumCubit>().getCurrentUserId(),
                            builder: (context, snapshot) {
                              final userId = snapshot.data ?? '';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: CommentCard(
                                  comment: lineComment,
                                  currentUserId: userId,
                                  onReply: () {},
                                  onEdit: () => _showEditCommentDialog(context, comment),
                                  onDelete: () => _showDeleteCommentDialog(context, comment.localId),
                                ),
                              );
                            },
                          );
                        },
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
