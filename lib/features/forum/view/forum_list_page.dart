import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/forum_body.dart';
import 'package:cap_project/features/forum/widgets/new_post_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';

class ForumListPage extends StatelessWidget {
  const ForumListPage({super.key});

  @override
  Widget build(BuildContext context) {
    // In a real app, you might inject this scope higher up or rely on auto-injection if set up
    return BlocProvider(
      create: (context) => ForumCubit(
        forumRepository: context.read<ForumRepository>(),
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
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Community'),
            centerTitle: true,
            actions: [
               if (state.hasPendingSync)
                 IconButton(
                    icon: const Icon(Icons.cloud_upload_outlined, color: AppColors.warning),
                    onPressed: () => context.read<ForumCubit>().syncWithBackend(),
                 ),
            ],
          ),
          body: const SafeArea(
            child: ForumBody(),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showNewPostSheet(context),
            icon: const Icon(Icons.add),
            label: const Text('New Post'),
            backgroundColor: AppColors.accentPrimary,
            foregroundColor: Colors.white,
            shape: const StadiumBorder(),
          ),
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
        decoration: BoxDecoration(
          color: AppColors.backgroundSurface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        // Provide the same ForumCubit to the sheet
        child: BlocProvider.value(
          value: context.read<ForumCubit>(),
          child: const NewPostSheet(),
        ),
      ),
    );
  }
}
