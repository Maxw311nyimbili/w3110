import 'package:cap_project/app/view/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/cubit.dart';
import '../../auth/widgets/google_sign_in_button.dart';

/// Authentication step - Google sign-in as part of onboarding
///
/// This appears after the welcome screen and before role selection.
/// Users must authenticate with Google to proceed with customization.
///
/// Debug: In development mode, includes a skip button to bypass auth.
class AuthenticationStep extends StatelessWidget {
  const AuthenticationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LandingCubit, LandingState>(
      listener: (context, state) {
        // Show auth errors
        if (state.authError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.authError!),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<LandingCubit>().clearError();
        }
      },
      child: BlocBuilder<LandingCubit, LandingState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Back button - aligned left only
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: state.isAuthenticating
                          ? null
                          : () => context.read<LandingCubit>().previousStep(),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // App icon - centered
                  Center(
                    child: Icon(
                      Icons.health_and_safety_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Title - centered
                  Text(
                    'Let\'s get started',
                    style: AppTextStyles.displayMedium,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Subtitle - centered
                  Text(
                    'Sign in with your Google account to personalize your experience',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),



                  const SizedBox(height: AppSpacing.xl),

                  // Google Sign-In button - centered
                  GoogleSignInButton(
                    onPressed: state.isAuthenticating
                        ? null
                        : () {
                      context
                          .read<LandingCubit>()
                          .authenticateWithGoogle();
                    },
                    isLoading: state.isAuthenticating,
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Divider(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outlineVariant
                                  .withOpacity(0.5),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: Text(
                                'Development Mode',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            BlocBuilder<LandingCubit, LandingState>(
                              builder: (context, state) {
                                return ElevatedButton.icon(
                                  onPressed: state.isAuthenticating
                                      ? null
                                      : () {
                                    // Skip auth and go to role selection (dev only)
                                    context
                                        .read<LandingCubit>()
                                        .nextStep();
                                  },
                                  icon: const Icon(Icons.bug_report),
                                  label: const Text('Skip Auth (Dev Only)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .errorContainer,
                                    foregroundColor: Theme.of(context)
                                        .colorScheme
                                        .onErrorContainer,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Center(
                              child: Text(
                                '⚠️ Remove this button before production!',
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  // Terms disclaimer - centered
                  Text(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BenefitItem extends StatelessWidget {
  const _BenefitItem({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium,
          ),
        ),
      ],
    );
  }
}