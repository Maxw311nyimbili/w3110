import 'package:cap_project/features/chat/widgets/audio_waveform.dart';
import 'package:cap_project/features/chat/widgets/chat_input.dart';
import 'package:cap_project/features/chat/widgets/message_bubble.dart';
import 'package:cap_project/features/chat/widgets/thinking_indicator.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ChatBody extends StatefulWidget {
  final bool isAudioMode;
  final VoidCallback onToggleAudio;

  const ChatBody({
    super.key,
    required this.isAudioMode,
    required this.onToggleAudio,
  });

  @override
  State<ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<ChatBody> {
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottom = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.offset < 50) {
      if (_showScrollToBottom) {
        setState(() {
          _showScrollToBottom = false;
          _unreadCount = 0;
        });
      }
    }
  }

  void _scrollToLatestMessage() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatCubit, ChatState>(
      listenWhen: (previous, current) => 
          previous.messages.length != current.messages.length ||
          (previous.error == null && current.error != null),
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
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<ChatCubit>().clearError();
        }
        
        if (state.hasMessages) {
          final lastMessage = state.messages.last;
          final isUserMessage = lastMessage.isUser;
          
          if (isUserMessage) {
            _scrollToLatestMessage();
          } else {
            // AI message arrived
            if (_scrollController.hasClients && _scrollController.offset > 100) {
              setState(() {
                _showScrollToBottom = true;
                _unreadCount++;
              });
            } else {
              _scrollToLatestMessage();
            }
          }
        }
      },
      child: Container(
        color: AppColors.backgroundPrimary,
        child: Stack(
          children: [
            Column(
              children: [
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.isLoading && !state.hasMessages) {
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
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
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isTyping) {
                  return state.loadingMessage != null
                    ? ThinkingIndicator(message: state.loadingMessage!)
                    : _buildTypingIndicator();
                }
                return const SizedBox.shrink();
              },
            ),
            RefinedChatInput(
              isAudioMode: widget.isAudioMode,
              onToggleAudio: widget.onToggleAudio,
            ),
          ],
        ),
            if (_showScrollToBottom)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _scrollToLatestMessage,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _unreadCount > 1 ? '$_unreadCount New Messages' : 'New Message',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundSurface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_outlined,
                size: 32,
                color: AppColors.accentPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              AppLocalizations.of(context).chatWelcomeTitle,
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).chatWelcomeSubtitle,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.2,
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
      controller: _scrollController,
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        top: 12,
        bottom: 180,
      ),
      reverse: true,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = state.messages.length - 1 - index;
        final message = state.messages[reversedIndex];
        return RefinedMessageBubble(
          message: message,
          key: ValueKey(message.id),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(delay: 0),
                const SizedBox(width: 4),
                _buildTypingDot(delay: 100),
                const SizedBox(width: 4),
                _buildTypingDot(delay: 200),
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
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        final paused = value < 0.33 || (value > 0.66 && value < 1.0);
        return Opacity(
          opacity: paused ? 0.4 : 1.0,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.textPrimary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}