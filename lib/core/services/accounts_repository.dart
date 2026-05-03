import '../models/account.dart';
import 'local_kv_store.dart';

class AccountsRepository {
  AccountsRepository(this._store);

  final LocalKvStore _store;

  Future<List<Account>> getAccounts() async {
    final rows = await _store.readJsonList(_store.accountsKey);
    return rows.map(Account.fromJson).toList();
  }

  Future<void> saveAccounts(List<Account> accounts) async {
    await _store.writeJsonList(
      _store.accountsKey,
      accounts.map((a) => a.toJson()).toList(),
    );
  }

  Future<Account?> getById(String id) async {
    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  Future<void> upsert(Account next) async {
    final accounts = await getAccounts();
    final updated = accounts.map((a) => a.id == next.id ? next : a).toList();
    if (!updated.any((a) => a.id == next.id)) {
      updated.add(next);
    }
    await saveAccounts(updated);
  }

  Future<void> upsertMany(List<Account> nextAccounts) async {
    final accounts = await getAccounts();
    final byId = {for (final a in accounts) a.id: a};
    for (final a in nextAccounts) {
      byId[a.id] = a;
    }
    await saveAccounts(byId.values.toList());
  }
}
