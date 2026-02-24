import 'dart:ui';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/widgets/brand_logo.dart';
import 'package:cap_project/features/auth/widgets/google_sign_in_button.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/landing/cubit/landing_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WelcomeDrawer extends StatelessWidget {
  const WelcomeDrawer({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const WelcomeDrawer(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Premium Handle Bar (like forum comments)
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 48),
                child: BlocListener<LandingCubit, LandingState>(
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

                    if (state.userName != null && !state.isGuest) {
                      Navigator.of(context).pop(); // Close drawer

                      // If onboarding is already marked complete in the state,
                      // we don't need to go to landing again.
                      if (state.currentStep == OnboardingStep.complete) {
                        // User is already done, just stay on Chat (the page under the drawer)
                        print(
                          '✅ User already onboarded, staying on current page',
                        );
                      } else {
                        AppRouter.replaceTo<void>(
                          context,
                          AppRouter.landing,
                          arguments: {
                            'initialStep': OnboardingStep.roleSelection,
                          },
                        );
                      }
                    }
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const BrandLogo(size: 80),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome to Thanzi',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Theme.of(context).textTheme.displayLarge?.color,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your companion for maternal health. Dive into chatting or sign in to sync your journey.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 40),
                      BlocBuilder<LandingCubit, LandingState>(
                        builder: (context, state) {
                          return Column(
                            children: [
                              GoogleSignInButton(
                                onPressed: state.isAuthenticating
                                    ? null
                                    : () => context
                                          .read<LandingCubit>()
                                          .authenticateWithGoogle(),
                                isLoading: state.isAuthenticating,
                              ),
                              if (state.isDemoAvailable) ...[
                                const SizedBox(height: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.accentPrimary.withOpacity(
                                      0.05,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TextButton(
                                    onPressed: () => context
                                        .read<LandingCubit>()
                                        .authenticateAsDemo(),
                                    child: Text(
                                      'DEMO LOGIN (DEVELOPER BYPASS)',
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        color: Theme.of(context).colorScheme.primary,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Close Button (Glass Circle)
          Positioned(
            top: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
