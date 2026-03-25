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
  static const _currentStepKey = 'current_onboarding_step';

  // ── Rating prompt keys ────────────────────────────────────────────────────
  static const _ratingHasRatedKey = 'rating_has_rated';
  static const _ratingLastPromptedMsKey = 'rating_last_prompted_ms';
  static const _ratingSessionCountKey = 'rating_session_count';
  static const _ratingFirstSessionMsKey = 'rating_first_session_ms';

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
    await _prefs.remove(_currentStepKey); // Also clear step
  }

  /// Save current step
  Future<void> saveCurrentStep(String step) async {
    _ensureInitialized();
    await _prefs.setString(_currentStepKey, step);
  }

  /// Get current step
  Future<String?> getCurrentStep() async {
    _ensureInitialized();
    return _prefs.getString(_currentStepKey);
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

  // ── Rating prompt helpers ─────────────────────────────────────────────────

  Future<bool> getRatingHasRated() async {
    _ensureInitialized();
    return _prefs.getBool(_ratingHasRatedKey) ?? false;
  }

  Future<void> setRatingHasRated({required bool value}) async {
    _ensureInitialized();
    await _prefs.setBool(_ratingHasRatedKey, value);
  }

  Future<int?> getRatingLastPromptedMs() async {
    _ensureInitialized();
    return _prefs.getInt(_ratingLastPromptedMsKey);
  }

  Future<void> setRatingLastPromptedMs(int ms) async {
    _ensureInitialized();
    await _prefs.setInt(_ratingLastPromptedMsKey, ms);
  }

  Future<int> getRatingSessionCount() async {
    _ensureInitialized();
    return _prefs.getInt(_ratingSessionCountKey) ?? 0;
  }

  Future<void> incrementRatingSessionCount() async {
    _ensureInitialized();
    final current = _prefs.getInt(_ratingSessionCountKey) ?? 0;
    await _prefs.setInt(_ratingSessionCountKey, current + 1);
  }

  Future<int?> getRatingFirstSessionMs() async {
    _ensureInitialized();
    return _prefs.getInt(_ratingFirstSessionMsKey);
  }

  Future<void> setRatingFirstSessionMs(int ms) async {
    _ensureInitialized();
    await _prefs.setInt(_ratingFirstSessionMsKey, ms);
  }
}
