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
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
                // ========== HEADER ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              post.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline_rounded, 
                                size: 48, 
                                color: AppColors.gray300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Be the first to comment',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: comments.length,
                        separatorBuilder: (context, index) => const Divider(height: 24),
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          // Wrap ForumComment into ForumLineComment for CommentCard compatibility
                          // or update CommentCard to handle both. For now, we reuse CommentCard
                          // by adapting the data.
                          final lineComment = ForumLineComment(
                            id: comment.id,
                            lineId: 'general',
                            authorId: comment.authorId,
                            authorName: comment.authorName,
                            authorRole: CommentRole.community,
                            commentType: CommentType.experience,
                            text: comment.content,
                            createdAt: comment.createdAt,
                            syncStatus: comment.syncStatus,
                          );

                          return CommentCard(
                            comment: lineComment,
                            onReply: () {},
                          );
                        },
                      );
                    },
                  ),
                ),

                // ========== REPLY INPUT ==========
                const Divider(height: 1),
                _GeneralCommentInput(postId: post.id.isEmpty ? post.localId : post.id),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GeneralCommentInput extends StatefulWidget {
  final String postId;
  const _GeneralCommentInput({required this.postId});

  @override
  State<_GeneralCommentInput> createState() => _GeneralCommentInputState();
}

class _GeneralCommentInputState extends State<_GeneralCommentInput> {
  final _textController = TextEditingController();
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    if (_textController.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);
    
    try {
      // For general comments, we use the existing addComment method
      // We need authorId and authorName (usually from AuthCubit, but ForumCubit handles some of it)
      // In a real app, this should be fetched from state.
      await context.read<ForumCubit>().addComment(
        postId: widget.postId,
        content: _textController.text,
        authorId: 'me', // This should be dynamic
        authorName: 'You',
      );
      _textController.clear();
      FocusScope.of(context).unfocus();
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              minLines: 1,
              maxLines: 4,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: AppColors.gray300),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: AppColors.backgroundPrimary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _isPosting 
            ? const SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                icon: const Icon(Icons.send_rounded, color: AppColors.accentPrimary),
                onPressed: _handlePost,
              ),
        ],
      ),
    );
  }
}
