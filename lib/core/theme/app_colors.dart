// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

/// App-wide color palette - Editorial Modern (Midnight Slate + Optical Alabaster)
class AppColors {
  AppColors._();

  // Backgrounds - Crisp & Clean
  static const Color backgroundPrimary = Color(0xFFFAFAF8); // Optical Alabaster (Primary BG)
  static const Color backgroundSurface = Color(0xFFFFFFFF); // Pure White (Cards/Modals)
  static const Color backgroundElevated = Color(0xFFF2F2F0); // Subtle Gray Offset
  
  // Accents - Sophisticated Teal Identity
  static const Color accentPrimary = Color(0xFF0C4B4F);   // Brand Dark Teal
  static const Color accentSecondary = Color(0xFF2C3E50); // Midnight Slate
  static const Color accentTertiary = Color(0xFFC16E5D);  // Soft Terracotta
  static const Color brandDarkTeal = Color(0xFF0C4B4F);   // Keep for compatibility
  
  // Semantic Colors
  static const Color success = Color(0xFF3A5A40); // Muted Forest (Health & Growth)
  static const Color info = Color(0xFF4B6EAF);    // Professional Blue
  static const Color warning = Color(0xFFC9974C); // Muted Amber
  static const Color error = Color(0xFF9E3A3A);   // Deep Red
  
  // Text Colors - Ink & Grays
  static const Color textPrimary = Color(0xFF1A1A1A);   // Deep Ink (Optimal Readability)
  static const Color textSecondary = Color(0xFF4B4B4B); // Slate Graphite
  static const Color textTertiary = Color(0xFF767676);  // Cool Gray
  static const Color textInverted = Color(0xFFFFFFFF);  // White
  
  // Functional Colors - Precision Borders
  static const Color borderLight = Color(0xFFE5E5E3);   // Subtle Paper Border
  static const Color borderMedium = Color(0xFFCACACE);  // Visible Divider
  static const Color borderDark = Color(0xFF4B4B4B);    // Strong Outline
  static const Color shadow = Color(0x0A000000);        // Purely neutral soft shadow
  
  // Dark Mode - Elegant Night
  static const Color darkBackgroundPrimary = Color(0xFF121212);
  static const Color darkBackgroundSurface = Color(0xFF1E1E1E);
  static const Color darkBackgroundElevated = Color(0xFF2C2C2C);
  
  static const Color darkTextPrimary = Color(0xFFF9F9F9);
  static const Color darkTextSecondary = Color(0xFFCACACE);
  static const Color darkTextTertiary = Color(0xFF999999);
  
  // Compatibility Keys (Mapped to Neutral Palette)
  static const Color gray100 = Color(0xFFF2F2F0);
  static const Color gray200 = Color(0xFFE5E5E3);
  static const Color gray300 = Color(0xFFCACACE);
  static const Color gray400 = Color(0xFF767676);
  
  static const Color confidenceHigh = success;
  static const Color confidenceMedium = warning;
  static const Color confidenceLow = error;
}
