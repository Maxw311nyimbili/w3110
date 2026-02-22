import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/core/widgets/glass_card.dart';

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
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, _) => Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(0, 20 * (1 - value)),
                        child: Text(
                          'Select your role',
                          style: AppTextStyles.displayMedium.copyWith(
                            color: AppColors.textPrimary,
                            letterSpacing: -1.0,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Expanded(
                    child: ListView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        _buildRoleItem(
                          context,
                          'Mother',
                          UserRole.mother,
                          state,
                          'I am expecting or have children',
                          index: 0,
                        ),
                        _buildRoleItem(
                          context,
                          'Support Partner',
                          UserRole.supportPartner,
                          state,
                          'I am supporting a mother',
                          index: 1,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(height: 1),
                        ),
                        _buildRoleItem(
                          context,
                          'Doctor',
                          UserRole.doctor,
                          state,
                          'Verified medical professional',
                          isProfessional: true,
                          index: 2,
                        ),
                        _buildRoleItem(
                          context,
                          'Midwife',
                          UserRole.midwife,
                          state,
                          'Verified birth professional',
                          isProfessional: true,
                          index: 3,
                        ),
                        _buildRoleItem(
                          context,
                          'Clinician',
                          UserRole.clinician,
                          state,
                          'Healthcare facility staff',
                          isProfessional: true,
                          index: 4,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: PremiumButton(
                      onPressed: state.canProceed
                          ? () => context.read<LandingCubit>().nextStep()
                          : null,
                      text: 'Continue',
                    ),
                  ),
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
    String subtitle, {
    bool isProfessional = false,
    required int index,
  }) {
    final isSelected = state.selectedRole == role;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: InkWell(
          onTap: () => context.read<LandingCubit>().selectRole(role),
          borderRadius: BorderRadius.circular(24),
          child: AnimatedScale(
            scale: isSelected ? 1.02 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GlassCard(
              padding: const EdgeInsets.all(20),
              borderRadius: 24,
              borderOpacity: isSelected ? 0.6 : 0.2,
              tintOpacity: isSelected ? 0.88 : 0.72,
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
                                color: isSelected
                                    ? AppColors.accentPrimary
                                    : AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
                        color: isSelected
                            ? AppColors.accentPrimary
                            : AppColors.borderLight,
                        width: 2,
                      ),
                      color: isSelected
                          ? AppColors.accentPrimary
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
