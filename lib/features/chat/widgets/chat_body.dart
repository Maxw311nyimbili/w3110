// lib/features/chat/widgets/chat_body.dart
// PREMIUM DESIGN - MedLink Brand Identity

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import 'message_bubble.dart';
import 'chat_input.dart';

class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
          context.read<ChatCubit>().clearError();
        }
      },
      child: Container(
        color: AppColors.backgroundPrimary,
        child: Column(
          children: [
            // Message list
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isLoading && !state.hasMessages) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentPrimary,
                        ),
                      ),
                    );
                  }

                  if (!state.hasMessages) {
                    return _buildEmptyState(context);
                  }

                  return _buildMessageList(context, state);
                },
              ),
            ),

            // Typing indicator
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isTyping) {
                  return _buildTypingIndicator();
                }
                return const SizedBox.shrink();
              },
            ),

            // Input field
            const ChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Premium MedLink logo/badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.medical_services_outlined,
                  size: 40,
                  color: AppColors.accentPrimary,
                ),
              ),

              const SizedBox(height: 28),

              // Main greeting
              Text(
                'Medical Guidance,\nInstantly.',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subheading
              Text(
                'Trusted health information powered by AI.\nAlways consult a healthcare provider for medical advice.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Suggested prompts
              _buildSuggestedPrompts(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestedPrompts(BuildContext context) {
    final prompts = [
      'Prenatal vitamins',
      'Morning sickness tips',
      'Safe exercises',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: prompts
          .map(
            (prompt) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => context.read<ChatCubit>().sendMessage(prompt),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gray200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: AppColors.accentPrimary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    prompt,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      reverse: true,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = state.messages.length - 1 - index;
        final message = state.messages[reversedIndex];
        return MessageBubble(
          message: message,
          key: ValueKey(message.id),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.gray200,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(delay: 0),
                const SizedBox(width: 6),
                _buildTypingDot(delay: 150),
                const SizedBox(width: 6),
                _buildTypingDot(delay: 300),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot({required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.accentPrimary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}