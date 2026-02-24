import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';

class ContextGatheringStep extends StatelessWidget {
  const ContextGatheringStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LandingCubit, LandingState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Theme.of(context).textTheme.bodyLarge?.color,
              onPressed: () => context.read<LandingCubit>().previousStep(),
            ),
            actions: [
              TextButton(
                onPressed: () => context.read<LandingCubit>().skipStep(),
                child: Text(
                  'Skip',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Topics of interest',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Theme.of(context).textTheme.displayLarge?.color,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Select a few to help us get started.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children:
                        [
                              'Pregnancy',
                              'Medications',
                              'Nutrition',
                              'Child Health',
                              'Mental Health',
                              'Immunizations',
                              'Postpartum',
                              'General Health',
                            ]
                            .map((label) => _buildChip(context, label, state))
                            .toList(),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => context.read<LandingCubit>().nextStep(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildChip(BuildContext context, String label, LandingState state) {
    final isSelected = state.interests.contains(label.toLowerCase());
    return InkWell(
      onTap: () {
        final cubit = context.read<LandingCubit>();
        if (isSelected) {
          cubit.removeInterest(label.toLowerCase());
        } else {
          cubit.addInterest(label.toLowerCase());
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
