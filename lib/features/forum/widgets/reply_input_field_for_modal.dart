// lib/features/forum/widgets/reply_input_field_for_modal.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';

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
  State<ReplyInputFieldForModal> createState() => _ReplyInputFieldForModalState();
}

class _ReplyInputFieldForModalState extends State<ReplyInputFieldForModal> {
  late TextEditingController _textController;
  late ValueNotifier<String> _typeController;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _typeController = ValueNotifier('experience');
  }

  @override
  void dispose() {
    _textController.dispose();
    _typeController.dispose();
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
          authorId: authState.user?.id ?? 'guest_${DateTime.now().millisecondsSinceEpoch}',
          authorName: authState.user?.displayName ?? 'Guest',
        );
      } else {
        await context.read<ForumCubit>().postLineComment(
          text: _textController.text,
          commentType: _typeController.value,
          lineId: widget.lineId,
          parentCommentId: context.read<ForumCubit>().state.replyingToComment?.id,
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Replying To Banner
          BlocBuilder<ForumCubit, ForumState>(
            builder: (context, state) {
              if (state.replyingToComment == null) return const SizedBox.shrink();
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.backgroundElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.reply_rounded, size: 16, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Replying to ${state.replyingToComment!.authorName}',
                        style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textTertiary),
                      onPressed: () => context.read<ForumCubit>().clearReplyingTo(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
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
            const SizedBox(height: 12),
          ],

          // Input Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundElevated,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: 4,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: widget.isGeneral ? 'Add to the discussion...' : 'Share your perspective...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Post Button
              _isPosting 
                ? const SizedBox(
                    width: 40, 
                    height: 40, 
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_upward_rounded, size: 20, color: Colors.white),
                      onPressed: _handlePost,
                      padding: EdgeInsets.zero,
                    ),
                  ),
            ],
          ),
        ],
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
              color: isSelected ? Colors.white : AppColors.textSecondary
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
