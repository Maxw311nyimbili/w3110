// lib/features/forum/widgets/new_post_sheet.dart

import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/features/forum/cubit/forum_cubit.dart';
import 'package:cap_project/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final title = _titleController.text.trim();
      final content = _contentController.text.trim();

      // Assuming auth is handled elsewhere or anonymous
      // In a real app, get currentUser ID
      const fakeAuthorId = 'user_123'; 
      const fakeAuthorName = 'You';

      context.read<ForumCubit>().createPost(
        title: title,
        content: content,
        authorId: fakeAuthorId,
        authorName: fakeAuthorName,
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 80,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(
                      AppLocalizations.of(context).cancel,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).newDiscussion,
                    style: AppTextStyles.headlineSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(0, 36),
                      ),
                      child: Text(
                        AppLocalizations.of(context).post,
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              autofocus: true,
              style: AppTextStyles.headlineSmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).discussionTitleHint,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppLocalizations.of(context).discussionTitleError;
                }
                return null;
              },
            ),
            const Divider(),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxHeight: 200,
                minHeight: 100,
              ),
              child: TextFormField(
                controller: _contentController,
                maxLines: null,
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context).discussionContentHint,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

