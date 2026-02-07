import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/models/breakdown_503020.dart';

// Fake Data Service (could be separated later)
class DemoDataService {
  List<Account> getAccounts() {
    return [
      const Account(
        id: '1',
        name: 'Efectivo',
        type: AccountType.cash,
        balance: 120.00,
        colorValue: 0xFF34D399,
        iconName: 'attach_money',
      ),
      const Account(
        id: '2',
        name: 'BCP Débito',
        type: AccountType.debit,
        balance: 950.00,
        colorValue: 0xFF60A5FA,
        iconName: 'credit_card',
      ),
      const Account(
        id: '3',
        name: 'Interbank Crédito',
        type: AccountType.credit,
        creditLimit: 1500.00,
        creditAvailable: 1070.00, // Deuda = 1500 - 1070 = 430
        colorValue: 0xFFFCD34D,
        iconName: 'credit_score',
      ),
    ];
  }

  List<TransactionModel> getTransactions() {
    final now = DateTime.now();
    return [
      TransactionModel(
        id: '1',
        userId: 'demo',
        amount: 45.00,
        category: TransactionCategory.comida,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(hours: 2)),
        source: TransactionSource.manual,
        note: 'Almuerzo menú',
      ),
      TransactionModel(
        id: '2',
        userId: 'demo',
        amount: 12.50,
        category: TransactionCategory.transporte,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(hours: 5)),
        source: TransactionSource.manual,
        note: 'Taxi',
      ),
      TransactionModel(
        id: '3',
        userId: 'demo',
        amount: 150.00,
        category: TransactionCategory.ocio,
        bucket: Bucket503020.deseo,
        timestamp: now.subtract(const Duration(days: 1)),
        source: TransactionSource.manual,
        note: 'Salida cine y cena',
      ),
      TransactionModel(
        id: '4',
        userId: 'demo',
        amount: 80.00,
        category: TransactionCategory.vivienda,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(days: 2)),
        source: TransactionSource.manual,
        note: 'Compras supermercado',
      ),
      TransactionModel(
        id: '5',
        userId: 'demo',
        amount: 200.00,
        category: TransactionCategory
            .otros, // Ahorro implementation logic might map specific categories or buckets
        bucket: Bucket503020.ahorro,
        timestamp: now.subtract(const Duration(days: 3)),
        source: TransactionSource.manual,
        note: 'Fondo de emergencia',
      ),
      TransactionModel(
        id: '6',
        userId: 'demo',
        amount: 25.00,
        category: TransactionCategory.comida,
        bucket: Bucket503020.deseo,
        timestamp: now.subtract(const Duration(days: 4)),
        source: TransactionSource.manual,
        note: 'Café Starbucks',
      ),
      TransactionModel(
        id: '7',
        userId: 'demo',
        amount: 60.00,
        category: TransactionCategory.salud,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(days: 5)),
        source: TransactionSource.manual,
        note: 'Farmacia',
      ),
      TransactionModel(
        id: '8',
        userId: 'demo',
        amount: 30.00,
        category: TransactionCategory.transporte,
        bucket: Bucket503020.necesidad,
        timestamp: now.subtract(const Duration(days: 6)),
        source: TransactionSource.manual,
        note: 'Recarga tarjeta',
      ),
      TransactionModel(
        id: '9',
        userId: 'demo',
        amount: 120.00,
        category: TransactionCategory.ocio,
        bucket: Bucket503020.deseo,
        timestamp: now.subtract(const Duration(days: 7)),
        source: TransactionSource.manual,
        note: 'Suscripciones anuales',
      ),
      TransactionModel(
        id: '10',
        userId: 'demo',
        amount: 50.00,
        category: TransactionCategory.otros,
        bucket: Bucket503020.ahorro,
        timestamp: now.subtract(const Duration(days: 8)),
        source: TransactionSource.manual,
        note: 'Ahorro metas',
      ),
    ];
  }
}

final demoDataServiceProvider = Provider((ref) => DemoDataService());

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  // Simulate delay
  await Future.delayed(const Duration(milliseconds: 500));
  return ref.read(demoDataServiceProvider).getAccounts();
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return ref.read(demoDataServiceProvider).getTransactions();
});

final todayExpenseProvider = Provider<double>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionModel>[],
      );
  final now = DateTime.now();
  return transactions
      .where(
        (t) =>
            t.timestamp.year == now.year &&
            t.timestamp.month == now.month &&
            t.timestamp.day == now.day,
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final weekExpenseProvider = Provider<double>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionModel>[],
      );
  final now = DateTime.now();
  final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
  return transactions
      .where(
        (t) =>
            t.timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1))),
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final streakProvider = Provider<int>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionModel>[],
      );
  if (transactions.isEmpty) return 0;

  // Logic: Count consecutive days with transactions backwards from today
  // Implementation simplified for demo: random logic based on data
  // Real implementation would sort by date and count unique dates backwards
  return 5; // Demo static value based on "10 transactions recently"
});

final budgetBreakdownProvider = Provider<BudgetBreakdown503020>((ref) {
  final transactions = ref
      .watch(transactionsProvider)
      .maybeWhen(
        data: (value) => value,
        orElse: () => const <TransactionModel>[],
      );

  double nec = 0;
  double des = 0;
  double aho = 0;

  for (var t in transactions) {
    switch (t.bucket) {
      case Bucket503020.necesidad:
        nec += t.amount;
        break;
      case Bucket503020.deseo:
        des += t.amount;
        break;
      case Bucket503020.ahorro:
        aho += t.amount;
        break;
    }
  }

  return BudgetBreakdown503020(
    totalNecesidades: nec,
    totalDeseos: des,
    totalAhorro: aho,
  );
});

final aiAdviceProvider = Provider<String>((ref) {
  final breakdown = ref.watch(budgetBreakdownProvider);
  if (breakdown.total == 0) return 'Empieza a registrar para recibir consejos.';

  final pDes = breakdown.percentDeseos();
  final pAho = breakdown.percentAhorro();

  if (pDes > 30) {
    return 'Tus "deseos" están volando alto (${pDes.toStringAsFixed(0)}%). Considera reducir gastos hormiga como cafés o taxis para equilibrarte.';
  } else if (pAho < 20) {
    return 'Tu ahorro está bajo (${pAho.toStringAsFixed(0)}%). Intenta separar un monto fijo al inicio de semana, aunque sea pequeño.';
  } else {
    return '¡Vas muy bien! Tu presupuesto está equilibrado. Sigue así y considera invertir tus excedentes.';
  }
});
