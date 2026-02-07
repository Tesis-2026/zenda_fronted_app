import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LightTheme {
  static final Color primary = const Color(0xFF34D399);
  static final Color secondary = const Color(0xFF60A5FA);
  static final Color bg = const Color(0xFFF9FAFB);
  static final Color textPrimary = const Color(0xFF1F2937);
  static final Color textSecondary = const Color(0xFF6B7280);
  static final ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.fromSeed(seedColor: primary, primary: primary, secondary: secondary, background: bg),
    textTheme: GoogleFonts.interTextTheme().apply(bodyColor: textPrimary, displayColor: textPrimary),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: primary),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
