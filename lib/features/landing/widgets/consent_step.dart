// lib/features/landing/widgets/consent_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_constants.dart';
import '../cubit/cubit.dart';

/// Medical disclaimer and consent screen
class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.screenHorizontalLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Back button
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.read<LandingCubit>().previousStep(),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Before we begin',
                style: AppTextStyles.displayMedium,
              ),

              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Please review and accept our terms',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Consent content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ConsentCard(
                        icon: Icons.info_outline,
                        title: 'AI-Powered Assistance',
                        content:
                        'MedLink uses artificial intelligence to provide health information. '
                            'Responses are generated based on medical knowledge but should not '
                            'replace professional medical advice.',
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _ConsentCard(
                        icon: Icons.warning_amber_outlined,
                        title: 'Not a Substitute for Medical Care',
                        content:
                        'This app does not provide medical diagnoses or treatment. '
                            'Always consult qualified healthcare professionals for medical decisions. '
                            'In emergencies, call your local emergency number immediately.',
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _ConsentCard(
                        icon: Icons.shield_outlined,
                        title: 'Your Privacy Matters',
                        content:
                        'We protect your data with encryption and secure storage. '
                            'Your conversations are private and used only to improve your experience. '
                            'We do not share personal health information without consent.',
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _ConsentCard(
                        icon: Icons.verified_user_outlined,
                        title: 'Evidence-Based Information',
                        content:
                        'Our responses cite trusted medical sources and indicate confidence levels. '
                            'Lower confidence responses should be verified with healthcare providers.',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Consent checkbox
              CheckboxListTile(
                value: state.consentGiven,
                onChanged: (value) {
                  context.read<LandingCubit>().giveConsent(
                    value ?? false,
                    AppConstants.currentConsentVersion,
                  );
                },
                title: Text(
                  'I understand and agree to these terms',
                  style: AppTextStyles.bodyMedium,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.accentPrimary,
                contentPadding: EdgeInsets.zero,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Continue button
              ElevatedButton(
                onPressed: state.canProceed
                    ? () => context.read<LandingCubit>().completeOnboarding()
                    : null,
                child: state.isLoading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text('Get Started'),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _ConsentCard extends StatelessWidget {
  const _ConsentCard({
    required this.icon,
    required this.title,
    required this.content,
  });

  final IconData icon;
  final String title;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: AppColors.accentPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.headlineMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  content,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}