import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/repositories_providers.dart';

/// Returns a formatter function for monetary amounts.
///
///   'dot'   → 1,234.56  (default)
///   'comma' → 1.234,56
///
/// Reactively rebuilds when the user changes their number-format
/// preference in profile, so dashboard/reports update without a
/// restart (B5).
final amountFormatterProvider = Provider<AsyncValue<String Function(double)>>(
  (ref) {
    final format = ref.watch(numberFormatProvider);
    return format.whenData((fmt) => (double amount) => formatAmount(amount, fmt));
  },
);

/// Formats [amount] with thousands grouping per [format] ('dot' | 'comma').
String formatAmount(double amount, String format, {int decimals = 2}) {
  final fixed = amount.toStringAsFixed(decimals);
  final parts = fixed.split('.');
  final groupSeparator = format == 'comma' ? '.' : ',';
  final decimalSeparator = format == 'comma' ? ',' : '.';
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]}$groupSeparator',
  );
  return parts.length > 1 ? '$intPart$decimalSeparator${parts[1]}' : intPart;
}
