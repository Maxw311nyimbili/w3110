// lib/core/theme/cubit/theme_state.dart

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum AppThemeMode { light, dark, system }

class ThemeState extends Equatable {
  const ThemeState({this.themeMode = AppThemeMode.system});

  final AppThemeMode themeMode;

  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  List<Object> get props => [themeMode];

  ThemeState copyWith({AppThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
