import 'package:flutter/material.dart';

/// SolveLens Elite Color Palette
/// Navy, Cyan Neon, Ivory, and Dark Grey theme
class AppColors {
  // Primary Colors - Navy Shades
  static const Color navy = Color(0xFF0A192F);
  static const Color navyLight = Color(0xFF112240);
  static const Color navyDark = Color(0xFF020c1b);
  
  // Accent Color - Cyan Neon
  static const Color cyanNeon = Color(0xFF00F0FF);
  static const Color cyanNeonDim = Color(0xFF00D4E6);
  static const Color cyanNeonBright = Color(0xFF66F6FF);
  
  // Supporting Colors
  static const Color ivory = Color(0xFFF9F9F7);
  static const Color darkGrey = Color(0xFF1E1E1E);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF8892B0);
  static const Color greyLight = Color(0xFFCCD6F6);
  static const Color greyDark = Color(0xFF495670);
  
  // Status Colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF3366);
  static const Color info = Color(0xFF64B5F6);
  
  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}