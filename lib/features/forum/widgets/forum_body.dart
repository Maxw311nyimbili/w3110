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
            _buildFilterToggle(context, state),
            Expanded(
              child: _buildMainContent(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterToggle(BuildContext context, ForumState state) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildAppleStyleButton(
              context,
              label: 'All Posts',
              isSelected: state.postFilter == PostFilter.all,
              onTap: () =>
                  context.read<ForumCubit>().setPostFilter(PostFilter.all),
            ),
          ),
          Expanded(
            child: _buildAppleStyleButton(
              context,
              label: 'My Posts',
              isSelected: state.postFilter == PostFilter.mine,
              onTap: () =>
                  context.read<ForumCubit>().setPostFilter(PostFilter.mine),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleStyleButton(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
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

    // Get filtered posts based on current filter
    final cubit = context.read<ForumCubit>();

    return FutureBuilder<String>(
      future: cubit.getCurrentUserId(),
      builder: (context, snapshot) {
        final userId = snapshot.data ?? '';
        final displayPosts = state.isSearching
            ? state.searchResults
            : cubit.getFilteredPosts(userId);

        if (displayPosts.isEmpty) {
          return _buildEmptyState(context, state);
        }

        return RefreshIndicator(
          color: AppColors.accentPrimary,
          onRefresh: () async {
            await context.read<ForumCubit>().loadPosts();
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 24),
            itemCount: displayPosts.length + (state.isSearching ? 1 : 0),
            itemBuilder: (context, index) {
              if (state.isSearching && index == 0) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: AppColors.accentPrimary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended for You',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.accentPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final post = displayPosts[state.isSearching ? index - 1 : index];
              return PostCard(
                post: post,
                currentUserId: userId,
                onTap: () {
                  context.read<ForumCubit>().selectPost(post);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        onChanged: (value) => context.read<ForumCubit>().searchPosts(value),
        style: AppTextStyles.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Search or ask for recommendations...',
          hintStyle: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          filled: true,
          fillColor: AppColors.backgroundSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: AppColors.borderLight,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(28),
            borderSide: const BorderSide(
              color: AppColors.accentPrimary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ForumState state) {
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
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
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

  Widget _buildEmptyState(BuildContext context, ForumState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              state.isSearching
                  ? Icons.search_off_rounded
                  : Icons.forum_outlined,
              size: 64,
              color: AppColors.textTertiary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              state.isSearching ? 'No results found' : 'Community is quiet',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.isSearching
                  ? 'Try another search term'
                  : 'Discussions start from your consultations. Chat with AI to share a finding.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            if (!state.isSearching) ...[
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  // TODO: Navigate to Chat Tab (index 1)
                  // context.read<HomeCubit>().setTab(1);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.accentPrimary,
                  side: const BorderSide(color: AppColors.accentPrimary),
                  shape: const StadiumBorder(),
                ),
                child: const Text('Go to Chat'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
