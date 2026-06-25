import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/budget.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/models/breakdown_503020.dart';
import '../../core/models/summary_models.dart';
import '../../core/services/recommendations_api_service.dart';
import '../../core/services/streak_repository.dart';
import '../../core/services/transaction_api_service.dart';
import '../../providers/repositories_providers.dart';
import '../../providers/services_providers.dart';
import '../../l10n/app_localizations.dart';
import '../budget/budget_screen.dart' show budgetServiceProvider;

// ─── ISO week helper ───────────────────────────────────────────────────────
// Standard ISO 8601: W = floor((dayOfYear - weekday + 10) / 7)
// Matches the algorithm used in reports_screen.dart and the backend.

int _isoWeekNumber(DateTime date) {
  final dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  final woy = ((dayOfYear - date.weekday + 10) / 7).floor();
  if (woy < 1) {
    // Late Dec/early Jan boundary: belongs to last week of previous year.
    return _isoWeekNumber(DateTime(date.year - 1, 12, 28));
  }
  if (woy > 52) {
    // Check whether week 53 is valid for this year (Dec 28 is always in last week).
    final dec28 = DateTime(date.year, 12, 28);
    final dec28Woy =
        ((dec28.difference(DateTime(dec28.year, 1, 1)).inDays +
                    1 -
                    dec28.weekday +
                    10) /
                7)
            .floor();
    if (woy > dec28Woy) {
      return 1; // Beyond last valid week → week 1 of next year.
    }
  }
  return woy;
}

// ─── API-backed summary providers ─────────────────────────────────────────

final daySummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return ref.read(insightsApiServiceProvider).getDaySummary(date: date);
});

final weekSummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  return ref
      .read(insightsApiServiceProvider)
      .getWeekSummary(year: now.year, week: _isoWeekNumber(now));
});

final monthSummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  return ref
      .read(insightsApiServiceProvider)
      .getMonthSummary(year: now.year, month: now.month);
});

// ─── Existing providers ────────────────────────────────────────────────────

/// Aggregate of the user's spending limits for the current month: `total` is the
/// sum of budget limits, `spent`/`available` derive from each budget's progress.
/// Budgets are pure limits — income is tracked separately and never inflates them
/// (see docs/income-as-first-class-concept.md).
class BudgetTotals {
  final double total;
  final double spent;
  const BudgetTotals({required this.total, required this.spent});
  double get available => total - spent;
}

final budgetSummaryProvider = FutureProvider.autoDispose<BudgetTotals>((
  ref,
) async {
  final now = DateTime.now();
  final budgets = await ref
      .read(budgetServiceProvider)
      .getAll(month: now.month, year: now.year);
  var total = 0.0;
  var spent = 0.0;
  for (final b in budgets) {
    total += b.total; // pure spending limit (no income inflation)
    spent += b.currentSpent;
  }
  return BudgetTotals(total: total, spent: spent);
});

/// The user's budgets for the current month — used as the required selector when
typedef BudgetPeriod = ({int month, int year});

/// The user's budgets for a specific month/year. Transaction creation uses the
/// expense date, not the device's current date, so backdated expenses can pick
/// the right budget period.
final budgetsForPeriodProvider = FutureProvider.autoDispose
    .family<List<Budget>, BudgetPeriod>((ref, period) async {
      return ref
          .read(budgetServiceProvider)
          .getAll(month: period.month, year: period.year);
    });

/// The user's budgets for the current month.
final currentMonthBudgetsProvider = FutureProvider.autoDispose<List<Budget>>((
  ref,
) async {
  final now = DateTime.now();
  return ref.watch(
    budgetsForPeriodProvider((month: now.month, year: now.year)).future,
  );
});

final transactionsProvider = FutureProvider.autoDispose<List<TransactionModel>>(
  (ref) async {
    return ref.watch(transactionsRepositoryProvider).getTransactions();
  },
);

final accountsProvider = FutureProvider.autoDispose<List<FinancialAccount>>((
  ref,
) async {
  return ref.watch(accountApiServiceProvider).getAll();
});

typedef AccountReportPeriod = ({int month, int year});

final accountReportProvider = FutureProvider.autoDispose
    .family<AccountReport, AccountReportPeriod>((ref, period) async {
      return ref
          .watch(accountApiServiceProvider)
          .getReport(month: period.month, year: period.year);
    });

final streakStateProvider = FutureProvider.autoDispose<StreakState>((
  ref,
) async {
  return ref.watch(streakRepositoryProvider).getStreak();
});

final todayExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(daySummaryProvider)
      .maybeWhen(data: (s) => s.totalExpense, orElse: () => 0.0);
});

final weekExpenseProvider = Provider<double>((ref) {
  return ref
      .watch(weekSummaryProvider)
      .maybeWhen(data: (s) => s.totalExpense, orElse: () => 0.0);
});

final streakProvider = Provider<int>((ref) {
  return ref
      .watch(streakStateProvider)
      .maybeWhen(data: (s) => s.currentDays, orElse: () => 0);
});

final budgetBreakdownProvider = Provider<BudgetBreakdown503020>((ref) {
  final summary = ref
      .watch(monthSummaryProvider)
      .maybeWhen(data: (s) => s, orElse: () => null);

  if (summary == null) {
    return BudgetBreakdown503020(
      totalNecesidades: 0,
      totalDeseos: 0,
      totalAhorro: 0,
    );
  }

  double nec = 0;
  double des = 0;
  double aho = 0;

  for (final item in summary.topCategories) {
    final category =
        categoryFromApiName(item.name) ?? TransactionCategory.otros;
    switch (bucketForCategory(category)) {
      case Bucket503020.necesidad:
        nec += item.amount;
        break;
      case Bucket503020.deseo:
        des += item.amount;
        break;
      case Bucket503020.ahorro:
        aho += item.amount;
        break;
    }
  }

  return BudgetBreakdown503020(
    totalNecesidades: nec,
    totalDeseos: des,
    totalAhorro: aho,
  );
});

final _recommendationsServiceProvider = Provider<RecommendationsApiService>(
  (_) => RecommendationsApiService(),
);

final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) {
  return ref.read(_recommendationsServiceProvider).getAll();
});

final aiAdviceProvider = Provider.family<String, AppLocalizations>((ref, l10n) {
  final recs = ref
      .watch(recommendationsProvider)
      .maybeWhen(data: (list) => list, orElse: () => const <Recommendation>[]);

  if (recs.isNotEmpty) {
    final r = recs.first;
    return r.body.isNotEmpty ? '${r.title}\n${r.body}' : r.title;
  }

  // Local fallback when API has no recommendations yet
  final breakdown = ref.watch(budgetBreakdownProvider);
  if (breakdown.total == 0) return l10n.aiAdviceStartRecording;

  final pDes = breakdown.percentDeseos();
  final pAho = breakdown.percentAhorro();

  if (pDes > 30) {
    return l10n.aiAdviceReduceWants(pDes.toStringAsFixed(0));
  } else if (pAho < 20) {
    return l10n.aiAdviceSaveLow(pAho.toStringAsFixed(0));
  } else {
    return l10n.aiAdviceOnTrack;
  }
});
