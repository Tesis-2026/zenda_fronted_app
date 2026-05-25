import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/local_kv_store.dart';
import '../core/services/accounts_repository.dart';
import '../core/services/transactions_repository.dart';
import '../core/services/streak_repository.dart';
import '../core/services/transaction_api_service.dart';
import '../core/services/category_api_service.dart';
import '../core/services/user_api_service.dart';
import '../core/services/pending_transaction_queue.dart';
import '../core/services/sync_service.dart';

final localKvStoreProvider = Provider<LocalKvStore>((ref) {
  return LocalKvStore();
});

final accountsRepositoryProvider = Provider<AccountsRepository>((ref) {
  return AccountsRepository(ref.read(localKvStoreProvider));
});

final transactionsRepositoryProvider = Provider<TransactionsRepository>((ref) {
  return TransactionsRepository(ref.read(localKvStoreProvider));
});

final streakRepositoryProvider = Provider<StreakRepository>((ref) {
  return StreakRepository(ref.read(localKvStoreProvider));
});

final transactionApiServiceProvider = Provider<TransactionApiService>((ref) {
  return TransactionApiService();
});

final categoryApiServiceProvider = Provider<CategoryApiService>((ref) {
  return CategoryApiService();
});

final notificationsServiceProvider = Provider<NotificationsApiService>((ref) {
  return NotificationsApiService();
});

final pendingTransactionQueueProvider = Provider<PendingTransactionQueue>((ref) {
  return PendingTransactionQueue();
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final service = SyncService(
    ref.read(pendingTransactionQueueProvider),
    ref.read(transactionApiServiceProvider),
  );
  ref.onDispose(service.dispose);
  service.startListening();
  return service;
});

// ── User number-format preference (B5 / cross-screen state) ──────────
// The format ('dot' vs 'comma') used to live as setState inside
// ProfileScreen. Other screens that format amounts (dashboard, reports)
// only re-read SharedPreferences on first build, so a change in profile
// wasn't visible elsewhere until app restart. Promoting to a Notifier
// fixes that: amountFormatterProvider now watches this provider and
// every screen using it rebuilds on change.

/// One of 'dot' (1,234.56) or 'comma' (1.234,56). Default is 'dot'.
typedef NumberFormatPref = String;

const _kNumberFormatKey = 'zenda.number_format';

class NumberFormatNotifier extends AsyncNotifier<NumberFormatPref> {
  @override
  Future<NumberFormatPref> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kNumberFormatKey) ?? 'dot';
  }

  Future<void> setFormat(NumberFormatPref format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kNumberFormatKey, format);
    state = AsyncData(format);
  }
}

final numberFormatProvider =
    AsyncNotifierProvider<NumberFormatNotifier, NumberFormatPref>(
  NumberFormatNotifier.new,
);
