// packages/landing_repository/lib/src/landing_repository.dart

import 'package:api_client/api_client.dart';
import 'package:landing_repository/src/local_preferences.dart';
import 'package:landing_repository/src/models/announcement.dart';
import 'package:landing_repository/src/models/consent_info.dart';
import 'package:landing_repository/src/models/onboarding_status.dart';

/// Landing repository - handles onboarding, announcements, and app initialization
class LandingRepository {
  LandingRepository({
    required ApiClient apiClient,
    required LocalPreferences localPreferences,
  }) : _apiClient = apiClient,
       _localPreferences = localPreferences;

  final ApiClient _apiClient;
  final LocalPreferences _localPreferences;

  /// Get onboarding status from local storage
  Future<OnboardingStatus> getOnboardingStatus() async {
    try {
      final data = await _localPreferences.getOnboardingStatus();
      if (data != null) {
        return OnboardingStatus.fromJson(data);
      }
      return const OnboardingStatus(isComplete: false);
    } catch (e) {
      throw LandingException(
        'Failed to get onboarding status: ${e.toString()}',
      );
    }
  }

  /// Fetch dynamic greeting from backend
  ///
  /// Backend endpoint: GET /landing/greeting
  /// Response: { "greeting": "..." }
  Future<String> fetchGreeting() async {
    try {
      final response = await _apiClient.get('/landing/greeting');
      final responseData = response.data as Map<String, dynamic>;
      return responseData['greeting'] as String? ?? 'Hello!';
    } catch (e) {
      print('⚠️ Failed to fetch dynamic greeting: $e');
      return 'Hello!'; // Fallback
    }
  }

  /// Update user preferences (interests and role) on backend
  ///
  /// Backend endpoint: PUT /landing/preferences
  /// Request body: { "interests": [...], "role": "..." }
  Future<void> updatePreferences({
    List<String>? interests,
    String? role,
    bool? onboardingCompleted,
    String? themeMode,
  }) async {
    try {
      await _apiClient.put(
        '/landing/preferences',
        data: {
          if (interests != null) 'interests': interests,
          if (role != null) 'role': role,
          if (onboardingCompleted != null)
            'onboarding_completed': onboardingCompleted,
          if (themeMode != null) 'theme_mode': themeMode,
        },
      );
      print('✅ Preferences updated on backend');
    } catch (e) {
      throw LandingException('Failed to update preferences: ${e.toString()}');
    }
  }

  /// Save onboarding status to local storage and sync with backend if possible
  Future<void> saveOnboardingStatus(OnboardingStatus status) async {
    try {
      // 1. Save locally first (immediate feedback)
      await _localPreferences.saveOnboardingStatus(status.toJson());

      // 2. Try to sync with backend
      await updatePreferences(
        role: status.userRole,
        interests: status.interests,
        onboardingCompleted: status.isComplete,
      );
    } catch (e) {
      // We log but don't rethrow for background sync in saveOnboardingStatus
      // to keep legacy behavior of not breaking the UI on sync failure
      print('⚠️ Failed to sync onboarding status: $e');
    }
  }

  /// Clear onboarding status (for testing/debugging)
  Future<void> clearOnboardingStatus() async {
    try {
      await _localPreferences.clearOnboardingStatus();
    } catch (e) {
      throw LandingException(
        'Failed to clear onboarding status: ${e.toString()}',
      );
    }
  }

  /// Fetch announcements from backend
  ///
  /// Backend endpoint: GET /announcements?active=true
  /// Response: { "announcements": [...] }
  Future<List<Announcement>> fetchAnnouncements() async {
    try {
      final response = await _apiClient.get('/announcements?active=true');

      // Cast response.data to Map first
      final responseData = response.data as Map<String, dynamic>;
      final announcementsJson = responseData['announcements'] as List<dynamic>;

      return announcementsJson
          .map((json) => Announcement.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw LandingException('Failed to fetch announcements: ${e.toString()}');
    }
  }

  /// Get current consent info from backend
  ///
  /// Backend endpoint: GET /consent/current
  /// Response: { "version": "1.0", "content": "...", "is_required": true }
  Future<ConsentInfo> getCurrentConsent() async {
    try {
      final response = await _apiClient.get('/consent/current');

      // Cast response.data to Map
      final responseData = response.data as Map<String, dynamic>;

      return ConsentInfo.fromJson(responseData);
    } catch (e) {
      throw LandingException('Failed to fetch consent info: ${e.toString()}');
    }
  }

  /// Check if consent version has changed (user needs to re-consent)
  Future<bool> needsConsentUpdate(String currentVersion) async {
    try {
      final latestConsent = await getCurrentConsent();
      return latestConsent.version != currentVersion;
    } catch (e) {
      // If we can't check, assume no update needed
      return false;
    }
  }

  /// Save language preference
  Future<void> saveLanguagePreference(String languageCode) async {
    try {
      await _localPreferences.saveLanguage(languageCode);
    } catch (e) {
      throw LandingException('Failed to save language: ${e.toString()}');
    }
  }

  /// Get language preference
  Future<String?> getLanguagePreference() async {
    try {
      return await _localPreferences.getLanguage();
    } catch (e) {
      return null; // Return null if no preference set
    }
  }

  /// Completely clear all local data (onboarding, language, etc.)
  Future<void> clearAllLocalData() async {
    try {
      await _localPreferences.clearAll();
    } catch (e) {
      throw LandingException('Failed to clear local data: ${e.toString()}');
    }
  }

  /// Save last splash seen time
  Future<void> saveLastSplashTime(DateTime time) async {
    try {
      await _localPreferences.saveLastSplashTime(time);
    } catch (e) {
      print('⚠️ Failed to save splash time: $e');
    }
  }

  /// Get last splash seen time
  Future<DateTime?> getLastSplashTime() async {
    try {
      return await _localPreferences.getLastSplashTime();
    } catch (e) {
      return null;
    }
  }
}

/// Custom exception for landing repository errors
class LandingException implements Exception {
  LandingException(this.message);
  final String message;

  @override
  String toString() => 'LandingException: $message';
}
