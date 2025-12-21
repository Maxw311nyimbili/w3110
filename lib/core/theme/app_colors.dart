// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// App-wide color palette - Perplexity-inspired modern minimalist
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color backgroundPrimary = Color(0xFFF9FAFB); // Classic light gray background
  static const Color backgroundSurface = Color(0xFFFFFFFF);
  static const Color backgroundElevated = Color(0xFFFFFFFF);

  // Dark Mode Backgrounds
  static const Color darkBackgroundPrimary = Color(0xFF191A1A); // Perplexity Dark
  static const Color darkBackgroundSurface = Color(0xFF222222);
  static const Color darkBackgroundElevated = Color(0xFF2D2D2D);

  // Text
  static const Color textPrimary = Color(0xFF111827); // Nearly black
  static const Color textSecondary = Color(0xFF6B7280); // Cool gray
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Dark Mode Text
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextTertiary = Color(0xFF6B7280);

  // Accent - Sophisticated Neutral (Anthracite/Slate)
  static const Color accentPrimary = Color(0xFF1E293B); // Slate 800
  static const Color accentLight = Color(0xFFF1F5F9);   // Slate 50
  static const Color accentDark = Color(0xFF0F172A);    // Slate 900

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Borders & Dividers
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderDark = Color(0xFF374151);

  // Neutral Grays (Restored for compat)
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF); // Added missing gray400

  // Confidence indicators (for chat)
  static const Color confidenceHigh = Color(0xFF10B981);
  static const Color confidenceMedium = Color(0xFFF59E0B);
  static const Color confidenceLow = Color(0xFFEF4444);
}
