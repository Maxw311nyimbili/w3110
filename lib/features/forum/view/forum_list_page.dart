// lib/features/forum/view/forum_list_page.dart

import 'package:cap_project/core/widgets/app_drawer.dart';
import 'package:cap_project/features/forum/cubit/cubit.dart';
import 'package:cap_project/features/forum/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:forum_repository/forum_repository.dart';

/// Forum list page - entry point for forum feature
class ForumListPage extends StatelessWidget {
  const ForumListPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const ForumListPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForumCubit(
        forumRepository: context.read<ForumRepository>(),
      )..initialize(),
      child: const ForumListView(),
    );
  }
}

/// Forum list view - wraps forum body with app bar
class ForumListView extends StatelessWidget {
  const ForumListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state.view == ForumView.detail ? 'Post Details' : 'Community Forum',
            ),
            leading: state.view == ForumView.detail
                ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.read<ForumCubit>().backToList(),
            )
                : null, // Will show hamburger menu automatically
            actions: [
              // Sync status indicator
              if (state.isSyncing)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (state.hasPendingSync)
                IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined),
                  tooltip: 'Sync pending',
                  onPressed: () => context.read<ForumCubit>().syncWithBackend(),
                )
              else if (state.lastSyncTime != null)
                  IconButton(
                    icon: const Icon(Icons.cloud_done_outlined),
                    tooltip: 'Synced',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Last synced: ${_formatSyncTime(state.lastSyncTime!)}',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
            ],
          ),
          drawer: state.view == ForumView.list ? const AppDrawer() : null,
          body: const SafeArea(
            child: ForumBody(),
          ),
          floatingActionButton: state.view == ForumView.list
              ? FloatingActionButton.extended(
            onPressed: () => _showNewPostSheet(context),
            icon: const Icon(Icons.add_rounded),
            label: const Text('New Post'),
          )
              : null,
        );
      },
    );
  }

  void _showNewPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocProvider.value(
          value: context.read<ForumCubit>(),
          child: const NewPostSheet(),
        ),
      ),
    );
  }

  String _formatSyncTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}