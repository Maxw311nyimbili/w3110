import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/locale/cubit/locale_cubit.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/core/services/audio_recording_service.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

import 'package:landing_repository/landing_repository.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:forum_repository/forum_repository.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

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
    _loadOnboarding();
  }

  Future<void> _loadOnboarding() async {
    try {
      final status = await context.read<LandingRepository>().getOnboardingStatus();
      if (mounted) {
        setState(() {
          _onboardingStatus = status;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
              audioRecordingService: AudioRecordingService(),
              locale: locale,
              userRole: _onboardingStatus?.userRole,
              interests: _onboardingStatus?.interests,
            )..initialize();
            
            context.read<LocaleCubit>().stream.listen((localeState) {
              cubit.setLocale(localeState.locale.languageCode);
            });
            
            return cubit;
          },
        ),
        BlocProvider(
          create: (context) => ForumCubit(
            forumRepository: context.read<ForumRepository>(),
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
    final user = context.watch<AuthCubit>().state.user;
    final status = widget.onboardingStatus;
    final initial = (status?.userName ?? user?.displayName ?? 'U')[0].toUpperCase();
    final photoUrl = user?.photoUrl;

    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure layout adjusts for keyboard
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _isAudioMode 
        ? null 
        : AppBar(
            elevation: 0,
            backgroundColor: AppColors.backgroundPrimary,
            surfaceTintColor: Colors.transparent,
            leadingWidth: 56,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: GestureDetector(
                  onTap: () => AppRouter.navigateTo(context, AppRouter.settings),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary.withOpacity(0.1),
                      shape: BoxShape.circle,
                      image: photoUrl != null 
                        ? DecorationImage(image: NetworkImage(photoUrl), fit: BoxFit.cover)
                        : null,
                    ),
                    child: photoUrl == null 
                      ? Center(
                          child: Text(
                            initial,
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  ),
                ),
              ),
            ),
            title: Text(
                'Thanzi',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1, 
                color: AppColors.borderLight.withOpacity(0.5)
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.forum_outlined, size: 22),
                onPressed: () => AppRouter.navigateTo(context, AppRouter.forum),
              ),
              const SizedBox(width: 8),
            ],
          ),
      body: ChatBody(
        isAudioMode: _isAudioMode,
        onToggleAudio: _toggleAudioMode,
      ),
    );
  }
}
