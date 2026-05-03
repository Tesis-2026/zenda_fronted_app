import '../models/transaction.dart';
import 'local_kv_store.dart';

class TransactionsRepository {
  TransactionsRepository(this._store);

  final LocalKvStore _store;

  Future<List<TransactionModel>> getTransactions() async {
    final rows = await _store.readJsonList(_store.transactionsKey);
    return rows.map(TransactionModel.fromJson).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> saveTransactions(List<TransactionModel> txs) async {
    await _store.writeJsonList(
      _store.transactionsKey,
      txs.map((t) => t.toJson()).toList(),
    );
  }

  Future<void> addTransaction(TransactionModel tx) async {
    final txs = await getTransactions();
    txs.insert(0, tx);
    await saveTransactions(txs);
  }
}
