// lib/features/chat/widgets/chat_input.dart
// PREMIUM DESIGN - Authority & Trust Statement

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
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

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final message = _controller.text.trim();
    context.read<ChatCubit>().sendMessage(message);

    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundPrimary,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Input row
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Premium text input
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.gray200,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentPrimary.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask about health, medications, care...',
                          hintStyle: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg,
                            vertical: AppSpacing.md,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Premium send button
                  BlocBuilder<ChatCubit, ChatState>(
                    builder: (context, state) {
                      final canSend = _hasText && !state.isTyping;

                      return GestureDetector(
                        onTap: canSend ? _sendMessage : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: canSend
                                ? AppColors.accentPrimary
                                : AppColors.backgroundElevated,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: canSend
                                ? [
                              BoxShadow(
                                color: AppColors.accentPrimary
                                    .withOpacity(0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                                : [],
                          ),
                          child: Icon(
                            Icons.arrow_upward_rounded,
                            color: canSend
                                ? Colors.white
                                : AppColors.textTertiary,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.md),

              // Trust statement - subtle but present
              Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 14,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'MedLink AI: Reliable health guidance. Not a substitute for professional medical advice.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}