import 'package:cap_project/core/theme/app_spacing.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/landing/widgets/authentication_step.dart';
import 'package:cap_project/features/landing/widgets/role_selection_step.dart';
import 'package:cap_project/features/landing/widgets/welcome_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'consent_step.dart';
import 'context_gathering_step.dart';

/// Manages the onboarding step progression
///
/// Flow: Welcome → Authentication → Role Selection → Context Gathering → Consent → Complete
class LandingBody extends StatelessWidget {
  const LandingBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildCurrentStep(context, state.currentStep),
        );
      },
    );
  }

  Widget _buildCurrentStep(BuildContext context, OnboardingStep step) {
    switch (step) {
      case OnboardingStep.welcome:
        return const WelcomeStep(key: ValueKey('welcome'));
      case OnboardingStep.authentication:
        return const AuthenticationStep(key: ValueKey('auth')); // ← NEW
      case OnboardingStep.roleSelection:
        return const RoleSelectionStep(key: ValueKey('role'));
      case OnboardingStep.contextGathering:
        return const ContextGatheringStep(key: ValueKey('context'));
      case OnboardingStep.consent:
        return const ConsentStep(key: ValueKey('consent'));
      case OnboardingStep.complete:
        return const Center(
          key: ValueKey('complete'),
          child: CircularProgressIndicator(),
        );
    }
  }
}