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
    return format.whenData((fmt) => (double amount) => _format(amount, fmt));
  },
);

String _format(double amount, String format) {
  final fixed = amount.toStringAsFixed(2);
  final parts = fixed.split('.');
  if (format == 'comma') {
    final intPart = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (m) => '${m[1]}.',
    );
    return '$intPart,${parts[1]}';
  }
  final intPart = parts[0].replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (m) => '${m[1]},',
  );
  return '$intPart.${parts[1]}';
}
