import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preference key matching the one used in profile_screen.dart.
const _kNumberFormatKey = 'zenda.number_format';

/// Asynchronously resolves the user's stored number-format preference and
/// returns a formatting function for monetary amounts.
///
/// 'dot'   → 1,234.56  (default)
/// 'comma' → 1.234,56
final amountFormatterProvider = FutureProvider<String Function(double)>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final format = prefs.getString(_kNumberFormatKey) ?? 'dot';
  return (double amount) {
    final fixed = amount.toStringAsFixed(2);
    if (format == 'comma') {
      // Integer part: replace thousands separator dot, then swap decimal dot → comma.
      final parts = fixed.split('.');
      final intPart = parts[0].replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+$)'),
        (m) => '${m[1]}.',
      );
      return '$intPart,${parts[1]}';
    }
    // dot-decimal: add thousands comma separator.
    final parts = fixed.split('.');
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]},',
    );
    return '$intPart.${parts[1]}';
  };
});
