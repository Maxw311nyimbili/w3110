import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/premium_button.dart';

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
        return Scaffold(
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
              color: AppColors.textPrimary,
            ),
          ),
          body: Padding(
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
                  onPressed: () => Navigator.of(context).pop(),
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
        );
      },
    );
  }
}
