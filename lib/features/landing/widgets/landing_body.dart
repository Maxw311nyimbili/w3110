import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';
import 'welcome_step.dart';
import 'authentication_step.dart';
import 'role_selection_step.dart';
import 'context_gathering_step.dart';
import 'consent_step.dart';

class LandingBody extends StatelessWidget {
  const LandingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppColors.textPrimary,
                strokeWidth: 2,
              ),
            ),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildStep(context, state.currentStep),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeStep(key: ValueKey('welcome'));
      case OnboardingStep.authentication:
        return const AuthenticationStep(key: ValueKey('auth'));
      case OnboardingStep.roleSelection:
        return const RoleSelectionStep(key: ValueKey('role'));
      case OnboardingStep.contextGathering:
        return const ContextGatheringStep(key: ValueKey('context'));
      case OnboardingStep.consent:
        return const ConsentStep(key: ValueKey('consent'));
      case OnboardingStep.complete:
        return const _CompleteStep(key: ValueKey('complete'));
    }
  }
}

class _CompleteStep extends StatelessWidget {
  const _CompleteStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.textPrimary, // Stark black/dark circle
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 48, color: AppColors.backgroundSurface),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(
              color: AppColors.textPrimary,
              strokeWidth: 2,
            ),
            const SizedBox(height: 20),
            Text(
              'Personalizing your experience...',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
