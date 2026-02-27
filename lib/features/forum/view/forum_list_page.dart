import 'package:cap_project/core/theme/app_colors.dart';
import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/forum_body.dart';
import 'package:cap_project/features/forum/widgets/new_post_sheet.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/widgets/entry_animation.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:forum_repository/forum_repository.dart';

class ForumListPage extends StatelessWidget {
  const ForumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you might inject this scope higher up or rely on auto-injection if set up
    return BlocProvider(
      create: (context) => ForumCubit(
        forumRepository: context.read<ForumRepository>(),
        authRepository: context.read<AuthRepository>(),
      )..initialize(),
      child: const ForumListView(),
    );
  }
}

class ForumListView extends StatefulWidget {
  const ForumListView({super.key});

  @override
  State<ForumListView> createState() => _ForumListViewState();
}

class _ForumListViewState extends State<ForumListView> {
  void _updateAppBar(ForumState state) {
    if (!mounted) return;
    // Only update if this tab is active
    final activeTab = context.read<NavigationCubit>().state.activeTab;
    if (activeTab != AppTab.forum) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NavigationCubit>().updateAppBar(
            title: Text(
              state.view == ForumView.detail
                  ? 'Discussion'
                  : AppLocalizations.of(context).community,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                onPressed: () => context.read<ForumCubit>().resetAndReload(),
                tooltip: 'Reset Forum Data',
              ),
              if (state.hasPendingSync)
                IconButton(
                  icon: const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.warning,
                  ),
                  onPressed: () => context.read<ForumCubit>().syncWithBackend(),
                ),
            ],
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavigationCubit, NavigationState>(
      listenWhen: (prev, curr) => prev.activeTab != curr.activeTab,
      listener: (context, state) {
        if (state.activeTab == AppTab.forum) {
          _updateAppBar(context.read<ForumCubit>().state);
        }
      },
      child: BlocConsumer<ForumCubit, ForumState>(
        listener: (context, state) {
          _updateAppBar(state);
        },
        builder: (context, state) {
          // Initial update handled by initState/BlocListener
          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: const SafeArea(
                  child: EntryAnimation(
                    child: ForumBody(),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
