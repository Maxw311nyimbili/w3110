// lib/features/landing/view/landing_page.dart

import 'package:cap_project/features/landing/cubit/cubit.dart';
import 'package:cap_project/features/landing/widgets/landing_body.dart';
import 'package:cap_project/core/util/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Entry point for onboarding flow
class LandingPage extends StatelessWidget {
  const LandingPage({super.key, this.initialStepOverride});

  final OnboardingStep? initialStepOverride;

  static Route<void> route({OnboardingStep? initialStep}) {
    return MaterialPageRoute(
      builder: (context) => LandingPage(initialStepOverride: initialStep),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Trigger initialization on first build
    context.read<LandingCubit>().initialize(
      initialStepOverride: initialStepOverride,
    );

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
      },
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const LandingBody(),
            ),
          ),
        ),
      ),
    );
  }
}
