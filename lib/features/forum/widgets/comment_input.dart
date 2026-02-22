// lib/features/forum/widgets/comment_input.dart
// PREMIUM DESIGN - Uses App Theme & Colors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';

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

    final forumState = context.read<ForumCubit>().state;
    final authState = context.read<AuthCubit>().state;

    if (forumState.selectedPost == null) return;

    final content = _controller.text.trim();

    if (!authState.isAuthenticated || authState.user == null) {
      bool isDebugMode = false;
      assert(() {
        isDebugMode = true;
        return true;
      }());

      if (!isDebugMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to comment')),
        );
        return;
      }

      context.read<ForumCubit>().addComment(
        postId: forumState.selectedPost!.id.isEmpty
            ? forumState.selectedPost!.localId
            : forumState.selectedPost!.id,
        content: content,
        authorId: 'debug_user_${DateTime.now().millisecondsSinceEpoch}',
        authorName: '[DEBUG] Test User',
      );
    } else {
      final user = authState.user!;

      context.read<ForumCubit>().addComment(
        postId: forumState.selectedPost!.id.isEmpty
            ? forumState.selectedPost!.localId
            : forumState.selectedPost!.id,
        content: content,
        authorId: user.id,
        authorName: user.displayName ?? user.email,
      );
    }

    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSurface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 100),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    textInputAction: TextInputAction.newline,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: TextStyle(
                        fontSize: 15,
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Send button
              GestureDetector(
                onTap: _hasText ? _sendComment : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _hasText
                        ? AppColors.accentPrimary
                        : AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_upward,
                    color: _hasText ? Colors.white : AppColors.textTertiary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
