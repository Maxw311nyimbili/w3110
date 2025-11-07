import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';

class RoleSelectionStep extends StatelessWidget {
  const RoleSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
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
                    onPressed: () => context.read<LandingCubit>().previousStep(),
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
                            width: 140,
                            height: 140,
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
                                'assets/animations/roles.json',
                                fit: BoxFit.contain,
                                repeat: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'Who are you?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Help us personalize your experience',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: ListView(
                      children: [
                        _buildRoleCard(context, 'Expecting Mother', 'Prenatal care',
                            Icons.pregnant_woman, UserRole.expectingMother, state),
                        const SizedBox(height: 12),
                        _buildRoleCard(context, 'Healthcare Provider', 'Medical professional',
                            Icons.medical_services_outlined, UserRole.healthcareProvider, state),
                        const SizedBox(height: 12),
                        _buildRoleCard(context, 'Parent/Caregiver', 'Family care', Icons.family_restroom,
                            UserRole.parentCaregiver, state),
                        const SizedBox(height: 12),
                        _buildRoleCard(context, 'Just Exploring', 'Learning health topics', Icons.search,
                            UserRole.explorer, state),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 24),
                  child: _buildPrimaryButton(
                    onPressed: state.canProceed ? () => context.read<LandingCubit>().nextStep() : null,
                    label: 'Continue',
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleCard(BuildContext context, String title, String desc, IconData icon, UserRole role,
      LandingState state) {
    final isSelected = state.selectedRole == role;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<LandingCubit>().selectRole(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentLight : AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isSelected ? AppColors.accentPrimary : AppColors.gray200,
                width: isSelected ? 1.5 : 0.5),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 22, color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: AppTextStyles.labelLarge.copyWith(
                            color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(desc, style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary)),
                  ],
                ),
              ),
              if (isSelected) Icon(Icons.check_circle, color: AppColors.accentPrimary, size: 20),
            ],
          ),
        ),
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