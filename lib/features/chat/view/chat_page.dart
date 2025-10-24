// lib/features/chat/view/chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_repository/chat_repository.dart';
import '../../../core/widgets/app_drawer.dart';
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

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Clear conversation',
            onPressed: () => _showChatMenu(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: const SafeArea(
        child: ChatBody(),
      ),
    );
  }

  void _showChatMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Clear conversation'),
              onTap: () {
                Navigator.pop(context);
                context.read<ChatCubit>().clearHistory();
              },
            ),
          ],
        ),
      ),
    );
  }
}