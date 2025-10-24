// lib/core/theme/app_spacing.dart

/// 4pt base grid spacing system - DO NOT use arbitrary values
class AppSpacing {
  AppSpacing._();

  // Base unit
  static const double base = 4.0;

  // Micro spacing
  static const double xs = base; // 4pt
  static const double sm = base * 2; // 8pt

  // Standard spacing
  static const double md = base * 3; // 12pt
  static const double lg = base * 4; // 16pt
  static const double xl = base * 6; // 24pt

  // Generous spacing
  static const double xxl = base * 8; // 32pt
  static const double xxxl = base * 12; // 48pt

  // Consistent horizontal padding across app
  static const double screenHorizontal = lg; // 16pt
  static const double screenHorizontalLarge = xl; // 24pt

  // Vertical section spacing
  static const double sectionVertical = xl; // 24pt
  static const double sectionVerticalLarge = xxl; // 32pt
}