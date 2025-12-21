import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/cubit.dart';

class WelcomeStep extends StatelessWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              // Minimalist Header
              Text(
                'Where knowledge\nmeets health.',
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.1,
                  letterSpacing: -1.0,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 24),
              // Subtitle
              Text(
                'Instant, accurate answers to your medical questions. Powered by advanced AI.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                ),
                textAlign: TextAlign.left,
              ),
              const Spacer(flex: 3),
              // Clean Action Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.read<LandingCubit>().nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.textPrimary, // Dark button for contrast
                    foregroundColor: AppColors.backgroundSurface,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Get Started',
                    style: AppTextStyles.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
