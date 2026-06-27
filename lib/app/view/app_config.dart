// lib/app/app_config.dart

import 'package:cap_project/app/env.dart';
import 'package:equatable/equatable.dart';

/// App configuration for different environments
class AppConfig extends Equatable {
  const AppConfig({
    required this.apiBaseUrl,
    required this.environment,
    this.enableLogging = false,
    this.apiTimeout = const Duration(seconds: 30),
  });

  final String apiBaseUrl;
  final Environment environment;
  final bool enableLogging;
  final Duration apiTimeout;

  /// Development configuration
  factory AppConfig.development() {
    return AppConfig(
      // LOCAL DEV: hardcoded to bypass envied/build_runner.
      // Android emulator → http://10.0.2.2:8000
      // iOS simulator / Windows / Web → http://localhost:8000
      // Restore `Env.apiUrlDev` after running:
      //   del lib\app\env.g.dart && dart run build_runner build --delete-conflicting-outputs
      apiBaseUrl: 'http://127.0.0.1:8000',
      environment: Environment.development,
      enableLogging: true,
      apiTimeout: const Duration(seconds: 60),
    );
  }

  /// Staging configuration
  factory AppConfig.staging() {
    return AppConfig(
      apiBaseUrl: Env.apiUrlStaging,
      environment: Environment.staging,
      enableLogging: true,
      apiTimeout: const Duration(seconds: 30),
    );
  }

  /// Production configuration
  factory AppConfig.production() {
    return AppConfig(
      apiBaseUrl: Env.apiUrlProd,
      environment: Environment.production,
      enableLogging: false, // Disable verbose logging in production
      apiTimeout: const Duration(seconds: 30),
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;

  @override
  List<Object?> get props => [
    apiBaseUrl,
    environment,
    enableLogging,
    apiTimeout,
  ];
}

/// Environment enumeration
enum Environment {
  development,
  staging,
  production,
}
