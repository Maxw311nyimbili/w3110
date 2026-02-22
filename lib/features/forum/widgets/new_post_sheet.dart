// lib/features/forum/widgets/new_post_sheet.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_cubit.dart';
import 'package:cap_project/features/auth/cubit/auth_state.dart';
import 'package:forum_repository/forum_repository.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NewPostSheet extends StatefulWidget {
  const NewPostSheet({
    this.initialTitle,
    this.initialContent,
    this.sources = const [],
    this.originalAnswerId,
    super.key,
  });

  final String? initialTitle;
  final String? initialContent;
  final List<ForumPostSource> sources;
  final String? originalAnswerId;

  @override
  State<NewPostSheet> createState() => _NewPostSheetState();
}

class _NewPostSheetState extends State<NewPostSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      // Get real user information from AuthCubit
      final authState = context.read<AuthCubit>().state;
      final authorId = authState.user?.id ?? 'anonymous';
      final authorName = authState.user?.displayName ?? 'Anonymous';

      context.read<ForumCubit>().createPost(
        title: title,
        content: content,
        authorId: authorId,
        authorName: authorName,
        sources: widget.sources,
        originalAnswerId: widget.originalAnswerId,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Action Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context).cancel,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _submit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppLocalizations.of(context).post,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Title',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(
                            context,
                          ).discussionTitleError;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      maxLines: null,
                      style: AppTextStyles.bodyLarge.copyWith(
                        height: 1.6,
                        fontSize: 17,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Start a discussion...',
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary.withOpacity(0.5),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
