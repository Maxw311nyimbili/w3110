import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../cubit/cubit.dart';
import 'package:cap_project/core/widgets/premium_button.dart';

class ProfileSetupStep extends StatefulWidget {
  const ProfileSetupStep({super.key});

  @override
  State<ProfileSetupStep> createState() => _ProfileSetupStepState();
}

class _ProfileSetupStepState extends State<ProfileSetupStep> {
  late TextEditingController _nameController;
  late TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<LandingCubit>().state;
    _nameController = TextEditingController(text: state.userName);
    _nicknameController = TextEditingController(text: state.accountNickname);

    // Update state when controllers change
    _nameController.addListener(() {
      context.read<LandingCubit>().setUserName(_nameController.text);
    });
    _nicknameController.addListener(() {
      context.read<LandingCubit>().setAccountNickname(_nicknameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    super.dispose();
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
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: Theme.of(context).textTheme.bodyLarge?.color,
              onPressed: () => context.read<LandingCubit>().previousStep(),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Staggered Title
                  _buildStaggeredEntrance(
                    delay: 100,
                    child: Text(
                      'Personalize your care',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Theme.of(context).textTheme.displayLarge?.color,
                        letterSpacing: -1.0,
                        fontWeight: FontWeight.w800,
                        fontSize: 34,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Staggered Subtitle
                  _buildStaggeredEntrance(
                    delay: 200,
                    child: Text(
                      'This helps Thanzi provide more accurate medical context tailored to you.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 17,
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Staggered Inputs
                  _buildStaggeredEntrance(
                    delay: 300,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('YOUR NAME'),
                        TextField(
                          controller: _nameController,
                          decoration: _buildInputDecoration('Enter your name'),
                          style: AppTextStyles.bodyLarge,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  _buildStaggeredEntrance(
                    delay: 400,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ACCOUNT NICKNAME'),
                        TextField(
                          controller: _nicknameController,
                          decoration: _buildInputDecoration(
                            'e.g., Clinical Account, Personal',
                          ),
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use this to distinguish this account from others.',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  _buildStaggeredEntrance(
                    delay: 500,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: PremiumButton(
                        onPressed: state.canProceed
                            ? () => context.read<LandingCubit>().nextStep()
                            : null,
                        text: 'Continue',
                      ),
                    ),
                  ),
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).textTheme.bodySmall?.color,
          letterSpacing: 1.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
      ),
    );
  }
}
