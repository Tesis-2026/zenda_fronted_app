import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centralized category icon and color mapping.
/// All screens should use these helpers instead of local switch statements.
abstract final class CategoryUtils {
  static IconData iconForCategory(String? name) {
    if (name == null) return Icons.swap_horiz_rounded;
    return switch (name.toLowerCase()) {
      'food' || 'comida' => Icons.restaurant_rounded,
      'transportation' || 'transporte' => Icons.directions_bus_rounded,
      'housing' || 'vivienda' => Icons.home_rounded,
      'utilities' || 'servicios' => Icons.bolt_rounded,
      'health' || 'salud' => Icons.favorite_rounded,
      'entertainment' || 'entretenimiento' => Icons.sports_esports_rounded,
      'shopping' || 'compras' => Icons.shopping_bag_rounded,
      'subscriptions' || 'suscripciones' => Icons.subscriptions_rounded,
      'cravings' || 'antojos' => Icons.icecream_rounded,
      'savings' || 'ahorro' => Icons.savings_rounded,
      _ => Icons.category_rounded,
    };
  }

  static Color bgColorForCategory(String? name, {bool isIncome = false}) {
    if (isIncome) return AppColors.primaryLight;
    if (name == null) return AppColors.dangerLight;
    return switch (name.toLowerCase()) {
      'food' || 'comida' => AppColors.warningLight,
      'transportation' || 'transporte' => const Color(0xFFDBEAFE),
      'housing' || 'vivienda' => AppColors.infoLight,
      'health' || 'salud' => const Color(0xFFFCE7F3),
      'savings' || 'ahorro' => AppColors.primaryLight,
      _ => AppColors.dangerLight,
    };
  }

  static Color iconColorForCategory(String? name, {bool isIncome = false}) {
    if (isIncome) return AppColors.income;
    if (name == null) return AppColors.danger;
    return switch (name.toLowerCase()) {
      'food' || 'comida' => AppColors.warning,
      'transportation' || 'transporte' => const Color(0xFF3B82F6),
      'housing' || 'vivienda' => AppColors.info,
      'health' || 'salud' => const Color(0xFFEC4899),
      'savings' || 'ahorro' => AppColors.income,
      _ => AppColors.danger,
    };
  }

  /// Returns a widget with the category icon inside a colored rounded square.
  static Widget iconWidget(
    String? categoryName, {
    bool isIncome = false,
    double size = 44,
    double iconSize = 20,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColorForCategory(categoryName, isIncome: isIncome),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        iconForCategory(categoryName),
        color: iconColorForCategory(categoryName, isIncome: isIncome),
        size: iconSize,
      ),
    );
  }
}
