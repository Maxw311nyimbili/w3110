// lib/features/forum/view/forum_list_page.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
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
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: AppColors.backgroundSurface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Text(
              state.view == ForumView.detail ? 'Post Details' : 'Community',
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            leading: state.view == ForumView.detail
                ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => context.read<ForumCubit>().backToList(),
            )
                : null,
            actions: [
              // Sync status indicator
              if (state.isSyncing)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.accentPrimary,
                        ),
                      ),
                    ),
                  ),
                )
              else if (state.hasPendingSync)
                IconButton(
                  icon: const Icon(Icons.cloud_upload_outlined),
                  color: AppColors.warning,
                  tooltip: 'Sync pending',
                  onPressed: () =>
                      context.read<ForumCubit>().syncWithBackend(),
                )
              else if (state.lastSyncTime != null)
                  IconButton(
                    icon: const Icon(Icons.cloud_done_outlined),
                    color: AppColors.accentPrimary,
                    tooltip: 'Synced',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Last synced: ${_formatSyncTime(state.lastSyncTime!)}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.textPrimary,
                          margin: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
              ? _buildPremiumFAB(context)
              : null,
        );
      },
    );
  }

  /// Premium FAB with icon and text
  Widget _buildPremiumFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24, right: 24),
      child: GestureDetector(
        onTap: () => _showNewPostSheet(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.accentPrimary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'New Post',
                style: AppTextStyles.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewPostSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
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