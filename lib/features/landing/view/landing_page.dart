// lib/features/landing/view/landing_page.dart

import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/landing/widgets/landing_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';

/// Entry point for onboarding flow
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const LandingPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trigger initialization on first build
    context.read<LandingCubit>().initialize();
    
    return const LandingView();
  }
}

class LandingView extends StatelessWidget {
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LandingCubit, LandingState>(
      listener: (context, state) {
        // Show error if any
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          context.read<LandingCubit>().clearError();
        }

        // Navigate when onboarding complete
        if (state.isComplete) {
          // Navigate after this frame to avoid build conflicts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Navigate to chat page (since auth happens during onboarding)
              AppRouter.replaceTo(context, AppRouter.chat);

              // Show completion message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Welcome to MedBot!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          });
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: LandingBody(),
        ),
      ),
    );
  }
}