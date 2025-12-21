// lib/app/app_config.dart

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
    return const AppConfig(
      // apiBaseUrl: 'https://91f9d06210b5.ngrok-free.app',
      apiBaseUrl: 'http://172.16.2.224:8000',
      //apiBaseUrl: 'http://10.0.2.2:8000',
      environment: Environment.development,
      enableLogging: true,
      apiTimeout: Duration(seconds: 60),
    );
  }

  /// Staging configuration
  factory AppConfig.staging() {
    return const AppConfig(
      apiBaseUrl: 'https://staging-api.medbot.com',
      environment: Environment.staging,
      enableLogging: true,
      apiTimeout: Duration(seconds: 30),
    );
  }

  /// Production configuration
  factory AppConfig.production() {
    return const AppConfig(
      apiBaseUrl: 'https://api.medbot.com',
      environment: Environment.production,
      enableLogging: false, // Disable verbose logging in production
      apiTimeout: Duration(seconds: 30),
    );
  }

  bool get isDevelopment => environment == Environment.development;
  bool get isStaging => environment == Environment.staging;
  bool get isProduction => environment == Environment.production;

  @override
  List<Object?> get props => [apiBaseUrl, environment, enableLogging, apiTimeout];
}

/// Environment enumeration
enum Environment {
  development,
  staging,
  production,
}