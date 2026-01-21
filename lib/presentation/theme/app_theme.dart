// Premium Elite Professor Theme - Navy & White (Ivy League Style)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Elite Professor Color Palette - Navy & White (Academic Research Station)
  static const Color primaryNavy = Color(0xFF0A192F); // Dark Navy Blue #0A192F
  static const Color navyDark = Color(0xFF1E293B); // Darker Navy
  static const Color navyGradientEnd = Color(0xFF1A2F4F); // Navy gradient end
  static const Color cyanNeon = Color(0xFF00F0FF); // Cyan Neon Accent #00F0FF
  static const Color brightBlue = Color(0xFF3B82F6); // Accent Bright Blue
  static const Color ivory = Color(0xFFF9F9F7); // Ivory Background #F9F9F7
  static const Color cleanWhite = Color(0xFFFFFFFF); // Pure White Background
  static const Color lightGrey = Color(0xFFF8FAFC); // Light Grey Surface
  static const Color mediumGrey = Color(0xFF64748B); // Medium Grey Text
  static const Color darkGrey = Color(0xFF334155); // Dark Grey Text
  static const Color premiumGold = Color(0xFFF59E0B); // Accent Gold for premium features
  
  // Status Colors
  static const Color successGreen = Color(0xFF10B981);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color warningOrange = Color(0xFFF59E0B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ivory, // Academic Research Station background
      
      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: primaryNavy,
        secondary: brightBlue,
        surface: lightGrey,
        error: errorRed,
        onPrimary: cleanWhite,
        onSecondary: cleanWhite,
        onSurface: textPrimary,
        onError: cleanWhite,
        tertiary: premiumGold,
      ),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: cleanWhite,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: primaryNavy),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cleanWhite,
        elevation: 2,
        shadowColor: primaryNavy.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: lightGrey,
            width: 1,
          ),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: cleanWhite,
          elevation: 2,
          shadowColor: primaryNavy.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryNavy,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          side: const BorderSide(color: primaryNavy, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: mediumGrey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryNavy, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorRed),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textTertiary),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: primaryNavy,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: DividerThemeData(
        color: mediumGrey.withOpacity(0.2),
        thickness: 1,
      ),
      
      // FloatingActionButton Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryNavy,
        foregroundColor: cleanWhite,
        elevation: 4,
      ),
      
      // BottomNavigationBar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cleanWhite,
        selectedItemColor: primaryNavy,
        unselectedItemColor: mediumGrey,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
