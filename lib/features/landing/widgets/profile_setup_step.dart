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
          backgroundColor: AppColors.backgroundPrimary,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
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
                  Text(
                    'Set up your profile',
                    style: AppTextStyles.displayMedium.copyWith(
                      color: AppColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This helps us personalize your experience.',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 40),
                  
                  _buildLabel('YOUR NAME'),
                  TextField(
                    controller: _nameController,
                    decoration: _buildInputDecoration('Enter your name'),
                    style: AppTextStyles.bodyLarge,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  _buildLabel('ACCOUNT NICKNAME'),
                  TextField(
                    controller: _nicknameController,
                    decoration: _buildInputDecoration('e.g., Clinical Account, Personal'),
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use this to distinguish this account from others.',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
                  ),
                  
                  const Spacer(),
                  PremiumButton(
                    onPressed: state.canProceed 
                        ? () => context.read<LandingCubit>().nextStep() 
                        : null,
                    text: 'Continue',
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
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
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textTertiary,
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
      fillColor: AppColors.backgroundSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: AppColors.accentPrimary, width: 2),
      ),
    );
  }
}
