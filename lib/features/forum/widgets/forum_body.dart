// lib/features/forum/widgets/forum_body.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'package:cap_project/features/forum/widgets/post_card.dart';
import 'package:cap_project/features/forum/widgets/forum_detail_view.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:forum_repository/forum_repository.dart';

class ForumBody extends StatelessWidget {
  const ForumBody({super.key});

  @override
  Widget build(BuildContext context) {
        return BlocBuilder<ForumCubit, ForumState>(
          builder: (context, state) {
            if (state.view == ForumView.detail && state.selectedPost != null) {
              return ForumDetailView(post: state.selectedPost!);
            }

            return Column(
              children: [
                _buildSearchBar(context),
                Expanded(
                  child: _buildMainContent(context, state),
                ),
              ],
            );
          },
        );
      }

  Widget _buildMainContent(BuildContext context, ForumState state) {
    if (state.isLoading && !state.isSearching) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.accentPrimary,
        ),
      );
    }

    if (state.errorMessage != null && !state.isSearching) {
      return _buildErrorState(context, state);
    }

    if (state.displayPosts.isEmpty) {
      return _buildEmptyState(context, state);
    }

    return RefreshIndicator(
      color: AppColors.accentPrimary,
      onRefresh: () async {
        await context.read<ForumCubit>().syncWithBackend();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: state.displayPosts.length,
        itemBuilder: (context, index) {
          final post = state.displayPosts[index];
          return PostCard(
            post: post,
            onTap: () {
              context.read<ForumCubit>().selectPost(post);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        onChanged: (value) => context.read<ForumCubit>().searchPosts(value),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search discussions...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          filled: true,
          fillColor: AppColors.backgroundSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ForumState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.error),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).somethingWentWrong, style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text(state.errorMessage!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => context.read<ForumCubit>().initialize(),
            child: Text(AppLocalizations.of(context).tryAgain),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ForumState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            state.isSearching ? Icons.search_off_rounded : Icons.forum_outlined,
            size: 64,
            color: AppColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            state.isSearching ? 'No results found' : AppLocalizations.of(context).noPostsYet,
            style: AppTextStyles.headlineSmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            state.isSearching ? 'Try another search term' : AppLocalizations.of(context).beTheFirst,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}
