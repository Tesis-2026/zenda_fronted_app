import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/models/breakdown_503020.dart';
import '../../core/services/streak_repository.dart';
import '../../providers/repositories_providers.dart';

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  return ref.read(accountsRepositoryProvider).getAccounts();
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  return ref.read(transactionsRepositoryProvider).getTransactions();
});

final streakStateProvider = FutureProvider<StreakState>((ref) async {
  return ref.read(streakRepositoryProvider).getStreak();
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
            t.kind == TransactionKind.expense &&
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
            t.kind == TransactionKind.expense &&
            t.timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1))),
      )
      .fold(0.0, (sum, t) => sum + t.amount);
});

final streakProvider = Provider<int>((ref) {
  return ref
      .watch(streakStateProvider)
      .maybeWhen(data: (s) => s.currentDays, orElse: () => 0);
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
    if (t.kind != TransactionKind.expense) continue;
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
