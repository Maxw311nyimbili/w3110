import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                        _buildRoleItem(context, 'Expecting Mother', UserRole.expectingMother, state),
                        _buildRoleItem(context, 'Healthcare Provider', UserRole.healthcareProvider, state),
                        _buildRoleItem(context, 'Parent/Caregiver', UserRole.parentCaregiver, state),
                        _buildRoleItem(context, 'Just Exploring', UserRole.explorer, state),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: state.canProceed 
                          ? () => context.read<LandingCubit>().nextStep() 
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.textPrimary,
                        foregroundColor: AppColors.backgroundSurface,
                        disabledBackgroundColor: AppColors.gray300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text('Continue'),
                    ),
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

  Widget _buildRoleItem(BuildContext context, String title, UserRole role, LandingState state) {
    final isSelected = state.selectedRole == role;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => context.read<LandingCubit>().selectRole(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.backgroundSurface : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.textPrimary : AppColors.gray300,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (isSelected) 
                const Icon(Icons.check_circle, size: 20, color: AppColors.textPrimary),
            ],
          ),
        ),
      ),
    );
  }
}
