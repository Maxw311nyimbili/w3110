import 'package:cap_project/features/chat/widgets/chat_input.dart';
import 'package:cap_project/features/chat/widgets/message_bubble.dart';
import 'package:cap_project/features/chat/widgets/thinking_indicator.dart';
import 'package:cap_project/features/chat/widgets/audio_playback_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../app/view/app_router.dart';
import '../../auth/cubit/cubit.dart';
import '../../landing/widgets/welcome_drawer.dart';
import '../../../core/widgets/brand_logo.dart';
import '../../../core/widgets/entry_animation.dart';
import '../../../l10n/l10n.dart';

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
  bool _showScrollToBottom = false;
  int _unreadCount = 0;

  // GoogleFonts styles cached here so they aren't re-created on every build.
  // Re-cached in didChangeDependencies so they stay correct after a theme change.
  late TextStyle _greetingStyleMobile;
  late TextStyle _greetingStyleDesktop;
  late TextStyle _dailyFactStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bodyColor = Theme.of(context).textTheme.bodyLarge?.color;
    _greetingStyleMobile = GoogleFonts.cormorantGaramond(
      fontSize: 40,
      fontWeight: FontWeight.w300,
      color: bodyColor,
      letterSpacing: 1.0,
      height: 1.1,
    );
    _greetingStyleDesktop = GoogleFonts.cormorantGaramond(
      fontSize: 52,
      fontWeight: FontWeight.w300,
      color: bodyColor,
      letterSpacing: 1.0,
      height: 1.1,
    );
    _dailyFactStyle = GoogleFonts.cormorantGaramond(
      fontSize: 20,
      height: 1.55,
      color: bodyColor,
      fontWeight: FontWeight.w500,
      fontStyle: FontStyle.italic,
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatCubit>().initialize();
    });
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
              action: SnackBarAction(
                label: AppLocalizations.of(context).dismiss,
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
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, state) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 280),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: !state.hasMessages
                  ? _buildLandingView(context, state)
                  : _buildActiveView(context, state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLandingView(BuildContext context, ChatState state) {
    if (state.isLoading && !state.hasMessages) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildEmptyState(context);
  }

  Widget _buildActiveView(BuildContext context, ChatState state) {
    return Column(
      children: [
        Expanded(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                _buildMessageList(context, state),
                if (_showScrollToBottom) _buildScrollToBottomButton(),
                // Subtle Floating Sign-In Chip
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: BlocBuilder<AuthCubit, AuthState>(
                    builder: (context, state) {
                      if (state.isAuthenticated) return const SizedBox.shrink();
                      return _buildFloatingSignInChip(context);
                    },
                  ),
                ),
                // Audio Playback Indicator Pill
                const Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: AudioPlaybackPill(),
                ),
              ],
            ),
          ),
        ),
        if (state.isTyping) _buildTypingIndicator(),
        SafeArea(
          top: false,
          child: RefinedChatInput(
            key: const ValueKey('active_input'),
            isAudioMode: widget.isAudioMode,
            onToggleAudio: widget.onToggleAudio,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hour = DateTime.now().hour;
    String greeting;
    if (hour >= 5 && hour < 12) {
      greeting = l10n.goodMorning;
    } else if (hour >= 12 && hour < 17) {
      greeting = l10n.goodAfternoon;
    } else {
      greeting = l10n.goodEvening;
    }
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final displayGreeting = state.dynamicGreeting ?? greeting;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            return Stack(
              children: [
                // ── Faint brand watermark ──
                Positioned(
                  top: constraints.maxHeight * 0.05,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: isDark ? 0.06 : 0.09,
                      child: BrandLogo(
                        size: constraints.maxWidth.clamp(240, 420).toDouble(),
                        isBreathing: false,
                      ),
                    ),
                  ),
                ),

                // ── Content ──
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 40,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: 1000,
                    ),
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isDesktop ? 40 : 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: isDesktop ? 80 : 64),

                            // 1. GREETING — display serif
                            EntryAnimation(
                              key: ValueKey(displayGreeting),
                              child: Column(
                                children: [
                                  Text(
                                    displayGreeting,
                                    textAlign: TextAlign.center,
                                    style: isDesktop
                                        ? _greetingStyleDesktop
                                        : _greetingStyleMobile,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    l10n.chatSupportQuestion,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.color,
                                          letterSpacing: 0.2,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 36),

                            // 2. DAILY INSIGHT CARD
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 560),
                              child: EntryAnimation(
                                delay: const Duration(milliseconds: 180),
                                child: _buildDailyFact(context),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // 3. PROMPT SUGGESTIONS — desktop only
                            if (!isDesktop) const SizedBox(height: 4),
                            if (isDesktop) ...[
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 560,
                                ),
                                child: EntryAnimation(
                                  delay: const Duration(milliseconds: 280),
                                  child: _buildSuggestedPrompts(context),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // 4. CENTERED INPUT PILL
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 720),
                              child: EntryAnimation(
                                delay: const Duration(milliseconds: 360),
                                child: RefinedChatInput(
                                  key: const ValueKey('landing_input'),
                                  isAudioMode: widget.isAudioMode,
                                  onToggleAudio: widget.onToggleAudio,
                                  isLandingMode: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 60),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSuggestedPrompts(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final suggestions = [
      l10n.promptVitamins,
      l10n.promptPreeclampsia,
      l10n.promptExercise,
      l10n.promptBabyMovement,
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) {
        return GestureDetector(
          onTap: () => context.read<ChatCubit>().sendMessage(s),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? Theme.of(context).colorScheme.surface
                  : AppColors.backgroundSurface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(
                  isDark ? 0.22 : 0.20,
                ),
                width: 1,
              ),
              boxShadow: const [],
            ),
            child: Text(
              s,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyFact(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final facts = [
      l10n.insightFolicAcid,
      l10n.insightGinger,
      l10n.insightBloodVolume,
      l10n.insightHydration,
      l10n.insightIron,
      l10n.insightWalking,
      l10n.insightHearing,
      l10n.insightCalcium,
      l10n.insightBananas,
      l10n.insightStress,
    ];

    final dayOfYear = int.parse(
      DateTime.now()
          .difference(DateTime(DateTime.now().year, 1, 1))
          .inDays
          .toString(),
    );
    final factIndex = dayOfYear % facts.length;
    final dailyFact = facts[factIndex];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        // Light: warm surface cream — stays in the same ivory family as canvas.
        // Dark: surface with slight opacity for depth.
        color: Theme.of(context).brightness == Brightness.dark
            ? Theme.of(context).colorScheme.surface.withOpacity(0.85)
            : AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).dividerColor.withOpacity(0.08)
              : AppColors.borderLight,
          width: 1.0,
        ),
        boxShadow: [
          // Subtle shadow only in dark mode — light mode relies on the
          // colour step between backgroundCanvas and backgroundSurface.
          if (Theme.of(context).brightness == Brightness.dark)
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
              blurRadius: 24,
              spreadRadius: -2,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -10,
            left: -10,
            child: Icon(
              Icons.format_quote_rounded,
              size: 60,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ),
          ),
          Column(
            children: [
              Text(
                AppLocalizations.of(context).dailyInsight.toUpperCase(),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                dailyFact,
                textAlign: TextAlign.center,
                style: _dailyFactStyle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, ChatState state) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        top: 4,
        bottom: 24,
      ),
      reverse: true,
      itemCount: state.messages.length,
      itemBuilder: (context, index) {
        final reversedIndex = state.messages.length - 1 - index;
        final message = state.messages[reversedIndex];
        // RepaintBoundary gives each bubble its own compositing layer so that
        // scrolling and streaming text into one bubble don't force every other
        // bubble on screen to repaint.
        return RepaintBoundary(
          child: RefinedMessageBubble(
            message: message,
            key: ValueKey(message.id),
          ),
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
              color: Theme.of(context).colorScheme.primary.withOpacity(0.96),
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.22),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.06),
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
