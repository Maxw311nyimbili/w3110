// lib/features/auth/widgets/auth_body.dart - FIXED FOR YOUR ROUTER

import 'package:cap_project/app/view/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import 'google_sign_in_button.dart';

/// Main auth screen body - handles all authentication UI
///
/// Authentication flow handled here:
/// 1. User taps "Continue with Google"
/// 2. AuthCubit triggers signInWithGoogle()
/// 3. Firebase Sign-In dialog appears
/// 4. User selects Google account
/// 5. Firebase returns ID token
/// 6. ID token exchanged with backend for JWT tokens
/// 7. User authenticated state emitted
/// 8. Navigation to chat screen
class AuthBody extends StatelessWidget {
  const AuthBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Show error messages
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<AuthCubit>().clearError();
        }

        // Navigate to main app when authenticated
        if (state.isAuthenticated) {
          // Navigate to chat screen after successful authentication
          // The user is now authenticated with:
          // - Access token stored securely
          // - Refresh token stored securely
          // - User info available in state.user
          if (context.mounted) {
            AppRouter.replaceTo(context, AppRouter.chat);
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),

            // App branding
            Icon(
              Icons.health_and_safety_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Welcome title
            Text(
              'Welcome to ${AppStrings.appName}',
              style: AppTextStyles.displayLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              'Your personal medical assistant',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.lg),

            // Description
            Text(
              'Sign in with your Google account to get started with personalized medical Q&A, community forums, and more.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // ============ Google Sign-In Section ============

            // Google Sign-In button with loading state
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Main sign-in button
                    GoogleSignInButton(
                      onPressed: state.isLoading
                          ? null
                          : () {
                              // Trigger Google Sign-In flow
                              context.read<AuthCubit>().signInWithGoogle();
                            },
                      isLoading: state.isLoading,
                    ),

                    // Loading indicator with text
                    if (state.isLoading) ...[
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Signing you in...',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ============ Debug Helper (Optional) ============

            // Development mode helper - shows skip button in debug builds
            Builder(
              builder: (context) {
                // Check if we're in debug mode
                bool isDebugMode = false;
                assert(() {
                  isDebugMode = true;
                  return true;
                }());

                if (isDebugMode) {
                  return Column(
                    children: [
                      Divider(
                        color: Theme.of(
                          context,
                        ).colorScheme.outlineVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Development Mode',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, state) {
                          return ElevatedButton.icon(
                            onPressed: state.isLoading
                                ? null
                                : () {
                                    // Skip auth and go directly to chat (dev only)
                                    AppRouter.replaceTo(
                                      context,
                                      AppRouter.chat,
                                    );
                                  },
                            icon: const Icon(Icons.bug_report),
                            label: const Text('Skip Auth (Dev Only)'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.errorContainer,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '⚠️ Remove this button before production!',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // ============ Legal Disclaimer ============
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy',
              style: AppTextStyles.labelSmall.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Security info
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Your data is encrypted and secure. We only access your email and profile picture.',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}
