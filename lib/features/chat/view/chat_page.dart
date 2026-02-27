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

    // 1. If not authenticated, we don't show the Welcome Drawer automatically.
    // Guests can already see the sidebar footer to sign in.
    if (authState.status != AuthStatus.authenticated) {
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
    if (!mounted) return;
    // Only update if this tab is active
    final activeTab = context.read<NavigationCubit>().state.activeTab;
    if (activeTab != AppTab.chat) return;

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
                // 1. New Chat Button
                IconButton(
                  icon: Icon(
                    Icons.add_circle_outline_rounded,
                    size: 22,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () => context.read<ChatCubit>().startNewSession(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: 'New Chat',
                ),
                const SizedBox(width: 14),

                // 2. Auth Dependent Action
                _buildAuthAction(context),

                const SizedBox(width: 12),
              ]
            : null,
      );
    });
  }

  Widget _buildAuthAction(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final isAuthenticated = authState.status == AuthStatus.authenticated;
    final theme = Theme.of(context);

    if (isAuthenticated) {
      final name = (authState.user?.displayName as String?) ?? 'User';
      final initials = name
          .trim()
          .split(' ')
          .take(2)
          .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
          .join();

      return InkWell(
        onTap: () => context.read<NavigationCubit>().setTab(AppTab.settings),
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: Text(
              initials.isEmpty ? 'U' : initials,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ),
      );
    }

    // Guest CTA
    return TextButton(
      onPressed: () => WelcomeDrawer.show(context),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Text(
        'Sign In',
        style: TextStyle(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (_isAudioMode) {
      // Re-update app bar when mode changes
      _updateAppBar();
    }

    return MultiBlocListener(
      listeners: [
        BlocListener<NavigationCubit, NavigationState>(
          listenWhen: (prev, curr) => prev.activeTab != curr.activeTab,
          listener: (context, state) {
            if (state.activeTab == AppTab.chat) {
              _updateAppBar();
            }
          },
        ),
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            _updateAppBar();
          },
        ),
      ],
      child: BlocBuilder<ChatCubit, ChatState>(
        builder: (context, chatState) {
          return Scaffold(
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
      ),
    );
  }
}
