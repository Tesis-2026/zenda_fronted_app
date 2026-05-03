import 'package:flutter/material.dart';

class AppTheme {
  // Light colors
  static const Color primary = Color(0xFF34D399);
  static const Color secondary = Color(0xFF60A5FA);
  static const Color background = Color(0xFFF9FAFB);
  static const Color textPrimary = Color(0xFF1F2937);
  static const Color textSecondary = Color(0xFF6B7280);

  // Dark colors
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkCard = Color(0xFF1E293B);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.fromSwatch().copyWith(primary: primary, secondary: secondary),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F2937),
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      // Consistent bold title across all screens using AppBar
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1F2937),
        letterSpacing: -0.2,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textSecondary),
    ),
    // Global input decoration — visible borders in all states for accessibility
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF9FAFB),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFD1D5DB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF34D399), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark).copyWith(
      primary: primary,
      secondary: const Color(0xFF38BDF8),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkCard,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: -0.2,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF1E293B),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFF34D399), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
      hintStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
    ),
  );
}
