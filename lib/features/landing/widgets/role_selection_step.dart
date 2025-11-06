import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.read<LandingCubit>().previousStep(),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Who are you?',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Help us personalize your experience',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      icon: Icons.pregnant_woman,
                      title: 'Expecting Mother',
                      description: 'Prenatal care',
                      role: UserRole.expectingMother,
                      isSelected: state.selectedRole == UserRole.expectingMother,
                      onTap: () => context.read<LandingCubit>().selectRole(UserRole.expectingMother),
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      icon: Icons.medical_services_outlined,
                      title: 'Healthcare Provider',
                      description: 'Medical professional',
                      role: UserRole.healthcareProvider,
                      isSelected: state.selectedRole == UserRole.healthcareProvider,
                      onTap: () => context.read<LandingCubit>().selectRole(UserRole.healthcareProvider),
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      icon: Icons.family_restroom,
                      title: 'Parent/Caregiver',
                      description: 'Family care',
                      role: UserRole.parentCaregiver,
                      isSelected: state.selectedRole == UserRole.parentCaregiver,
                      onTap: () => context.read<LandingCubit>().selectRole(UserRole.parentCaregiver),
                    ),
                    const SizedBox(height: 12),
                    _RoleCard(
                      icon: Icons.search,
                      title: 'Just Exploring',
                      description: 'Learning health topics',
                      role: UserRole.explorer,
                      isSelected: state.selectedRole == UserRole.explorer,
                      onTap: () => context.read<LandingCubit>().selectRole(UserRole.explorer),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: state.canProceed ? () => context.read<LandingCubit>().nextStep() : null,
                child: const Text('Continue'),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentLight : AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.accentPrimary : AppColors.gray200,
              width: isSelected ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : AppColors.gray100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppColors.accentPrimary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}