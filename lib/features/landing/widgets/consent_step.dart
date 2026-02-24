import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';

class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

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
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Staggered Title
                  _buildStaggeredEntrance(
                    delay: 100,
                    child: Text(
                      'One final commitment',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        letterSpacing: -1.0,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Staggered Items
                  _buildStaggeredEntrance(
                    delay: 200,
                    child: _buildTermItem(
                      context,
                      'AI Assistance',
                      'MedLink uses AI. It is not a substitute for professional medical advice.',
                    ),
                  ),
                  _buildStaggeredEntrance(
                    delay: 300,
                    child: _buildTermItem(
                      context,
                      'Emergency',
                      'If this is an emergency, call 911 immediately.',
                    ),
                  ),
                  _buildStaggeredEntrance(
                    delay: 400,
                    child: _buildTermItem(
                      context,
                      'Privacy',
                      'Your data is private and encrypted.',
                    ),
                  ),

                  const Spacer(),

                  // Staggered Consent Box
                  _buildStaggeredEntrance(
                    delay: 500,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Checkbox(
                            value: state.consentGiven,
                            onChanged: (value) {
                              context.read<LandingCubit>().giveConsent(
                                value ?? false,
                                AppConstants.currentConsentVersion,
                              );
                            },
                            activeColor: Theme.of(context).colorScheme.primary,
                            checkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'I understand and agree to the terms',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildStaggeredEntrance(
                    delay: 600,
                    child: PremiumButton(
                      onPressed: state.consentGiven
                          ? () => context
                                .read<LandingCubit>()
                                .completeOnboarding()
                          : null,
                      text: 'Complete Setup',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
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

  Widget _buildTermItem(BuildContext context, String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.info_outline,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
