// lib/features/forum/widgets/line_comments_filtered_view.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/forum/cubit/forum_state.dart';
import 'comment_card.dart';
import 'reply_input_field_for_modal.dart';

class LineCommentsFilteredView extends StatefulWidget {
  final String lineId;
  final int lineNumber;

  const LineCommentsFilteredView({
    super.key,
    required this.lineId,
    required this.lineNumber,
  });

  @override
  State<LineCommentsFilteredView> createState() => _LineCommentsFilteredViewState();
}

class _LineCommentsFilteredViewState extends State<LineCommentsFilteredView> {
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: AppColors.backgroundSurface,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: Column(
              children: [
                // ========== FIXED HEADER ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: BlocBuilder<ForumCubit, ForumState>(
                          builder: (context, state) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Sentence Discussion',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Line ${widget.lineNumber}',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textTertiary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // ========== SCROLLABLE CONTENT ==========
                Expanded(
                  child: BlocBuilder<ForumCubit, ForumState>(
                    builder: (context, state) {
                      if (state.isLoading && state.lineComments.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final comments = state.lineComments;
                      final lineText = state.getLineText(widget.lineId);

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // 1. Quoted Line (Scrolls away)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.accentPrimary.withOpacity(0.05),
                              border: const Border(left: BorderSide(color: AppColors.accentPrimary, width: 3)),
                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                            ),
                            child: Text(
                              '"$lineText"',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 4,
                            ),
                          ),

                          // 2. Filter Tabs (Scrolls away)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterTab(
                                    label: 'All',
                                    value: 'all',
                                    isActive: state.activeFilter == 'all',
                                    onTap: () => context.read<ForumCubit>().filterComments('all'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: '⚕️ Clinician',
                                    value: 'clinician',
                                    isActive: state.activeFilter == 'clinician',
                                    onTap: () => context.read<ForumCubit>().filterComments('clinician'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: '💬 Experience',
                                    value: 'experience',
                                    isActive: state.activeFilter == 'experience',
                                    onTap: () => context.read<ForumCubit>().filterComments('experience'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: '⚠️ Concern',
                                    value: 'concern',
                                    isActive: state.activeFilter == 'concern',
                                    onTap: () => context.read<ForumCubit>().filterComments('concern'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1),

                          // 3. Comments List
                          if (comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.gray300),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No comments yet',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...comments.expand((comment) => [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: CommentCard(
                                  comment: comment,
                                  onReply: () {
                                    // Focus management
                                  },
                                ),
                              ),
                              const Divider(height: 1, indent: 16, endIndent: 16),
                            ]),
                        ],
                      );
                    },
                  ),
                ),

                // ========== FIXED REPLY INPUT ==========
                const Divider(height: 1),
                ReplyInputFieldForModal(lineId: widget.lineId),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final String value;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.value,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentPrimary.withOpacity(0.1) : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.accentPrimary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isActive ? AppColors.accentPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
