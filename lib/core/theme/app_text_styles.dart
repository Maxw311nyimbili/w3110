// lib/core/theme/app_text_styles.dart
// Naiia Brand — Poppins for UI & body (Brand Guide §04)

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Font bases ────────────────────────────────────────────────────────────
  static TextStyle get _poppins => GoogleFonts.poppins();

  // ─── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _poppins.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.6,
  );

  static TextStyle get displayMedium => _poppins.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.4,
  );

  static TextStyle get displaySmall => _poppins.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: -0.2,
  );

  // ─── Headline ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => _poppins.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.1,
  );

  static TextStyle get headlineMedium => _poppins.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
  );

  static TextStyle get headlineSmall => _poppins.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ─── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _poppins.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.65,
  );

  static TextStyle get bodyMedium => _poppins.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );

  static TextStyle get bodySmall => _poppins.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.55,
  );

  // ─── Label ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => _poppins.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => _poppins.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.2,
  );

  static TextStyle get labelSmall => _poppins.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.3,
  );

  // ─── Caption / overline ────────────────────────────────────────────────────
  static TextStyle get caption => _poppins.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );

  static TextStyle get overline => _poppins.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.6,
    color: AppColors.textTertiary,
  );
}
