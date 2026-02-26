import 'package:cap_project/core/theme/cubit/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:landing_repository/landing_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({LandingRepository? landingRepository})
      : _landingRepository = landingRepository,
        super(const ThemeState()) {
    _loadTheme();
  }

  final LandingRepository? _landingRepository;
  static const String _themeKey = 'theme_mode';

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey);
      if (themeIndex != null) {
        emit(ThemeState(themeMode: AppThemeMode.values[themeIndex]));
      }
    } catch (_) {
      // Fallback to default
    }
  }

  /// Update theme from user preference (called after login)
  void updateFromUserPref(String pref) {
    final mode = ThemeState.fromString(pref);
    emit(state.copyWith(themeMode: mode));
    // Also save to shared prefs for local persistence
    _saveToLocal(mode);
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));

    // 1. Save locally
    await _saveToLocal(mode);

    // 2. Sync with backend if possible
    if (_landingRepository != null) {
      try {
        await _landingRepository!.updatePreferences(themeMode: state.name);
      } catch (e) {
        print('⚠️ Failed to sync theme preference to backend: $e');
      }
    }
  }

  Future<void> _saveToLocal(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (_) {
      // Non-critical persistence failure
    }
  }
}
