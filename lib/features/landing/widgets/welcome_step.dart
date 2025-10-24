// lib/features/landing/widgets/welcome_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/cubit.dart';

/// Welcome screen - first step of onboarding
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),

          // App logo or illustration would go here
          Icon(
            Icons.health_and_safety_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Title
          Text(
            AppStrings.onboardingWelcomeTitle,
            style: AppTextStyles.displayLarge,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSpacing.lg),

          // Subtitle
          Text(
            AppStrings.onboardingWelcomeSubtitle,
            style: AppTextStyles.bodyLarge.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // Get Started button
          ElevatedButton(
            onPressed: () => context.read<LandingCubit>().nextStep(),
            child: const Text('Get Started'),
          ),

          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}