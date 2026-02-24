import 'package:flutter/material.dart';

/// Utilities for handling responsive layouts based on screen width
class ResponsiveUtils {
  /// Mobile breakpoint (phones)
  static const double mobileBreakpoint = 600;

  /// Tablet breakpoint (tablets, small laptops)
  static const double tabletBreakpoint = 1024;

  /// Returns true if the screen width is considered mobile
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  /// Returns true if the screen width is considered tablet
  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < tabletBreakpoint;

  /// Returns true if the screen width is considered desktop
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletBreakpoint;

  /// Returns the width constrained for readability (max 800px)
  static double getReadableWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 800) return 800;
    return width;
  }
}
