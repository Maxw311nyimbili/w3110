import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/legal/legal_content.dart';
import '../../../core/legal/policy_viewer_page.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';
import 'package:cap_project/core/theme/app_text_styles.dart';

class ConsentStep extends StatelessWidget {
  const ConsentStep({super.key});

  void _openPrivacyPolicy(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PolicyViewerPage(
          title: kPrivacyPolicyTitle,
          effectiveDate: kPrivacyPolicyDate,
          sections: kPrivacySections,
        ),
      ),
    );
  }

  void _openTerms(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PolicyViewerPage(
          title: kTermsTitle,
          effectiveDate: kTermsDate,
          sections: kTermsSections,
        ),
      ),
    );
  }

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
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Theme.of(context).textTheme.bodyLarge?.color,
              onPressed: () => context.read<LandingCubit>().previousStep(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 8,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
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

                  const SizedBox(height: 8),

                  _buildStaggeredEntrance(
                    delay: 150,
                    child: Text(
                      'Please read these carefully before continuing.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Key commitments
                  _buildStaggeredEntrance(
                    delay: 200,
                    child: _buildTermItem(
                      context,
                      icon: Icons.smart_toy_outlined,
                      title: 'AI — Not a Doctor',
                      desc:
                          'Naiia uses AI to provide health information. It is not a substitute for professional medical advice, diagnosis, or treatment.',
                    ),
                  ),
                  _buildStaggeredEntrance(
                    delay: 280,
                    child: _buildTermItem(
                      context,
                      icon: Icons.emergency_outlined,
                      title: 'Emergencies',
                      desc:
                          'If you are experiencing a medical emergency, call your local emergency number immediately. Do not rely on Naiia.',
                    ),
                  ),
                  _buildStaggeredEntrance(
                    delay: 360,
                    child: _buildTermItem(
                      context,
                      icon: Icons.lock_outline_rounded,
                      title: 'Your Data',
                      desc:
                          'We collect your email, chat history, and health interests to personalise your experience. We do not sell your data. You can delete your account and all data at any time.',
                    ),
                  ),
                  _buildStaggeredEntrance(
                    delay: 440,
                    child: _buildTermItem(
                      context,
                      icon: Icons.verified_user_outlined,
                      title: 'Data Sharing',
                      desc:
                          'Your data is processed by Firebase (auth), Groq AI (chat responses), and Railway (hosting). No other parties have access.',
                    ),
                  ),

                  const Spacer(),

                  // View full documents
                  _buildStaggeredEntrance(
                    delay: 520,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDocLink(
                          context,
                          label: 'Privacy Policy',
                          onTap: () => _openPrivacyPolicy(context),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            '·',
                            style: TextStyle(
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.4),
                              fontSize: 18,
                            ),
                          ),
                        ),
                        _buildDocLink(
                          context,
                          label: 'Terms of Service',
                          onTap: () => _openTerms(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Consent checkbox
                  _buildStaggeredEntrance(
                    delay: 580,
                    child: _ConsentCheckbox(
                      value: state.consentGiven,
                      onChanged: (value) {
                        context.read<LandingCubit>().giveConsent(
                          value ?? false,
                          AppConstants.currentConsentVersion,
                        );
                      },
                      onPrivacyTap: () => _openPrivacyPolicy(context),
                      onTermsTap: () => _openTerms(context),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildStaggeredEntrance(
                    delay: 640,
                    child: PremiumButton(
                      onPressed: state.consentGiven
                          ? () => context.read<LandingCubit>().nextStep()
                          : null,
                      text: 'I Agree — Continue',
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
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutQuart,
      builder: (context, value, _) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTermItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 14),
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
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    height: 1.5,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocLink(
    BuildContext context, {
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(
            context,
          ).colorScheme.primary.withOpacity(0.5),
        ),
      ),
    );
  }
}

/// Checkbox with inline tappable "Privacy Policy" and "Terms of Service" links.
class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({
    required this.value,
    required this.onChanged,
    required this.onPrivacyTap,
    required this.onTermsTap,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onPrivacyTap;
  final VoidCallback onTermsTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bodyColor = theme.textTheme.bodyMedium?.color;
    final primary = theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.translate(
          offset: const Offset(-4, -2),
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primary,
            checkColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: RichText(
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: bodyColor,
                  height: 1.55,
                  fontSize: 14,
                ),
                children: [
                  const TextSpan(text: 'I have read and agree to the '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: primary.withOpacity(0.5),
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onPrivacyTap,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: primary.withOpacity(0.5),
                    ),
                    recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
