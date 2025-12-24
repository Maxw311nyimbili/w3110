import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/cubit.dart';
import '../../auth/widgets/google_sign_in_button.dart';

class AuthenticationStep extends StatelessWidget {
  const AuthenticationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LandingCubit, LandingState>(
      listener: (context, state) {
        if (state.authError != null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(state.authError!),
            backgroundColor: AppColors.error,
          ));
          context.read<LandingCubit>().clearError();
        }
      },
      child: BlocBuilder<LandingCubit, LandingState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.backgroundPrimary,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                color: AppColors.textPrimary,
                onPressed: state.isAuthenticating
                    ? null
                    : () => context.read<LandingCubit>().previousStep(),
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      'Sign in to sync your history',
                      style: AppTextStyles.displayMedium.copyWith(
                         color: AppColors.textPrimary,
                         letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Continue with Google to start asking questions.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 48),
                    
                    // Simple, clean Google Button wrapper
                    Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.gray200),
                        borderRadius: BorderRadius.circular(30),
                        color: AppColors.backgroundSurface,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: GoogleSignInButton(
                          onPressed: state.isAuthenticating
                              ? null
                              : () => context.read<LandingCubit>().authenticateWithGoogle(),
                          isLoading: state.isAuthenticating,
                        ),
                      ),
                    ),
                    
                    const Spacer(),
                    Center(
                      child: TextButton(
                        onPressed: state.isAuthenticating 
                            ? null 
                            : () => context.read<LandingCubit>().nextStep(), // Bypass
                        child: Text(
                          'Skip for now (Dev)',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
