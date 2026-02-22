import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/widgets/brand_logo.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/auth/widgets/google_sign_in_button.dart';

class AuthenticationStep extends StatelessWidget {
  const AuthenticationStep({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LandingCubit, LandingState>(
      listener: (context, state) {
        if (state.authError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.authError!),
              backgroundColor: AppColors.error,
            ),
          );
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
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: state.isAuthenticating
                      ? null
                      : () => context.read<LandingCubit>().continueAsGuest(),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Brand Identity Character (Orb) & Welcome
                    _buildStaggeredEntrance(
                      delay: 100,
                      child: Column(
                        children: [
                          const BrandLogo(size: 140),
                          const SizedBox(height: 32),
                          Text(
                            'Welcome to Thanzi',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textPrimary,
                              letterSpacing: -1.0,
                              fontWeight: FontWeight.w800,
                              fontSize: 34,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Staggered Subtitle
                    _buildStaggeredEntrance(
                      delay: 300,
                      child: Text(
                        'Secure your medical history and personalize your health companion by signing in.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Main Sign-In Action
                    _buildStaggeredEntrance(
                      delay: 500,
                      child: Container(
                        height: 60,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderLight.withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(30),
                          color: AppColors.backgroundSurface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: GoogleSignInButton(
                            onPressed: state.isAuthenticating
                                ? null
                                : () => context
                                      .read<LandingCubit>()
                                      .authenticateWithGoogle(),
                            isLoading: state.isAuthenticating,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Guest / Dismiss Action
                    _buildStaggeredEntrance(
                      delay: 600,
                      child: TextButton(
                        onPressed: state.isAuthenticating
                            ? null
                            : () => context
                                  .read<LandingCubit>()
                                  .continueAsGuest(),
                        child: Text(
                          'Continue as Guest',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    if (state.isDemoAvailable)
                      _buildStaggeredEntrance(
                        delay: 700,
                        child: Center(
                          child: TextButton(
                            onPressed: state.isAuthenticating
                                ? null
                                : () => context
                                      .read<LandingCubit>()
                                      .authenticateAsDemo(),
                            child: Text(
                              'Demo Login (Developer Bypass)',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.textTertiary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStaggeredEntrance({required Widget child, required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }
}
