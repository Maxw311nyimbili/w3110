// lib/app/app_router.dart

import 'package:cap_project/features/auth/auth.dart';
import 'package:cap_project/features/auth/view/settings_page.dart';
import 'package:cap_project/features/chat/chat.dart';
import 'package:cap_project/features/forum/forum.dart';
import 'package:cap_project/features/landing/landing.dart';
import 'package:cap_project/features/medscanner/medscanner.dart';
import 'package:flutter/material.dart';

/// App router - handles navigation between features
class AppRouter {
  // Route names
  static const String landing = '/';
  static const String auth = '/auth';
  static const String chat = '/chat';
  static const String scanner = '/scanner';
  static const String forum = '/forum';
  static const String settings = '/settings';

  /// Generate routes
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRouter.landing:
        return MaterialPageRoute(
          builder: (_) => const LandingPage(),
          settings: settings,
        );

      case AppRouter.auth:
        return MaterialPageRoute(
          builder: (_) => const AuthPage(),
          settings: settings,
        );

      case AppRouter.chat:
        return MaterialPageRoute(
          builder: (_) => const ChatPage(),
          settings: settings,
        );

      case AppRouter.scanner:
        return MaterialPageRoute(
          builder: (_) => const MedScannerPage(),
          settings: settings,
        );

      case AppRouter.forum:
        return MaterialPageRoute(
          builder: (_) => const ForumListPage(),
          settings: settings,
        );

      case AppRouter.settings:
        return MaterialPageRoute(
          builder: (_) => const SettingsPage(),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
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