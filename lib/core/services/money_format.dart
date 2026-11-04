import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_controller.dart';
import '../../providers/repositories_providers.dart';
import 'amount_formatter.dart';

/// Display-only currency + number-format preference (CP061). Amounts are
/// stored in the user's currency as entered; there is no FX conversion.
@immutable
class MoneyFormat {
  const MoneyFormat({required this.currency, required this.numberFormat});

  /// ISO code from the profile: 'PEN' or 'USD'.
  final String currency;

  /// 'dot' (1,234.56) or 'comma' (1.234,56).
  final String numberFormat;

  String get symbol => currency == 'USD' ? 'US\$' : 'S/';

  /// Formats [amount] with the currency symbol, e.g. `S/ 1,234.50`.
  String format(double amount, {int decimals = 2}) =>
      '$symbol ${formatAmount(amount, numberFormat, decimals: decimals)}';

  @override
  bool operator ==(Object other) =>
      other is MoneyFormat &&
      other.currency == currency &&
      other.numberFormat == numberFormat;

  @override
  int get hashCode => Object.hash(currency, numberFormat);
}

final moneyFormatProvider = Provider<MoneyFormat>((ref) {
  final currency = ref.watch(authNotifierProvider).user?.currency;
  final numberFormat = ref.watch(numberFormatProvider).asData?.value ?? 'dot';
  return MoneyFormat(
    currency: currency == null || currency.isEmpty ? 'PEN' : currency,
    numberFormat: numberFormat,
  );
});

/// Provided at the app root so every widget that formats money rebuilds when
/// the preference changes, without restarting the app.
class MoneyScope extends InheritedWidget {
  const MoneyScope({super.key, required this.format, required super.child});

  final MoneyFormat format;

  static MoneyFormat of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MoneyScope>()?.format ??
      const MoneyFormat(currency: 'PEN', numberFormat: 'dot');

  @override
  bool updateShouldNotify(MoneyScope oldWidget) => format != oldWidget.format;
}

extension MoneyX on BuildContext {
  /// `S/ 1,234.50` (or `US$ …`) following the user's preferences.
  String money(double amount, {int decimals = 2}) =>
      MoneyScope.of(this).format(amount, decimals: decimals);

  /// Just the currency symbol, for input prefixes.
  String get currencySymbol => MoneyScope.of(this).symbol;
}
