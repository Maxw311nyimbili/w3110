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
import 'package:cap_project/features/medscanner/cubit/medscanner_state.dart' as scanner;
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
      final status = await context.read<LandingRepository>().getOnboardingStatus();
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
    final authState = context.watch<AuthCubit>().state;
    final user = authState.user;
    final status = widget.onboardingStatus;
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            if (!_isAudioMode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundPrimary,
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.borderLight.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Profile / Settings Button
                    GestureDetector(
                      onTap: () => AppRouter.navigateTo<void>(context, AppRouter.settings),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundSurface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.borderLight),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thanzi',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Actions
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.backgroundSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.forum_outlined, size: 20, color: AppColors.textPrimary),
                        onPressed: () => AppRouter.navigateTo<void>(context, AppRouter.forum),
                        tooltip: 'Community Forum',
                      ),
                    ),
                  ],
                ),
              ),

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
    );
  }
}
