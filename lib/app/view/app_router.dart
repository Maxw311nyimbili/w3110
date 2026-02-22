// lib/app/app_router.dart

import 'package:flutter/cupertino.dart';
import 'package:cap_project/core/widgets/auth_guard.dart';
import 'package:cap_project/features/auth/auth.dart';
import 'package:cap_project/features/auth/view/settings_page.dart';
import 'package:cap_project/features/chat/chat.dart';
import 'package:cap_project/features/forum/forum.dart';
import 'package:cap_project/features/landing/landing.dart';
import 'package:cap_project/features/landing/view/splash_page.dart';
import 'package:cap_project/features/landing/view/feature_choice_page.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';
import 'package:flutter/material.dart';

/// App router - handles navigation between features
class AppRouter {
  // Route names
  static const String splash = '/splash';
  static const String featureChoice = '/feature-choice';
  static const String landing = '/';
  static const String auth = '/auth';
  static const String chat = '/chat';
  static const String scanner = '/scanner';
  static const String forum = '/forum';
  static const String settings = '/settings';

  /// Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.splash:
        return CupertinoPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case AppRouter.featureChoice:
        return CupertinoPageRoute(
          builder: (_) => const FeatureChoicePage(),
          settings: settings,
        );

      case AppRouter.landing:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialStep = args?['initialStep'] as OnboardingStep?;
        final forceAuth = args?['forceAuth'] == true;

        return CupertinoPageRoute(
          builder: (_) => LandingPage(
            initialStepOverride:
                initialStep ??
                (forceAuth ? OnboardingStep.authentication : null),
          ),
          settings: settings,
        );

      case AppRouter.auth:
        return CupertinoPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );

      case AppRouter.chat:
        final scanResult = settings.arguments as ScanResult?;
        return CupertinoPageRoute(
          builder: (_) => ChatPage(initialScanResult: scanResult),
          settings: settings,
        );

      case AppRouter.scanner:
        return CupertinoPageRoute(
          builder: (_) => const AuthGuard(child: MedScannerPage()),
          settings: settings,
        );

      case AppRouter.forum:
        return CupertinoPageRoute(
          builder: (_) => const AuthGuard(child: ForumListPage()),
          settings: settings,
        );

      case AppRouter.settings:
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (_, __, ___) => const AuthGuard(child: SettingsPage()),
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            const begin = Offset(-1.0, 0.0); // Start from LEFT
            const end = Offset.zero;
            const curve = Curves.easeOutCubic;

            var tween = Tween(
              begin: begin,
              end: end,
            ).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );

      default:
        return CupertinoPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('404')),
            body: Center(
              child: Text('Route not found: ${settings.name}'),
            ),
          ),
        );
    }
  }

  /// Navigate to route
  static Future<T?> navigateTo<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(
      context,
      routeName,
      arguments: arguments,
    );
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
