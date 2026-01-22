import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';

class RoleSelectionStep extends StatelessWidget {
  const RoleSelectionStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
              onPressed: () => context.read<LandingCubit>().previousStep(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Select your role',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildRoleItem(context, 'Mother', UserRole.mother, state, 'I am expecting or have children'),
                        _buildRoleItem(context, 'Support Partner', UserRole.supportPartner, state, 'I am supporting a mother'),
                        const Divider(height: 32),
                        _buildRoleItem(context, 'Doctor', UserRole.doctor, state, 'Verified medical professional', isProfessional: true),
                        _buildRoleItem(context, 'Midwife', UserRole.midwife, state, 'Verified birth professional', isProfessional: true),
                        _buildRoleItem(context, 'Clinician', UserRole.clinician, state, 'Healthcare facility staff', isProfessional: true),
                      ],
                    ),
                  ),
                  PremiumButton(
                    onPressed: state.canProceed 
                        ? () => context.read<LandingCubit>().nextStep() 
                        : null,
                    text: 'Continue',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleItem(
    BuildContext context, 
    String title, 
    UserRole role, 
    LandingState state,
    String subtitle,
    {bool isProfessional = false}
  ) {
    final isSelected = state.selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () => context.read<LandingCubit>().selectRole(role),
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundSurface,
            border: Border.all(
              color: isSelected ? AppColors.accentPrimary : AppColors.borderLight,
              width: isSelected ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: isSelected 
                    ? Colors.black.withOpacity(0.05) 
                    : Colors.black.withOpacity(0.02),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: isSelected ? AppColors.accentPrimary : AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (isProfessional) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.accentPrimary : AppColors.backgroundElevated,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.borderLight, width: 0.5),
                            ),
                            child: Text(
                              'PRO',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w800,
                                fontSize: 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppColors.accentPrimary : AppColors.borderLight,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.accentPrimary : Colors.transparent,
                ),
                child: isSelected 
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
