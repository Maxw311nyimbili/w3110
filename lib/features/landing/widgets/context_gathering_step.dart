import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';

class ContextGatheringStep extends StatefulWidget {
  const ContextGatheringStep({super.key});

  @override
  State<ContextGatheringStep> createState() => _ContextGatheringStepState();
}

class _ContextGatheringStepState extends State<ContextGatheringStep>
    with TickerProviderStateMixin {
  late AnimationController _lottieController;
  late Animation<double> _lottieFadeAnimation;

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    )..repeat();

    _lottieFadeAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(
        parent: _lottieController,
        curve: const Interval(0.75, 1.0, curve: Curves.easeInQuad),
      ),
    );
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

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
                            width: 160,
                            height: 160,
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
                              child: AnimatedBuilder(
                                animation: _lottieFadeAnimation,
                                builder: (context, child) {
                                  return Opacity(
                                    opacity: _lottieFadeAnimation.value,
                                    child: Lottie.asset(
                                      'assets/animations/interests.json',
                                      fit: BoxFit.contain,
                                      repeat: true,
                                      controller: _lottieController,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text(
                            'What interests you?',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Select topics (optional)',
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
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: [
                          'Pregnancy',
                          'Medications',
                          'Nutrition',
                          'Child Health',
                          'Mental Health',
                          'Immunizations',
                          'Postpartum',
                          'General Health',
                        ]
                            .map((label) => _buildInterestChip(context, label, state))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPrimaryButton(
                        onPressed: () => context.read<LandingCubit>().nextStep(),
                        label: 'Continue',
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => context.read<LandingCubit>().skipStep(),
                        child: Text(
                          'Skip for now',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInterestChip(BuildContext context, String label, LandingState state) {
    final isSelected = state.interests.contains(label.toLowerCase());
    return Material(
      color: Colors.transparent,
      child: InkWell(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentPrimary : AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.accentPrimary : AppColors.gray200.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: AppColors.accentPrimary.withOpacity(0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
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
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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