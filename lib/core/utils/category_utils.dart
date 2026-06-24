import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Centralized category icon and color mapping.
/// All screens should use these helpers instead of local switch statements.
///
/// Resolution order for icons:
///   1. The backend-provided semantic [iconKey] (e.g. 'food', 'transport').
///   2. A legacy match on the category [name] (covers the fixed transaction
///      enum and any category without a key).
///   3. A single default icon ([customCategoryIcon]) — used for custom
///      categories, whose name already differentiates them.
abstract final class CategoryUtils {
  /// The one icon every custom (or unkeyed/unknown) category falls back to.
  static const IconData customCategoryIcon = Icons.label_rounded;

  /// Backend icon key → IconData. Keep in sync with the seed's
  /// ICON_BY_CATEGORY_NAME map in the backend.
  static const Map<String, IconData> _iconByKey = {
    'food': Icons.restaurant_rounded,
    'transport': Icons.directions_bus_rounded,
    'housing': Icons.home_rounded,
    'utilities': Icons.bolt_rounded,
    'health': Icons.favorite_rounded,
    'entertainment': Icons.sports_esports_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'subscriptions': Icons.subscriptions_rounded,
    'cravings': Icons.icecream_rounded,
    'savings': Icons.savings_rounded,
    'education': Icons.school_rounded,
    'scholarship': Icons.school_rounded,
    'work': Icons.work_rounded,
    'family': Icons.family_restroom_rounded,
    'freelance': Icons.laptop_mac_rounded,
    'other': Icons.category_rounded,
  };

  /// Spanish display label for a system category whose backend `name` is kept
  /// in English (English is required for the client's category resolution).
  /// Unknown names (custom categories the user typed) are returned as-is.
  static String labelEs(String? name) {
    if (name == null || name.isEmpty) return '';
    return switch (name.toLowerCase()) {
      'food' => 'Comida',
      'transportation' => 'Transporte',
      'housing' => 'Vivienda',
      'utilities' => 'Servicios',
      'health' => 'Salud',
      'entertainment' => 'Entretenimiento',
      'shopping' => 'Compras',
      'subscriptions' => 'Suscripciones',
      'cravings' => 'Antojos',
      'savings' => 'Ahorro',
      'education' => 'Educación',
      'other' => 'Otros',
      'scholarship' => 'Beca',
      'part-time work' => 'Trabajo part-time',
      'part time work' => 'Trabajo part-time',
      'family' => 'Apoyo familiar',
      'freelance' => 'Freelance',
      _ => name,
    };
  }

  static IconData iconForCategory(
    String? name, {
    String? iconKey,
    bool isCustom = false,
  }) {
    final key = iconKey?.toLowerCase();
    if (key != null && _iconByKey.containsKey(key)) return _iconByKey[key]!;
    if (isCustom) return customCategoryIcon;
    if (name == null) return Icons.swap_horiz_rounded;
    return _iconByName(name.toLowerCase());
  }

  static IconData _iconByName(String name) {
    return switch (name) {
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
      'education' || 'educación' || 'educacion' => Icons.school_rounded,
      'scholarship' || 'beca' => Icons.school_rounded,
      'part-time work' ||
      'part time work' ||
      'trabajoparttime' ||
      'trabajo part time' => Icons.work_rounded,
      'family' ||
      'familia' ||
      'apoyo familiar' => Icons.family_restroom_rounded,
      'freelance' => Icons.laptop_mac_rounded,
      'other' || 'otros' => Icons.category_rounded,
      // Unknown name (a custom category) → single default icon.
      _ => customCategoryIcon,
    };
  }

  static Color bgColorForCategory(
    String? name, {
    bool isIncome = false,
    bool isCustom = false,
  }) {
    if (isIncome) return AppColors.primaryLight;
    if (isCustom) return const Color(0xFFF3F4F6); // neutral for custom
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

  static Color iconColorForCategory(
    String? name, {
    bool isIncome = false,
    bool isCustom = false,
  }) {
    if (isIncome) return AppColors.income;
    if (isCustom) return const Color(0xFF6B7280); // neutral for custom
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
    String? iconKey,
    bool isIncome = false,
    bool isCustom = false,
    double size = 44,
    double iconSize = 20,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColorForCategory(
          categoryName,
          isIncome: isIncome,
          isCustom: isCustom,
        ),
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Icon(
        iconForCategory(categoryName, iconKey: iconKey, isCustom: isCustom),
        color: iconColorForCategory(
          categoryName,
          isIncome: isIncome,
          isCustom: isCustom,
        ),
        size: iconSize,
      ),
    );
  }
}
