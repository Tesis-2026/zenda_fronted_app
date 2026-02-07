import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DarkTheme {
  static final Color bg = const Color(0xFF0F172A);
  static final ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme.dark(
      background: bg,
      primary: const Color(0xFF34D399),
      secondary: const Color(0xFF38BDF8),
    ),
    textTheme: GoogleFonts.interTextTheme().apply(bodyColor: const Color(0xFFF1F5F9)),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(backgroundColor: Color(0xFF34D399)),
  );
}
