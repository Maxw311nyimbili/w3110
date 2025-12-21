// lib/features/chat/view/chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../widgets/widgets.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ChatPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatCubit(
        chatRepository: context.read<ChatRepository>(),
      )..initialize(),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  const ChatView({super.key});

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
    final initial = (user?.displayName ?? 'U')[0].toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: _isAudioMode 
        ? null 
        : AppBar(
            elevation: 0,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => AppRouter.navigateTo(context, AppRouter.settings),
                child: CircleAvatar(
                  backgroundColor: AppColors.gray200,
                  child: Text(
                    initial,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
                'Thanzi',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.forum_outlined, color: AppColors.textPrimary),
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
