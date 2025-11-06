import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RefinedChatInput extends StatefulWidget {
  const RefinedChatInput({super.key});

  @override
  State<RefinedChatInput> createState() => _RefinedChatInputState();
}

class _RefinedChatInputState extends State<RefinedChatInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;
  bool _isRecording = false;

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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();
    context.read<ChatCubit>().sendMessage(message);
    _controller.clear();
    _focusNode.unfocus();
    setState(() {
      _hasText = false;
    });
  }

  void _toggleVoice() {
    setState(() {
      _isRecording = !_isRecording;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main encapsulated container
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _focusNode.hasFocus
                    ? AppColors.accentPrimary
                    : AppColors.gray200,
                width: 0.8,
              ),
              boxShadow: _focusNode.hasFocus
                  ? [
                BoxShadow(
                  color: AppColors.accentPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : [],
            ),
            child: Column(
              children: [
                // Text input field - full width, no border, with top radius
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    maxLines: null,
                    minLines: 1,
                    maxLength: 5000,
                    textInputAction: TextInputAction.newline,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask MedLink anything...',
                      hintStyle: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      counterText: '',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),

                // Bottom action bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Voice button
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _toggleVoice,
                          borderRadius: BorderRadius.circular(8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              _isRecording
                                  ? Icons.mic
                                  : Icons.mic_none_rounded,
                              color: _isRecording
                                  ? AppColors.error
                                  : AppColors.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                      ),

                      // Send button
                      BlocBuilder<ChatCubit, ChatState>(
                        builder: (context, state) {
                          final canSend = _hasText && !state.isTyping;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: canSend
                                  ? AppColors.accentPrimary
                                  : AppColors.backgroundElevated,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: canSend ? _sendMessage : null,
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    color: canSend
                                        ? Colors.white
                                        : AppColors.textTertiary,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Recording indicator
          if (_isRecording) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording...',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}