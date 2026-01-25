import 'package:cap_project/core/widgets/brand_orb.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../app/view/app_router.dart';
import '../cubit/cubit.dart';
import 'authentication_step.dart';
import 'role_selection_step.dart';
import 'profile_setup_step.dart';
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
          duration: const Duration(milliseconds: 600),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (Widget child, Animation<double> animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          child: _buildStep(context, state.currentStep),
        );
      },
    );
  }

  Widget _buildStep(BuildContext context, OnboardingStep step) {
    switch (step) {
      case OnboardingStep.roleSelection:
        return const RoleSelectionStep(key: ValueKey('role'));
      case OnboardingStep.profileSetup:
        return const ProfileSetupStep(key: ValueKey('profile_setup'));
      case OnboardingStep.contextGathering:
        return const ContextGatheringStep(key: ValueKey('context'));
      case OnboardingStep.consent:
        return const ConsentStep(key: ValueKey('consent'));
      case OnboardingStep.complete:
        return const _CompleteStep(key: ValueKey('complete'));
      case OnboardingStep.authentication:
        // This should not happen in the formal LandingPage anymore as per new flow
        return const RoleSelectionStep(key: ValueKey('role'));
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const BrandOrb(size: 140),
              const SizedBox(height: 48),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Column(
                      children: [
                        Text(
                          'You\'re all set!',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Personalizing your health guide based on your role and preferences...',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 64),
              PremiumButton(
                onPressed: () => AppRouter.replaceTo(context, AppRouter.chat),
                text: 'Start Chatting',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
