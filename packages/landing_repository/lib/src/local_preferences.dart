// packages/landing_repository/lib/src/local_preferences.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper for storing onboarding data locally
/// Uses shared_preferences package
class LocalPreferences {
  LocalPreferences();

  late final SharedPreferences _prefs;
  bool _prefsInitialized = false;

  static const _onboardingKey = 'onboarding_status';
  static const _languageKey = 'app_language';
  static const _splashKey = 'last_splash_seen';

  bool get isInitialized => _prefsInitialized;

  /// Initialize preferences
  Future<void> initialize() async {
    if (_prefsInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _prefsInitialized = true;
  }

  void _ensureInitialized() {
    if (!_prefsInitialized) {
      throw StateError(
        'LocalPreferences not initialized. Call initialize() first.',
      );
    }
  }

  /// Save onboarding status
  Future<void> saveOnboardingStatus(Map<String, dynamic> status) async {
    _ensureInitialized();
    await _prefs.setString(_onboardingKey, jsonEncode(status));
  }

  /// Get onboarding status
  Future<Map<String, dynamic>?> getOnboardingStatus() async {
    _ensureInitialized();
    final data = _prefs.getString(_onboardingKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  /// Clear onboarding status
  Future<void> clearOnboardingStatus() async {
    _ensureInitialized();
    await _prefs.remove(_onboardingKey);
  }

  /// Clear all app preferences
  Future<void> clearAll() async {
    _ensureInitialized();
    await _prefs.clear();
  }

  /// Save language preference
  Future<void> saveLanguage(String languageCode) async {
    _ensureInitialized();
    await _prefs.setString(_languageKey, languageCode);
  }

  /// Get language preference
  Future<String?> getLanguage() async {
    _ensureInitialized();
    return _prefs.getString(_languageKey);
  }

  /// Save last splash seen time
  Future<void> saveLastSplashTime(DateTime time) async {
    _ensureInitialized();
    await _prefs.setInt(_splashKey, time.millisecondsSinceEpoch);
  }

  /// Get last splash seen time
  Future<DateTime?> getLastSplashTime() async {
    _ensureInitialized();
    final timestamp = _prefs.getInt(_splashKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }
}
