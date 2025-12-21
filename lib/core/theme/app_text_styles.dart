// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AppTextStyles {
  // Use Inter from Google Fonts for that premium, clean look
  static TextStyle get _baseFont => GoogleFonts.inter();

  // Display - for empty states, major headings
  static TextStyle get displayLarge => _baseFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle get displayMedium => _baseFont.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.3,
  );

  // Headline - section headers
  static TextStyle get headlineLarge => _baseFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
  );

  static TextStyle get headlineMedium => _baseFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
  );

  static TextStyle get headlineSmall => _baseFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body - main content text
  static TextStyle get bodyLarge => _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6, // Taller line height for readability
    letterSpacing: 0,
  );

  static TextStyle get bodyMedium => _baseFont.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );

  static TextStyle get bodySmall => _baseFont.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.2,
  );

  // Label - UI elements, badges
  static TextStyle get labelLarge => _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.35,
    letterSpacing: 0.1,
  );

  static TextStyle get labelSmall => _baseFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // Caption - smallest, for timestamps and meta
  static TextStyle get caption => _baseFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.2,
    letterSpacing: 0.3,
  );
}
