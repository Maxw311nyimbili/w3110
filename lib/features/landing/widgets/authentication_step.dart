import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.authError!),
            backgroundColor: AppColors.error,
          ));
          context.read<LandingCubit>().clearError();
        }
      },
      child: BlocBuilder<LandingCubit, LandingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundPrimary,
            body: SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: state.isAuthenticating
                          ? null
                          : () => context.read<LandingCubit>().previousStep(),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accentPrimary.withOpacity(0.08),
                                    blurRadius: 32,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Lottie.asset(
                                  'assets/animations/shield.json',
                                  fit: BoxFit.contain,
                                  repeat: true,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              "Let's get started",
                              style: AppTextStyles.displayMedium.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Sign in with your Google account',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        GoogleSignInButton(
                          onPressed: state.isAuthenticating
                              ? null
                              : () => context.read<LandingCubit>().authenticateWithGoogle(),
                          isLoading: state.isAuthenticating,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'We only access your email and profile picture',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
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
                                    color: AppColors.gray200.withOpacity(0.3),
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
                                          backgroundColor: AppColors.error.withOpacity(0.2),
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}