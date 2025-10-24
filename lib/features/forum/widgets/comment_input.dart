// lib/features/forum/widgets/comment_input.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

/// Comment input field - add comments to posts
class CommentInput extends StatefulWidget {
  const CommentInput({super.key});

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _sendComment() {
    if (_controller.text.trim().isEmpty) return;

    final state = context.read<ForumCubit>().state;
    if (state.selectedPost == null) return;

    // TODO: Get actual user info from auth
    final content = _controller.text.trim();
    context.read<ForumCubit>().addComment(
      postId: state.selectedPost!.id.isEmpty
          ? state.selectedPost!.localId
          : state.selectedPost!.id,
      content: content,
      authorId: 'current_user_id', // TODO: From auth
      authorName: 'Current User', // TODO: From auth
    );

    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Text input field
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 100),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onSubmitted: (_) => _sendComment(),
                ),
              ),
            ),

            const SizedBox(width: AppSpacing.sm),

            // Send button
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              child: IconButton(
                onPressed: _hasText ? _sendComment : null,
                icon: Icon(
                  Icons.send,
                  color: _hasText ? AppColors.accentPrimary : AppColors.gray400,
                  size: 22,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _hasText
                      ? AppColors.accentLight
                      : AppColors.gray100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}