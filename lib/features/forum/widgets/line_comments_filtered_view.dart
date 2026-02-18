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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                // Handle bar
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundElevated,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // ========== HEADER ==========
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                                  'Discussion',
                                  style: AppTextStyles.headlineSmall.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                
                // ========== SCROLLABLE CONTENT ==========
                Expanded(
                  child: BlocBuilder<ForumCubit, ForumState>(
                    builder: (context, state) {
                      if (state.isLoading && state.lineComments.isEmpty) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      final comments = state.lineComments;
                      print('DEBUG: LineCommentsFilteredView - Rendering ${comments.length} comments for ${widget.lineId}');
                      for (var c in comments) {
                        print('DEBUG:   - Comment ${c.id} by ${c.authorName} (${c.authorRole})');
                      }
                      final lineText = state.getLineText(widget.lineId);

                      return ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: [
                          // 1. Quoted Line (Scrolls away)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundElevated,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.format_quote_rounded, size: 20, color: AppColors.accentPrimary),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Line ${widget.lineNumber}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  lineText,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // 2. Filter Tabs (Scrolls away)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _FilterTab(
                                    label: 'All',
                                    isActive: state.activeFilter == 'all',
                                    onTap: () => context.read<ForumCubit>().filterComments('all'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: 'Clinician',
                                    icon: Icons.local_hospital_outlined,
                                    isActive: state.activeFilter == 'clinician',
                                    onTap: () => context.read<ForumCubit>().filterComments('clinician'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: 'Experience',
                                    icon: Icons.face_4_outlined,
                                    isActive: state.activeFilter == 'experience',
                                    onTap: () => context.read<ForumCubit>().filterComments('experience'),
                                  ),
                                  const SizedBox(width: 8),
                                  _FilterTab(
                                    label: 'Concern',
                                    icon: Icons.help_outline_rounded,
                                    isActive: state.activeFilter == 'concern',
                                    onTap: () => context.read<ForumCubit>().filterComments('concern'),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Divider(height: 1, color: AppColors.borderLight),

                          // 3. Comments List
                          if (comments.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble_outline_rounded, size: 48, color: AppColors.borderMedium),
                                    const SizedBox(height: 12),
                                    Text(
                                      'No discussions yet',
                                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textTertiary),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Tap below to start one',
                                      style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...comments.expand((comment) => [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: CommentCard(
                                  comment: comment,
                                  onReply: () {
                                    // Focus management
                                  },
                                ),
                              ),
                              const Divider(height: 1, indent: 20, endIndent: 20, color: AppColors.borderLight),
                            ]),
                        ],
                      );
                    },
                  ),
                ),

                // ========== FIXED REPLY INPUT ==========
                const Divider(height: 1, color: AppColors.borderLight),
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
  final IconData? icon;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accentPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? Colors.transparent : AppColors.borderMedium,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon, 
                size: 16, 
                color: isActive ? Colors.white : AppColors.textSecondary
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isActive ? Colors.white : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
