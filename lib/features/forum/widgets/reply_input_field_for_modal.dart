// lib/features/forum/widgets/reply_input_field_for_modal.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import '../cubit/cubit.dart';
import 'package:forum_repository/forum_repository.dart';

class ReplyInputFieldForModal extends StatefulWidget {
  final String? lineId;
  final String? postId;
  final bool isGeneral;

  const ReplyInputFieldForModal({
    super.key,
    this.lineId,
    this.postId,
    this.isGeneral = false,
  });

  @override
  State<ReplyInputFieldForModal> createState() =>
      _ReplyInputFieldForModalState();
}

class _ReplyInputFieldForModalState extends State<ReplyInputFieldForModal> {
  late TextEditingController _textController;
  late ValueNotifier<String> _typeController;
  late FocusNode _focusNode;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _typeController = ValueNotifier('experience');
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _textController.dispose();
    _typeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handlePost() async {
    if (_textController.text.trim().isEmpty || _isPosting) return;

    setState(() => _isPosting = true);
    try {
      if (widget.isGeneral) {
        final authState = context.read<AuthCubit>().state;
        final forumState = context.read<ForumCubit>().state;
        final post = forumState.selectedPost!;

        await context.read<ForumCubit>().addComment(
          postId: post.id.isEmpty ? post.localId : post.id,
          content: _textController.text,
          authorId:
              authState.user?.id ??
              'guest_${DateTime.now().millisecondsSinceEpoch}',
          authorName: authState.user?.displayName ?? 'Guest',
          parentCommentId: forumState.replyingToComment?.localId,
        );
      } else {
        await context.read<ForumCubit>().postLineComment(
          text: _textController.text,
          commentType: _typeController.value,
          lineId: widget.lineId,
          parentCommentId: context
              .read<ForumCubit>()
              .state
              .replyingToComment
              ?.id,
        );
      }
      _textController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      // Error handling is managed by Cubit state
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForumCubit, ForumState>(
      listenWhen: (previous, current) =>
          previous.replyingToComment == null &&
          current.replyingToComment != null,
      listener: (context, state) {
        _focusNode.requestFocus();
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Replying To Banner
            BlocBuilder<ForumCubit, ForumState>(
              builder: (context, state) {
                if (state.replyingToComment == null)
                  return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentLight),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.reply_rounded,
                        size: 18,
                        color: AppColors.accentPrimary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            children: [
                              const TextSpan(text: 'Replying to '),
                              TextSpan(
                                text: state.replyingToComment!.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            context.read<ForumCubit>().clearReplyingTo(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Type Selection (Horizontal Pills) - Hide for general comments
            if (!widget.isGeneral) ...[
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: ValueListenableBuilder<String>(
                  valueListenable: _typeController,
                  builder: (context, selectedType, child) {
                    return Row(
                      children: [
                        _TypeChoiceChip(
                          label: 'Experience',
                          icon: Icons.face_4_outlined,
                          value: 'experience',
                          groupValue: selectedType,
                          onSelected: (val) => _typeController.value = val,
                        ),
                        const SizedBox(width: 8),
                        _TypeChoiceChip(
                          label: 'Clinical',
                          icon: Icons.local_hospital_outlined,
                          value: 'clinical',
                          groupValue: selectedType,
                          onSelected: (val) => _typeController.value = val,
                        ),
                        const SizedBox(width: 8),
                        _TypeChoiceChip(
                          label: 'Evidence',
                          icon: Icons.library_books_outlined,
                          value: 'evidence',
                          groupValue: selectedType,
                          onSelected: (val) => _typeController.value = val,
                        ),
                        const SizedBox(width: 8),
                        _TypeChoiceChip(
                          label: 'Concern',
                          icon: Icons.help_outline_rounded,
                          value: 'concern',
                          groupValue: selectedType,
                          onSelected: (val) => _typeController.value = val,
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Input Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadowWarm.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _textController,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 5,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                      decoration: InputDecoration(
                        hintText: widget.isGeneral
                            ? 'Add to the discussion...'
                            : 'Share your perspective...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Post Button
                _isPosting
                    ? const SizedBox(
                        width: 48,
                        height: 48,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentPrimary,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.accentPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentPrimary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_upward_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          onPressed: _handlePost,
                          padding: EdgeInsets.zero,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String groupValue;
  final ValueChanged<String> onSelected;

  const _TypeChoiceChip({
    required this.label,
    required this.icon,
    required this.value,
    required this.groupValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderMedium,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
