import '../models/transaction.dart';
import 'local_kv_store.dart';

class TransactionsRepository {
  TransactionsRepository(this._store);

  final LocalKvStore _store;

  Future<List<TransactionModel>> getTransactions() async {
    final rows = await _store.readJsonList(_store.transactionsKey);
    if (rows.isEmpty) {
      final seed = _seedTransactions();
      await saveTransactions(seed);
      return seed;
    }
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

  List<TransactionModel> _seedTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: 'seed_1',
        userId: 'demo',
        accountId: '1',
        kind: TransactionKind.expense,
        amount: 45.00,
        category: TransactionCategory.comida,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(hours: 2)),
        source: TransactionSource.manual,
        note: 'Almuerzo menú',
      ),
      TransactionModel(
        id: 'seed_2',
        userId: 'demo',
        accountId: '2',
        kind: TransactionKind.expense,
        amount: 12.50,
        category: TransactionCategory.transporte,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(hours: 5)),
        source: TransactionSource.manual,
        note: 'Taxi',
      ),
      TransactionModel(
        id: 'seed_3',
        userId: 'demo',
        accountId: '3',
        kind: TransactionKind.expense,
        amount: 150.00,
        category: TransactionCategory.ocio,
        bucket: Bucket503020.deseo,
        timestamp: now.subtract(const Duration(days: 1)),
        source: TransactionSource.manual,
        note: 'Salida cine y cena',
      ),
      TransactionModel(
        id: 'seed_4',
        userId: 'demo',
        accountId: '2',
        kind: TransactionKind.expense,
        amount: 80.00,
        category: TransactionCategory.vivienda,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
        note: 'Compras supermercado',
      ),
      TransactionModel(
        id: 'seed_5',
        userId: 'demo',
        accountId: '1',
        kind: TransactionKind.expense,
        amount: 200.00,
        category: TransactionCategory.ahorro,
        bucket: Bucket503020.ahorro,
        timestamp: now.subtract(const Duration(days: 3)),
        source: TransactionSource.manual,
        note: 'Fondo de emergencia',
      ),
    ];
  }
}
