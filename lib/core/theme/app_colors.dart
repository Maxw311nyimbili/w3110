// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// App-wide color palette - medical trust meets premium simplicity
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundPrimary = Color(0xFFFAFAFA);
  static const Color backgroundSurface = Color(0xFFFFFFFF);
  static const Color backgroundElevated = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFFA0A0A0);

  // Accent - Trust Teal (medical but warm)
  static const Color accentPrimary = Color(0xFF00A67E);
  static const Color accentLight = Color(0xFFE6F7F3); // 12% opacity equivalent
  static const Color accentDark = Color(0xFF008566);

  // Semantic
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Neutral grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFE5E5E5);
  static const Color gray300 = Color(0xFFD4D4D4);
  static const Color gray400 = Color(0xFFA3A3A3);
  static const Color gray500 = Color(0xFF737373);
  static const Color gray600 = Color(0xFF525252);
  static const Color gray700 = Color(0xFF404040);
  static const Color gray800 = Color(0xFF262626);
  static const Color gray900 = Color(0xFF171717);

  // Confidence indicators (for chat)
  static const Color confidenceHigh = Color(0xFF00C896);
  static const Color confidenceMedium = Color(0xFFF59E0B);
  static const Color confidenceLow = Color(0xFFEF4444);
}