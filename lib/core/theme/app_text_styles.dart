// lib/core/theme/app_text_styles.dart
// Hope UI Inspired — DM Sans Typography System

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cap_project/core/theme/app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ─── Font bases ────────────────────────────────────────────────────────────
  static TextStyle get _base    => GoogleFonts.dmSans();
  static TextStyle get _display => GoogleFonts.dmSans();

  // ─── Display ───────────────────────────────────────────────────────────────
  static TextStyle get displayLarge => _display.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.15,
    letterSpacing: -0.8,
    color: AppColors.textPrimary,
  );

  static TextStyle get displayMedium => _display.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get displaySmall => _display.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  // ─── Headline ──────────────────────────────────────────────────────────────
  static TextStyle get headlineLarge => _display.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineMedium => _display.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: -0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get headlineSmall => _display.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  // ─── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.65,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodyMedium => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    color: AppColors.textPrimary,
  );

  static TextStyle get bodySmall => _base.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.55,
    color: AppColors.textSecondary,
  );

  // ─── Label ─────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  static TextStyle get labelMedium => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.35,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  static TextStyle get labelSmall => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.4,
    color: AppColors.textTertiary,
  );

  // ─── Caption / Overline ────────────────────────────────────────────────────
  static TextStyle get caption => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
  );

  static TextStyle get overline => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.4,
    color: AppColors.textTertiary,
  );
}
