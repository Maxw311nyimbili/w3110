// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AppTextStyles {
  // Primary font for body
  static TextStyle get _baseFont => GoogleFonts.inter();
  
  // High-performance display font for headlines
  static TextStyle get _displayFont => GoogleFonts.plusJakartaSans();

  // Display
  static TextStyle get displayLarge => _displayFont.copyWith(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    letterSpacing: -1.0,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => _displayFont.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => _displayFont.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
  );

  // Headline
  static TextStyle get headlineLarge => _displayFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => _displayFont.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => _displayFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // Body
  static TextStyle get bodyLarge => _baseFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.6,
  );

  static TextStyle get bodyMedium => _baseFont.copyWith(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodySmall => _baseFont.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // Label
  static TextStyle get labelLarge => _baseFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => _baseFont.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get labelSmall => _baseFont.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.2,
  );

  // Caption
  static TextStyle get caption => _baseFont.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.3,
  );
}
