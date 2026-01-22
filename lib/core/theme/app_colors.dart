// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// App-wide color palette - Perplexity-inspired modern minimalist
class AppColors {
  AppColors._();

  // Backgrounds - Minimalist Elite
  static const Color backgroundPrimary = Color(0xFFF9FAFB); // Gray 50 (Off-white)
  static const Color backgroundSurface = Color(0xFFFFFFFF); // Pure White
  static const Color backgroundElevated = Color(0xFFF3F4F6); // Gray 100
  
  // Accent - Minimalist Elite (Anthracite & Slate)
  static const Color accentPrimary = Color(0xFF1A1A1A); // Anthracite / Near Black
  static const Color accentSecondary = Color(0xFF64748B); // Slate Gray 500
  static const Color accentTertiary = Color(0xFF94A3B8); // Slate 400
  
  // Semantic Colors (High contrast, slightly muted)
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color info = Color(0xFF3B82F6);    // Blue 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color error = Color(0xFFEF4444);   // Red 500

  // Text Colors
  static const Color textPrimary = Color(0xFF1A1A1A);   // Anthracite
  static const Color textSecondary = Color(0xFF4B5563); // Gray 600
  static const Color textTertiary = Color(0xFF6B7280);  // Gray 500
  static const Color textInverted = Color(0xFFFFFFFF);  // White

  // Functional Colors
  static const Color borderLight = Color(0xFFE5E7EB);   // Gray 200
  static const Color borderMedium = Color(0xFFD1D5DB);  // Gray 300
  static const Color borderDark = Color(0xFF262626);    // Anthracite Border
  static const Color shadow = Color(0x0A000000);        // Very soft shadow

  // Dark Mode - Minimalist Elite (Anthracite Dark)
  static const Color darkBackgroundPrimary = Color(0xFF0A0A0A);  // Near Black
  static const Color darkBackgroundSurface = Color(0xFF121212);  // Near Black Surface
  static const Color darkBackgroundElevated = Color(0xFF1E1E1E); // Elevated Surface
  
  static const Color darkTextPrimary = Color(0xFFF5F5F5);   // Crisp White/Gray
  static const Color darkTextSecondary = Color(0xFF9CA3AF); // Gray 400
  static const Color darkTextTertiary = Color(0xFF6B7280);  // Gray 500
  
  // Compatibility Keys (Mapped to Minimalist Palette)
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB); // Same as borderLight
  static const Color gray300 = Color(0xFFD1D5DB); // Same as borderMedium
  static const Color gray400 = Color(0xFF9CA3AF);
  
  static const Color confidenceHigh = Color(0xFF10B981);   // Mapped to success
  static const Color confidenceMedium = Color(0xFFF59E0B); // Mapped to warning
  static const Color confidenceLow = Color(0xFFEF4444);    // Mapped to error
}
