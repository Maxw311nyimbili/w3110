// lib/core/theme/cubit/theme_cubit.dart

import 'package:cap_project/core/theme/cubit/theme_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState()) {
    _loadTheme();
  }

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

  Future<void> setThemeMode(AppThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, mode.index);
    } catch (_) {
      // Non-critical persistence failure
    }
  }
}
