import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BuildContext extension providing dark-mode-aware color tokens.
/// Usage: `context.colors.bg`, `context.colors.card`, etc.
extension ZendaThemeX on BuildContext {
  ZendaColors get colors => ZendaColors(
        isDark: Theme.of(this).brightness == Brightness.dark,
      );
}

class ZendaColors {
  final bool isDark;
  const ZendaColors({required this.isDark});

  Color get bg =>
      isDark ? AppColors.darkPageBackground : AppColors.pageBackground;
  Color get card =>
      isDark ? AppColors.darkCard : AppColors.cardBackground;
  Color get cardElevated =>
      isDark ? AppColors.darkCardElevated : AppColors.fillLight;
  Color get fill =>
      isDark ? AppColors.darkFill : AppColors.fillLight;
  Color get border =>
      isDark ? AppColors.darkBorder : AppColors.border;
  Color get textPrimary =>
      isDark ? AppColors.darkTextPrimary : AppColors.textDark;
  Color get textMuted =>
      isDark ? AppColors.darkTextMuted : AppColors.textMuted;
  Color get textSubtle =>
      isDark ? AppColors.darkTextSubtle : AppColors.textSubtle;

  // Shorthand for primary brand color (same in both modes)
  Color get primary => AppColors.primary;
  Color get primaryLight =>
      isDark ? const Color(0xFF064E3B) : AppColors.primaryLight;

  // Icon tint
  Color get icon =>
      isDark ? AppColors.darkTextMuted : AppColors.textSubtle;
  Color get iconStrong =>
      isDark ? AppColors.darkTextPrimary : AppColors.textDark;
}
