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
import 'package:cap_project/core/widgets/main_navigation_shell.dart';
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

class ForumListView extends StatelessWidget {
  const ForumListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        return MainNavigationShell(
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
          child: Center(
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
    );
  }
}
