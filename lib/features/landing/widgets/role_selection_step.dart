// lib/features/landing/widgets/role_selection_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/cubit.dart';

/// Role selection screen - user picks their primary role
class RoleSelectionStep extends StatelessWidget {
  const RoleSelectionStep({super.key});

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

              // Title
              Text(
                AppStrings.onboardingRoleTitle,
                style: AppTextStyles.displayMedium,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Role options
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      icon: Icons.pregnant_woman,
                      title: AppStrings.onboardingRoleExpectingMother,
                      description: 'Prenatal care and pregnancy guidance',
                      role: UserRole.expectingMother,
                      isSelected: state.selectedRole == UserRole.expectingMother,
                      onTap: () => context.read<LandingCubit>().selectRole(
                        UserRole.expectingMother,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _RoleCard(
                      icon: Icons.medical_services_outlined,
                      title: AppStrings.onboardingRoleHealthcare,
                      description: 'Medical professionals and clinicians',
                      role: UserRole.healthcareProvider,
                      isSelected: state.selectedRole == UserRole.healthcareProvider,
                      onTap: () => context.read<LandingCubit>().selectRole(
                        UserRole.healthcareProvider,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _RoleCard(
                      icon: Icons.family_restroom,
                      title: AppStrings.onboardingRoleParent,
                      description: 'Parents, guardians, and caregivers',
                      role: UserRole.parentCaregiver,
                      isSelected: state.selectedRole == UserRole.parentCaregiver,
                      onTap: () => context.read<LandingCubit>().selectRole(
                        UserRole.parentCaregiver,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    _RoleCard(
                      icon: Icons.search,
                      title: AppStrings.onboardingRoleExplorer,
                      description: 'Learning and exploring health topics',
                      role: UserRole.explorer,
                      isSelected: state.selectedRole == UserRole.explorer,
                      onTap: () => context.read<LandingCubit>().selectRole(
                        UserRole.explorer,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Continue button
              ElevatedButton(
                onPressed: state.canProceed
                    ? () => context.read<LandingCubit>().nextStep()
                    : null,
                child: const Text(AppStrings.next),
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isSelected
            ? const BorderSide(color: AppColors.accentPrimary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentLight
                      : AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: isSelected
                      ? AppColors.accentPrimary
                      : AppColors.textSecondary,
                ),
              ),

              const SizedBox(width: AppSpacing.lg),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      description,
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.accentPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}