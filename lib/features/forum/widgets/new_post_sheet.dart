// lib/features/forum/widgets/new_post_sheet.dart
// PREMIUM DESIGN - Uses App Theme & Colors

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class NewPostSheet extends StatefulWidget {
  const NewPostSheet({super.key});

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submitPost() {
    if (!_formKey.currentState!.validate()) return;

    final authState = context.read<AuthCubit>().state;

    if (!authState.isAuthenticated || authState.user == null) {
      bool isDebugMode = false;
      assert(() {
        isDebugMode = true;
        return true;
      }());

      if (!isDebugMode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to create a post')),
        );
        return;
      }

      context.read<ForumCubit>().createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: 'debug_user_${DateTime.now().millisecondsSinceEpoch}',
        authorName: '[DEBUG] Test User',
      );
    } else {
      final user = authState.user!;

      context.read<ForumCubit>().createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: user.id,
        authorName: user.displayName ?? user.email,
      );
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.gray200,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title
                  Text(
                    'New Post',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Title input
                  TextFormField(
                    controller: _titleController,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'What\'s on your mind?',
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.gray200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.gray200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.accentPrimary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundElevated,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a title';
                      }
                      if (value.trim().length < 5) {
                        return 'Title must be at least 5 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Content input
                  TextFormField(
                    controller: _contentController,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Content',
                      hintText: 'Share your thoughts...',
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.gray200,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.gray200,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.accentPrimary,
                          width: 1.5,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.backgroundElevated,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter some content';
                      }
                      if (value.trim().length < 10) {
                        return 'Content must be at least 10 characters';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: AppColors.gray200,
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.accentPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentPrimary,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.lg,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Post',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}