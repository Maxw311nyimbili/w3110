import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../cubit/cubit.dart';

class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.read<LandingCubit>().previousStep(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Before we begin',
                      style: AppTextStyles.displayMedium.copyWith(color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Please review and accept our terms',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildConsentCard(
                              'AI-Powered Assistance',
                              'MedLink uses AI to provide health information. Not a substitute for professional medical advice.',
                              Icons.info_outline),
                          const SizedBox(height: 12),
                          _buildConsentCard('Emergency Warning',
                              'For emergencies, call 911 or your local emergency number immediately.', Icons.warning_amber_outlined),
                          const SizedBox(height: 12),
                          _buildConsentCard('Your Privacy',
                              'Your conversations are encrypted and private. We do not share health information.',
                              Icons.shield_outlined),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: state.consentGiven,
                        onChanged: (value) {
                          context.read<LandingCubit>().giveConsent(value ?? false, AppConstants.currentConsentVersion);
                        },
                        activeColor: AppColors.accentPrimary,
                      ),
                      Expanded(
                        child: Text('I understand and agree',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPrimaryButton(
                    onPressed: state.consentGiven
                        ? () => context.read<LandingCubit>().completeOnboarding()
                        : null,
                    label: state.isLoading ? 'Loading...' : 'Get Started',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsentCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.gray200, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.accentPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    AppTextStyles.labelLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(content,
                    style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentPrimary,
            AppColors.accentPrimary.withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentPrimary.withOpacity(0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Text(
              label,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}