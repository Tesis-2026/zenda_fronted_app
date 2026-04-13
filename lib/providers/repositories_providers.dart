import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/local_kv_store.dart';
import '../core/services/accounts_repository.dart';
import '../core/services/transactions_repository.dart';
import '../core/services/streak_repository.dart';
import '../core/services/transaction_api_service.dart';
import '../core/services/category_api_service.dart';

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
