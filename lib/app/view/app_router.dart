// lib/app/app_router.dart

import 'package:flutter/material.dart';
import 'package:cap_project/core/widgets/app_shell.dart';
import 'package:cap_project/core/widgets/auth_guard.dart';
import 'package:cap_project/features/auth/auth.dart';
import 'package:cap_project/features/auth/view/settings_page.dart';
import 'package:cap_project/features/chat/chat.dart';
import 'package:cap_project/features/forum/forum.dart';
import 'package:cap_project/features/landing/landing.dart';
import 'package:cap_project/features/landing/view/splash_page.dart';
import 'package:cap_project/features/landing/view/feature_choice_page.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';

/// App router - handles navigation between features
class AppRouter {
  // Route names
  static const String splash = '/splash';
  static const String featureChoice = '/feature-choice';
  static const String landing = '/';
  static const String shell = '/app';
  static const String chat = '/chat';
  static const String scanner = '/scanner';
  static const String forum = '/forum';
  static const String settings = '/settings';

  /// Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return _fadeRoute(const SplashPage(), settings);

      case AppRouter.featureChoice:
        return _fadeRoute(const FeatureChoicePage(), settings);

      case AppRouter.landing:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialStep = args?['initialStep'] as OnboardingStep?;
        final forceAuth = args?['forceAuth'] == true;
        return _fadeRoute(
          LandingPage(
            initialStepOverride:
                initialStep ??
                (forceAuth ? OnboardingStep.authentication : null),
          ),
          settings,
        );

      case AppRouter.chat:
        final scanResult = settings.arguments as ScanResult?;
        return _fadeRoute(
          ChatPage(initialScanResult: scanResult),
          settings,
        );

      case AppRouter.scanner:
        return _fadeRoute(
          const AuthGuard(child: MedScannerPage()),
          settings,
        );

      case AppRouter.forum:
        return _fadeRoute(
          const AuthGuard(child: ForumListPage()),
          settings,
        );

      case AppRouter.settings:
        // Settings slides in from the right — intentional directional cue
        return _slideRoute(
          const AuthGuard(child: SettingsPage()),
          settings,
        );

      case AppRouter.shell:
        // Shell replaces everything — instant, no animation
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const AppShell(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (_, __, ___, child) => child,
        );

      default:
        return _fadeRoute(
          Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
          settings,
        );
    }
  }

  /// Navigate to route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Replace current route
  static Future<T?> replaceTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, dynamic>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pop current route
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}

// ── Transition builders ───────────────────────────────────────────────────────

/// Pure fade — no sliding, no parallax. New page fades in, old fades out.
/// This is the default for all feature routes.
PageRouteBuilder<T> _fadeRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 200),
    reverseTransitionDuration: const Duration(milliseconds: 160),
    transitionsBuilder: (_, animation, __, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Slide from right — only for settings-style overlay pages where
/// a directional cue makes sense (swipe-back to dismiss).
PageRouteBuilder<T> _slideRoute<T>(Widget page, RouteSettings settings) {
  return PageRouteBuilder<T>(
    settings: settings,
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 280),
    reverseTransitionDuration: const Duration(milliseconds: 220),
    transitionsBuilder: (_, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      // The *outgoing* page fades slightly rather than sliding left —
      // avoids the competing-slide effect that causes the cranky feel.
      final fade = Tween<double>(begin: 1.0, end: 0.85).animate(
        CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeIn),
      );

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
