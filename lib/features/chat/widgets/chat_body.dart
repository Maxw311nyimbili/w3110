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

class _ChatBodyState extends State<ChatBody> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _breathingController;
  bool _showScrollToBottom = false;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Breathing animation for Greeting
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathingController.dispose();
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
          if (lastMessage.isUser) {
            _scrollToLatestMessage();
          } else {
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
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    BlocBuilder<ChatCubit, ChatState>(
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
                    if (_showScrollToBottom)
                      Positioned(
                        bottom: 20,
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
            SafeArea(
              top: false,
              child: RefinedChatInput(
                isAudioMode: widget.isAudioMode,
                onToggleAudio: widget.onToggleAudio,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    // 1. Dynamic Greeting
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(), 
                      
                      // 1. Premium Greeting Group
                      Column(
                        children: [
                          Text(
                            greeting,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayLarge.copyWith( // Even Bigger
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.5,
                              color: AppColors.textPrimary,
                              height: 1.1,
                              fontSize: 40,
                            ),
                            key: ValueKey(greeting),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your personal health guide.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      
                      // Fixed spacing to visually group greeting + fact
                      const SizedBox(height: 56),

                      // 2. Editorial Insight Widget (Now Breathing)
                      AnimatedBuilder(
                        animation: _breathingController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 0.98 + (0.02 * _breathingController.value), // Subtle beat
                            child: Opacity(
                              opacity: 0.5 + (0.5 * _breathingController.value), // Deep breathing
                              child: child,
                            ),
                          );
                        },
                        child: _buildDailyFact(context),
                      ),
                      
                      const Spacer(), 
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }
    );
  }

  Widget _buildDailyFact(BuildContext context) {
    // Pregnancy-focused facts + General Health
    final facts = [
      'Take 400mcg of Folic Acid daily.',
      'Ginger is effective for morning sickness.',
      'Blood volume increases 50% during pregnancy.',
      'Staying hydrated forms the amniotic sac.',
      'Iron needs double during pregnancy.',
      'Walking is safe throughout pregnancy.',
      'Babies hear sounds around 24 weeks.',
      'Calcium is crucial for baby\'s bones.',
      'Bananas help prevent leg cramps.',
      'Stress affects baby’s development.',
    ];

    final dayOfYear = int.parse(DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays.toString());
    final factIndex = dayOfYear % facts.length;
    final dailyFact = facts[factIndex];

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Giant Background Quote Mark
              Positioned(
                top: -20,
                left: 20,
                child: Transform.rotate(
                  angle: -0.2, // Slight tilt
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 140,
                    color: AppColors.accentPrimary.withOpacity(0.06), // Very faint
                  ),
                ),
              ),

              // 2. Editorial Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    // Small Eyebrow Label
                    Text(
                      'DAILY INSIGHT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.accentPrimary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // High-End Serif Typography
                    Text(
                      dailyFact,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                         // Fallback to Georgia or generic serif since GoogleFonts might not be fully loaded for 'Playfair'
                         fontFamily: 'Georgia', 
                         fontSize: 22,
                         height: 1.4,
                         color: AppColors.textPrimary,
                         fontWeight: FontWeight.w500,
                         fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Decorative Line
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.accentPrimary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 12,
        bottom: 24, // Reduced from 180 to allow input area to naturally push content
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