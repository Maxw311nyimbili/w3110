import 'package:bloc/bloc.dart';
import 'package:cap_project/core/locale/cubit/locale_state.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit for managing application locale
class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(const LocaleState(locale: Locale('en'))) {
    _loadSavedLocale();
  }

  static const String _localeKey = 'app_locale';

  /// Load the saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      
      if (localeCode != null) {
        final locale = Locale(localeCode);
        if (_isSupported(locale)) {
          emit(state.copyWith(locale: locale));
        }
      }
    } catch (e) {
      // If loading fails, keep default locale
      debugPrint('Error loading saved locale: $e');
    }
  }

  /// Change the application locale
  Future<void> changeLocale(Locale locale) async {
    if (!_isSupported(locale)) {
      debugPrint('Unsupported locale: ${locale.languageCode}');
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
      emit(state.copyWith(locale: locale));
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Check if a locale is supported
  bool _isSupported(Locale locale) {
    return LocaleState.supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }

  /// Get the current locale code for API calls
  String get currentLocaleCode => state.locale.languageCode;
}
