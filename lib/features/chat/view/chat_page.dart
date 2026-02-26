import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/core/services/audio_recording_service.dart';
import 'package:cap_project/features/landing/widgets/welcome_drawer.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart'
    as scanner;
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/core/widgets/main_navigation_shell.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

import 'package:landing_repository/landing_repository.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:forum_repository/forum_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({this.initialScanResult, super.key});

  final scanner.ScanResult? initialScanResult;

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  OnboardingStatus? _onboardingStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      final status = await context
          .read<LandingRepository>()
          .getOnboardingStatus();
      if (mounted) {
        setState(() {
          _onboardingStatus = status;
          _isLoading = false;
        });

        // Handle initial entry (Popup or Onboarding)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _handleEntryStatus(status);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleEntryStatus(OnboardingStatus status) {
    final authState = context.read<AuthCubit>().state;

    // 1. If not authenticated, show the Welcome Drawer (Gate)
    if (authState.status != AuthStatus.authenticated) {
      WelcomeDrawer.show(context);
      return;
    }

    // 2. If authenticated but hasn't finished personalization, guide them back
    if (!status.isComplete) {
      AppRouter.replaceTo<void>(
        context,
        AppRouter.landing,
        arguments: {'initialStep': OnboardingStep.roleSelection},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final locale = context.read<LocaleCubit>().state.locale.languageCode;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) {
            final cubit = ChatCubit(
              chatRepository: context.read<ChatRepository>(),
              landingRepository: context.read<LandingRepository>(),
              audioRecordingService: AudioRecordingService(),
              locale: locale,
              userRole: _onboardingStatus?.userRole,
              interests: _onboardingStatus?.interests,
            )..initialize();

            if (widget.initialScanResult != null) {
              cubit.addMedicineResult(widget.initialScanResult!);
            }

            context.read<LocaleCubit>().stream.listen((localeState) {
              cubit.setLocale(localeState.locale.languageCode);
            });

            return cubit;
          },
        ),
        BlocProvider(
          create: (context) => ForumCubit(
            forumRepository: context.read<ForumRepository>(),
            authRepository: context.read<AuthRepository>(),
          ),
        ),
      ],
      child: ChatView(onboardingStatus: _onboardingStatus),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key, this.onboardingStatus});

  final OnboardingStatus? onboardingStatus;

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  bool _isAudioMode = false;

  void _toggleAudioMode() {
    setState(() {
      _isAudioMode = !_isAudioMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveUtils.isDesktop(context);

    return MainNavigationShell(
      title: (!isDesktop && !_isAudioMode)
          ? Text(
              'Thanzi',
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            )
          : null,
      actions: (!isDesktop && !_isAudioMode)
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(
                        Icons.history_rounded,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: 'Chat History',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withOpacity(0.1),
                    ),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.forum_outlined,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => AppRouter.navigateTo<void>(
                      context,
                      AppRouter.forum,
                    ),
                    tooltip: 'Community Forum',
                  ),
                ),
              ),
            ]
          : null,
      endDrawer: const HistoryDrawer(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Body
              Expanded(
                child: ChatBody(
                  isAudioMode: _isAudioMode,
                  onToggleAudio: _toggleAudioMode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
