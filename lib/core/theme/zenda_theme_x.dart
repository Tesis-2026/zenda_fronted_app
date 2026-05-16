import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BuildContext extension exposing the app's color tokens.
/// Usage: `context.colors.bg`, `context.colors.card`, etc.
extension ZendaThemeX on BuildContext {
  ZendaColors get colors => const ZendaColors();
}

class ZendaColors {
  const ZendaColors();

  Color get bg => AppColors.pageBackground;
  Color get card => AppColors.cardBackground;
  Color get cardElevated => AppColors.fillLight;
  Color get fill => AppColors.fillLight;
  Color get border => AppColors.border;
  Color get textPrimary => AppColors.textDark;
  Color get textMuted => AppColors.textMuted;
  Color get textSubtle => AppColors.textSubtle;

  Color get primary => AppColors.primary;
  Color get primaryLight => AppColors.primaryLight;

  Color get icon => AppColors.textSubtle;
  Color get iconStrong => AppColors.textDark;
}
