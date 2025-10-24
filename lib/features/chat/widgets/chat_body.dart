// lib/features/chat/widgets/chat_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import 'message_bubble.dart';
import 'chat_input.dart';

/// Main chat interface body - message list and input
class ChatBody extends StatelessWidget {
  const ChatBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listener: (context, state) {
        // Show error messages
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<ChatCubit>().clearError();
        }
      },
      child: Column(
        children: [
          // Message list
          Expanded(
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isLoading && !state.hasMessages) {
                  return const Center(
                    child: CircularProgressIndicator(),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              AppStrings.chatEmptyState,
              style: AppTextStyles.headlineMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Ask me anything about health, medications, or prenatal care',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      reverse: true, // Show newest messages at bottom
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
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(delay: 0),
                const SizedBox(width: 4),
                _buildTypingDot(delay: 150),
                const SizedBox(width: 4),
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
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}