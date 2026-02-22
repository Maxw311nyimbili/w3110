// lib/features/auth/view/auth_page.dart

import 'package:auth_repository/auth_repository.dart';
import 'package:cap_project/app/view/app_router.dart';
import 'package:cap_project/features/auth/cubit/cubit.dart';
import 'package:cap_project/features/auth/widgets/widgets.dart';
import 'package:flutter/material.dart';

/// Auth page - entry point for authentication flow
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (context) => const AuthPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const AuthView();
  }
}

/// Auth view - wraps auth body with scaffold
class AuthView extends StatelessWidget {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // Show error messages
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
          context.read<AuthCubit>().clearError();
        }

        // Navigate to chat when authenticated
        if (state.status == AuthStatus.authenticated && state.user != null) {
          print('✅ Auth successful! Navigating to chat...');
          print('👤 User: ${state.user!.displayName} (${state.user!.email})');

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              // Navigate to chat page
              AppRouter.replaceTo(context, AppRouter.chat);

              // Show welcome message
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Welcome, ${state.user!.displayName}!',
                  ),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
        }
      },
      child: const Scaffold(
        body: SafeArea(
          child: AuthBody(),
        ),
      ),
    );
  }
}
