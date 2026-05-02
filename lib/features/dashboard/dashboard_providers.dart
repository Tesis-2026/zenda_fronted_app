import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/models/breakdown_503020.dart';
import '../../core/models/summary_models.dart';
import '../../core/services/insights_api_service.dart';
import '../../core/services/recommendations_api_service.dart';
import '../../core/services/streak_repository.dart';
import '../../core/services/transaction_api_service.dart';
import '../../providers/repositories_providers.dart';
import '../../l10n/app_localizations.dart';

// ─── ISO week helper ───────────────────────────────────────────────────────

int _isoWeekNumber(DateTime date) {
  // ISO 8601: week starts on Monday; week 1 contains the first Thursday.
  final ordinal = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
  final jan1Weekday = DateTime(date.year, 1, 1).weekday; // Mon=1, Sun=7
  // Shift so Monday-based numbering starts at 0.
  final weekday = date.weekday; // Mon=1 … Sun=7
  // ISO week = floor((ordinal + jan1Weekday - 2) / 7) + 1
  final week = ((ordinal + jan1Weekday - 2) ~/ 7) + 1;
  // Edge cases: week 0 means last week of previous year; week 53 may not exist.
  if (week < 1) {
    return _isoWeekNumber(DateTime(date.year - 1, 12, 28));
  }
  if (week > 52) {
    final dec28 = DateTime(date.year, 12, 28);
    if (dec28.weekday < weekday) return 1;
  }
  return week;
}

// ─── API-backed summary providers ─────────────────────────────────────────

final _insightsService = InsightsApiService();

final daySummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  final date =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  return _insightsService.getDaySummary(date: date);
});

final weekSummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  return _insightsService.getWeekSummary(
    year: now.year,
    week: _isoWeekNumber(now),
  );
});

final monthSummaryProvider = FutureProvider.autoDispose<PeriodSummary>((ref) {
  final now = DateTime.now();
  return _insightsService.getMonthSummary(year: now.year, month: now.month);
});

// ─── Existing providers ────────────────────────────────────────────────────

final accountsProvider = FutureProvider<List<Account>>((ref) async {
  return ref.watch(accountsRepositoryProvider).getAccounts();
});

final transactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  return ref.watch(transactionsRepositoryProvider).getTransactions();
});

final streakStateProvider = FutureProvider<StreakState>((ref) async {
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
    final category = categoryFromApiName(item.name) ?? TransactionCategory.otros;
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
  final recs = ref.watch(recommendationsProvider).maybeWhen(
        data: (list) => list,
        orElse: () => const <Recommendation>[],
      );

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
