// lib/features/forum/widgets/new_post_sheet.dart - WITH DEBUG BYPASS

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';

/// Bottom sheet for creating a new forum post
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

    // Check if user is authenticated
    if (!authState.isAuthenticated || authState.user == null) {
      // DEBUG: Allow posting without auth in debug mode
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

      // DEBUG MODE: Use mock user
      context.read<ForumCubit>().createPost(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        authorId: 'debug_user_${DateTime.now().millisecondsSinceEpoch}',
        authorName: '[DEBUG] Test User',
      );
    } else {
      // PRODUCTION: Use authenticated user
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
    return Padding(
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
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Title
                Text(
                  'New Post',
                  style: AppTextStyles.headlineLarge,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Title input
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'What\'s on your mind?',
                  ),
                  textCapitalization: TextCapitalization.sentences,
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
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    hintText: 'Share your thoughts...',
                    alignLabelWithHint: true,
                  ),
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
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
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _submitPost,
                        child: const Text('Post'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}