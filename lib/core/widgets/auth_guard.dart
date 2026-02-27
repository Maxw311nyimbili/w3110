import 'package:cap_project/app/cubit/navigation_cubit.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/core/theme/app_colors.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthGuard extends StatelessWidget {
  const AuthGuard({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state.isAuthenticated) {
          return child;
        }

        // Feature Locked state for guests
        // We use a Container/Material instead of a Scaffold to avoid "Nested Scaffold" issues
        // inside the AppShell IndexedStack.
        return Material(
          color: AppColors.backgroundPrimary,
          child: Stack(
            children: [
              // Close button in top-left
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () =>
                      context.read<NavigationCubit>().setTab(AppTab.chat),
                  color: AppColors.textPrimary,
                ),
              ),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.accentPrimary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_person_rounded,
                            size: 64,
                            color: AppColors.accentPrimary,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Sign in required',
                          style: AppTextStyles.displayMedium.copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Unlock full access to the medical scanner, community forum, and persistent history by signing in.',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        PremiumButton(
                          onPressed: () {
                            // Navigate to landing but force authentication step
                            AppRouter.navigateTo(
                              context,
                              AppRouter.landing,
                              arguments: {'forceAuth': true},
                            );
                          },
                          text: 'Sign In',
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () =>
                              context.read<NavigationCubit>().setTab(AppTab.chat),
                          child: Text(
                            'Maybe Later',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textTertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
