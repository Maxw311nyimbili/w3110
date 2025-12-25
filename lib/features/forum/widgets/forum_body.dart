// lib/features/forum/widgets/forum_body.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/post_card.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForumBody extends StatelessWidget {
  const ForumBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForumCubit, ForumState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.accentPrimary,
            ),
          );
        }

        if (state.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: AppColors.error,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).somethingWentWrong,
                  style: AppTextStyles.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage!,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => context.read<ForumCubit>().initialize(),
                  child: Text(AppLocalizations.of(context).tryAgain),
                ),
              ],
            ),
          );
        }

        if (state.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.forum_outlined,
                  size: 64,
                  color: AppColors.textTertiary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).noPostsYet,
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).beTheFirst,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.accentPrimary,
          onRefresh: () async {
            await context.read<ForumCubit>().syncWithBackend();
          },
          child: ListView.builder(
            itemCount: state.posts.length,
            itemBuilder: (context, index) {
              final post = state.posts[index];
              return PostCard(
                post: post,
                onTap: () {
                  // Navigate to details (implementation pending in Cubit/Router)
                  // For now, just print or show snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Tapped ${post.title}'))
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
