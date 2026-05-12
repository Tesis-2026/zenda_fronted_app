import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized typography constants.
/// Use these instead of ad-hoc TextStyle() in widgets.
abstract final class AppTextStyles {
  // Display / Hero
  static const h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textDark,
  );

  // Screen titles (AppBar)
  static const h2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    color: AppColors.textDark,
  );

  // Section / card headings
  static const h3 = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Sub-section labels
  static const h4 = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textMuted,
    letterSpacing: 0.4,
  );

  // Body — primary
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textDark,
    height: 1.5,
  );

  // Body — muted / secondary
  static const bodyMuted = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.5,
  );

  // Small label
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  // Small bold label (chip text, badges)
  static const label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  // Amount / financial figures
  static const amount = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textDark,
  );

  static const amountSmall = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );

  // Button text
  static const button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  // Helpers: return a copy with given color (for dark mode adaption)
  static TextStyle withColor(TextStyle base, Color color) =>
      base.copyWith(color: color);
}
