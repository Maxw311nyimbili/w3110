// lib/features/landing/widgets/context_gathering_step.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_strings.dart';
import '../cubit/cubit.dart';

/// Optional context gathering - interests and topics
class ContextGatheringStep extends StatelessWidget {
  const ContextGatheringStep({super.key});

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
                'What brings you here today?',
                style: AppTextStyles.displayMedium,
              ),

              const SizedBox(height: AppSpacing.md),

              // Subtitle
              Text(
                'Select topics that interest you (optional)',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Interest chips
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _InterestChip(
                        label: 'Pregnancy & Prenatal Care',
                        isSelected: state.interests.contains('pregnancy'),
                        onTap: () => _toggleInterest(context, 'pregnancy'),
                      ),
                      _InterestChip(
                        label: 'Medication Safety',
                        isSelected: state.interests.contains('medication'),
                        onTap: () => _toggleInterest(context, 'medication'),
                      ),
                      _InterestChip(
                        label: 'Nutrition & Diet',
                        isSelected: state.interests.contains('nutrition'),
                        onTap: () => _toggleInterest(context, 'nutrition'),
                      ),
                      _InterestChip(
                        label: 'Child Development',
                        isSelected: state.interests.contains('child_development'),
                        onTap: () => _toggleInterest(context, 'child_development'),
                      ),
                      _InterestChip(
                        label: 'Mental Health',
                        isSelected: state.interests.contains('mental_health'),
                        onTap: () => _toggleInterest(context, 'mental_health'),
                      ),
                      _InterestChip(
                        label: 'Immunizations',
                        isSelected: state.interests.contains('immunizations'),
                        onTap: () => _toggleInterest(context, 'immunizations'),
                      ),
                      _InterestChip(
                        label: 'Postpartum Care',
                        isSelected: state.interests.contains('postpartum'),
                        onTap: () => _toggleInterest(context, 'postpartum'),
                      ),
                      _InterestChip(
                        label: 'General Health',
                        isSelected: state.interests.contains('general_health'),
                        onTap: () => _toggleInterest(context, 'general_health'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => context.read<LandingCubit>().skipStep(),
                      child: const Text(AppStrings.skip),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => context.read<LandingCubit>().nextStep(),
                      child: const Text(AppStrings.next),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }

  void _toggleInterest(BuildContext context, String interest) {
    final cubit = context.read<LandingCubit>();
    final state = cubit.state;

    if (state.interests.contains(interest)) {
      cubit.removeInterest(interest);
    } else {
      cubit.addInterest(interest);
    }
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.gray100,
      selectedColor: AppColors.accentPrimary,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isSelected
            ? BorderSide.none
            : const BorderSide(color: AppColors.gray300),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
  }
}