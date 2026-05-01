import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/auth_controller.dart';

/// Returns the currency symbol for the authenticated user.
/// Defaults to "S/" (PEN) if no user or unknown currency code.
final currencySymbolProvider = Provider<String>((ref) {
  final user = ref.watch(authNotifierProvider).user;
  if (user == null) return 'S/';
  return _symbolFor(user.currency);
});

String _symbolFor(String currencyCode) {
  return switch (currencyCode.toUpperCase()) {
    'PEN' => 'S/',
    'USD' => '\$',
    'EUR' => '€',
    'MXN' => 'MX\$',
    'COP' => 'COL\$',
    'ARS' => 'AR\$',
    'CLP' => 'CL\$',
    _ => currencyCode,
  };
}
