import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents the current locale state of the application
class LocaleState extends Equatable {
  const LocaleState({
    required this.locale,
  });

  /// The current locale
  final Locale locale;

  /// List of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'), // English
    Locale('ar'), // Arabic
    Locale('fr'), // French
  ];

  /// Get language name in its native form
  static String getLanguageName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'ar':
        return 'العربية';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }

  /// Get language icon
  static IconData getLanguageIcon(Locale locale) {
    return Icons.language_rounded;
  }

  /// Copy with method for state updates
  LocaleState copyWith({
    Locale? locale,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
    );
  }

  @override
  List<Object?> get props => [locale];
}
