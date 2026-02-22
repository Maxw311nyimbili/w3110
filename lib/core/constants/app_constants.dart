// lib/core/constants/app_constants.dart

/// App-wide constants
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'MedLink';
  static const String appVersion = '1.0.0';

  // User roles
  static const String roleExpectingMother = 'expecting_mother';
  static const String roleHealthcareProvider = 'healthcare_provider';
  static const String roleParentCaregiver = 'parent_caregiver';
  static const String roleExplorer = 'explorer';

  // Onboarding
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String userRoleKey = 'user_role';
  static const String consentVersionKey = 'consent_version';
  static const String currentConsentVersion = '1.0';

  // Chat
  static const int maxChatHistoryLength = 100;
  static const double confidenceThresholdHigh = 0.8;
  static const double confidenceThresholdMedium = 0.5;

  // Forum
  static const int forumPostsPerPage = 20;
  static const Duration syncRetryDelay = Duration(seconds: 30);
  static const int maxSyncRetries = 3;

  // Media
  static const int imageQuality = 85;
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB

  // Backend URLs (TODO: Replace with actual backend URLs)
  static const String baseApiUrl = 'https://api.medlink.example.com';
  static const String authEndpoint = '/auth/exchange';
  static const String chatEndpoint = '/chat/query';
  static const String forumEndpoint = '/forum';
  static const String mediaEndpoint = '/media/upload';
}
