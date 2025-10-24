// lib/features/auth/widgets/auth_body.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/cubit.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import 'google_sign_in_button.dart';

/// Main auth screen body - handles all authentication UI
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
          // TODO: Replace with actual router navigation when backend ready
          // context.go('/chat');

          // TEMPORARY: Show success for development
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Authenticated as ${state.user?.displayName ?? state.user?.email}',
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
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
              'Welcome back',
              style: AppTextStyles.displayLarge,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Subtitle
            Text(
              'Sign in to continue to ${AppStrings.appName}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            // Google Sign-In button with loading state
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return GoogleSignInButton(
                  onPressed: state.isLoading
                      ? null
                      : () => context.read<AuthCubit>().signInWithGoogle(),
                  isLoading: state.isLoading,
                );
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // DEVELOPMENT ONLY: Bypass authentication button
            // TODO: Remove this entire button before production deployment
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                    context.read<AuthCubit>().bypassAuth();
                    // TODO: Replace with router navigation
                    Navigator.of(context).pushReplacementNamed('/chat');
                  },
                  child: Text(
                    '⚠️ DEV: Bypass Auth (Remove in Production)',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Legal disclaimer
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy',
              style: AppTextStyles.labelSmall,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}