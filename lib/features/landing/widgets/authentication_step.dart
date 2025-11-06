import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/cubit.dart';
import '../../auth/widgets/google_sign_in_button.dart';

class AuthenticationStep extends StatelessWidget {
  const AuthenticationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LandingCubit, LandingState>(
      listener: (context, state) {
        if (state.authError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.authError!),
              backgroundColor: AppColors.error,
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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: state.isAuthenticating
                          ? null
                          : () => context.read<LandingCubit>().previousStep(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.lock_outline,
                        size: 32,
                        color: AppColors.accentPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Let\'s get started',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in with your Google account',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  GoogleSignInButton(
                    onPressed: state.isAuthenticating
                        ? null
                        : () {
                      context.read<LandingCubit>().authenticateWithGoogle();
                    },
                    isLoading: state.isAuthenticating,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'We only access your email and profile picture',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Builder(
                    builder: (context) {
                      bool isDebugMode = false;
                      assert(() {
                        isDebugMode = true;
                        return true;
                      }());

                      if (isDebugMode) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              height: 0.5,
                              color: AppColors.gray200,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            BlocBuilder<LandingCubit, LandingState>(
                              builder: (context, state) {
                                return ElevatedButton.icon(
                                  onPressed: state.isAuthenticating
                                      ? null
                                      : () {
                                    context.read<LandingCubit>().nextStep();
                                  },
                                  icon: const Icon(Icons.bug_report, size: 16),
                                  label: const Text('Skip (Dev)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                    AppColors.error.withOpacity(0.2),
                                    foregroundColor: AppColors.error,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}