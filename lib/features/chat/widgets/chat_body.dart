import 'dart:math';
import 'package:cap_project/features/chat/widgets/chat_input.dart';
import 'package:cap_project/features/chat/widgets/message_bubble.dart';
import 'package:cap_project/features/chat/widgets/thinking_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../app/view/app_router.dart';
import '../../auth/cubit/cubit.dart';
import '../../landing/widgets/welcome_drawer.dart';
import '../../../core/widgets/entry_animation.dart';

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

class _ChatBodyState extends State<ChatBody>
    with SingleTickerProviderStateMixin {
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().initialize();
    });
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
              action: SnackBarAction(
                label: 'Dismiss',
                onPressed: () => context.read<ChatCubit>().clearError(),
                textColor: Colors.white,
              ),
            ),
          );
        }

        if (state.hasMessages) {
          final lastMessage = state.messages.last;
          if (lastMessage.isUser || state.isTyping) {
            _scrollToLatestMessage();
          } else {
            if (_scrollController.hasClients &&
                _scrollController.offset > 100) {
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
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          children: [
            Expanded(
              child: SafeArea(
                bottom: false,
                child: Stack(
                  children: [
                    BlocBuilder<ChatCubit, ChatState>(
                      builder: (context, state) {
                        print('Debug: ChatBody BlocBuilder Rebuild. Messages: ${state.messages.length}, Status: ${state.status}');
                        if (state.isLoading && !state.hasMessages) {
                          return Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).colorScheme.primary,
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
                    if (_showScrollToBottom) _buildScrollToBottomButton(),

                    // Subtle Floating Sign-In Chip
                    Positioned(
                      bottom: 8,
                      left: 0,
                      right: 0,
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          if (state.isAuthenticated)
                            return const SizedBox.shrink();
                          return _buildFloatingSignInChip(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.isTyping) {
                  return _buildTypingIndicator();
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
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning,';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon,';
    } else {
      greeting = 'Good Evening,';
    }

    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final displayGreeting = state.dynamicGreeting ?? greeting;

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Spacer(),
                          Column(
                            children: [
                              EntryAnimation(
                                child: Text(
                                  displayGreeting,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -1.5,
                                    color: Theme.of(context).textTheme.displayLarge?.color,
                                    height: 1.1,
                                    fontSize: 40,
                                  ),
                                  key: ValueKey(displayGreeting),
                                ),
                              ),
                              const SizedBox(height: 12),
                              EntryAnimation(
                                delay: const Duration(milliseconds: 200),
                                child: Text(
                                  'Your personal health guide.',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Theme.of(context).textTheme.bodySmall?.color,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 56),
                          AnimatedBuilder(
                            animation: _breathingController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale:
                                    0.98 + (0.02 * _breathingController.value),
                                child: Opacity(
                                  opacity:
                                      0.5 + (0.5 * _breathingController.value),
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
          },
        );
      },
    );
  }

  Widget _buildDailyFact(BuildContext context) {
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

    final dayOfYear = int.parse(
      DateTime.now()
          .difference(DateTime(DateTime.now().year, 1, 1))
          .inDays
          .toString(),
    );
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
              Positioned(
                top: -20,
                left: 20,
                child: Transform.rotate(
                  angle: -0.2,
                  child: Icon(
                    Icons.format_quote_rounded,
                    size: 140,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Text(
                      'DAILY INSIGHT',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2.0,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dailyFact,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        height: 1.5,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: 40,
                      height: 2,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
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
        bottom: 24,
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
    return const Padding(
      padding: EdgeInsets.fromLTRB(4, 4, 4, 4),
      child: ThinkingIndicator(),
    );
  }

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: _scrollToLatestMessage,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.brandDarkTeal.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: AppShadows.card,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  _unreadCount > 1
                      ? '$_unreadCount New Messages'
                      : 'New Message',
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
    );
  }

  Widget _buildFloatingSignInChip(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ColorFilter.mode(
            Colors.transparent,
            BlendMode.dst,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => WelcomeDrawer.show(context),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.22),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sign in',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'to save history',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
