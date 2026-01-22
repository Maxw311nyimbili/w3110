// lib/features/forum/widgets/reply_input_field_for_modal.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';

class ReplyInputFieldForModal extends StatefulWidget {
  final String lineId;

  const ReplyInputFieldForModal({super.key, required this.lineId});

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
      await context.read<ForumCubit>().postLineComment(
        text: _textController.text,
        commentType: _typeController.value,
      );
      _textController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      // Error handling is managed by Cubit state, but we stop loading here
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.comment_outlined, size: 14, color: AppColors.accentPrimary),
              const SizedBox(width: 8),
              Text(
                'Share your thoughts',
                style: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Comment type dropdown
          Container(
            height: 44,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.gray200),
              borderRadius: BorderRadius.circular(8),
              color: AppColors.backgroundSurface,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ValueListenableBuilder<String>(
              valueListenable: _typeController,
              builder: (context, value, child) {
                return DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary),
                    items: const [
                      DropdownMenuItem(
                        value: 'clinical',
                        child: Text('⚕️ Clinical Interpretation'),
                      ),
                      DropdownMenuItem(
                        value: 'evidence',
                        child: Text('📚 Supporting Evidence'),
                      ),
                      DropdownMenuItem(
                        value: 'experience',
                        child: Text('💬 Lived Experience'),
                      ),
                      DropdownMenuItem(
                        value: 'concern',
                        child: Text('⚠️ Concern / Clarification'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) _typeController.value = v;
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Text input
          TextField(
            controller: _textController,
            minLines: 1,
            maxLines: 4,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Share your perspective...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.gray200),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              filled: true,
              fillColor: AppColors.backgroundPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Send button
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: _isPosting 
                ? const SizedBox(
                    width: 36, 
                    height: 36, 
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : ElevatedButton.icon(
                    onPressed: _handlePost,
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Post'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentPrimary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      textStyle: AppTextStyles.labelSmall.copyWith(fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
