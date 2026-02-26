import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/landing/widgets/welcome_drawer.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart'
    as scanner;
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/app/cubit/navigation_cubit.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';
import '../widgets/history_drawer.dart';

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

        // Update the shared ChatCubit with onboarding profile data
        if (mounted) {
          context.read<ChatCubit>().updateProfile(
            userRole: status.userRole,
            interests: status.interests,
          );
          context.read<ChatCubit>().initialize();
          if (widget.initialScanResult != null) {
            context.read<ChatCubit>().addMedicineResult(widget.initialScanResult!);
          }
        }

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

    context.read<LocaleCubit>().stream.listen((localeState) {
      context.read<ChatCubit>().setLocale(localeState.locale.languageCode);
    });

    return BlocProvider(
      create: (context) => ForumCubit(
        forumRepository: context.read<ForumRepository>(),
        authRepository: context.read<AuthRepository>(),
      ),
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
    _updateAppBar();
  }

  @override
  void initState() {
    super.initState();
    _updateAppBar();
  }

  void _updateAppBar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final isDesktop = ResponsiveUtils.isDesktop(context);

      context.read<NavigationCubit>().updateAppBar(
        title: !_isAudioMode
            ? Text(
                'Thanzi',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              )
            : null,
        // Only show top-bar icons on mobile — desktop uses the sidebar
        actions: (!_isAudioMode && !isDesktop)
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Builder(
                    builder: (context) => IconButton(
                      icon: Icon(
                        Icons.history_rounded,
                        size: 22,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                      tooltip: 'Chat History',
                    ),
                  ),
                ),
              ]
            : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isAudioMode) {
      // Re-update app bar when mode changes
      _updateAppBar();
    }

    return Scaffold(
      endDrawer: const HistoryDrawer(),
      body: Center(
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
