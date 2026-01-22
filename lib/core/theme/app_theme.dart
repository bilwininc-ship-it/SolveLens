import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// SolveLens Elite Dark Theme
/// Minimalist design with 8px rounded corners for buttons
class AppTheme {
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    
    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.cyanNeon,
      secondary: AppColors.cyanNeonDim,
      surface: AppColors.navyLight,
      background: AppColors.navy,
      error: AppColors.error,
      onPrimary: AppColors.navy,
      onSecondary: AppColors.navy,
      onSurface: AppColors.ivory,
      onBackground: AppColors.ivory,
      onError: AppColors.white,
    ),
    
    // AppBar Theme
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.navyDark,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.ivory,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(color: AppColors.cyanNeon),
    ),
    
    // Card Theme
    cardTheme: const CardThemeData(
      color: AppColors.navyLight,
      elevation: 4,
      shadowColor: AppColors.cyanNeon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    
    // Elevated Button Theme - 8px Border Radius (Elite & Minimalist)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.cyanNeon,
        foregroundColor: AppColors.navy,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 8px as required
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Outlined Button Theme - 8px Border Radius
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cyanNeon,
        side: const BorderSide(color: AppColors.cyanNeon, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // 8px as required
        ),
        textStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.cyanNeon,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    
    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.navyLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // 8px consistency
        borderSide: const BorderSide(color: AppColors.greyDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.greyDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cyanNeon, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.grey, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.greyDark, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    
    // Text Theme - Thin & Elite Fonts
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppColors.ivory,
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displayMedium: TextStyle(
        color: AppColors.ivory,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: AppColors.ivory,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineMedium: TextStyle(
        color: AppColors.ivory,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.ivory,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: AppColors.ivory,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.greyLight,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: TextStyle(
        color: AppColors.grey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: TextStyle(
        color: AppColors.greyDark,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: TextStyle(
        color: AppColors.cyanNeon,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.greyDark,
      thickness: 1,
      space: 1,
    ),
    
    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.cyanNeon,
      size: 24,
    ),
  );
}