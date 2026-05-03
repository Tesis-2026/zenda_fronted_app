import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/predictions_api_service.dart';
import '../../l10n/l10n_extension.dart';

final predictionsServiceProvider = Provider<PredictionsApiService>(
  (_) => PredictionsApiService(),
);

final _expensePredictionProvider =
    FutureProvider.autoDispose<PredictionResult>((ref) {
  return ref.read(predictionsServiceProvider).getExpensePrediction();
});

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key});

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> {
  // Month offset from current month (0 = current, -1 = previous, +1 = next)
  int _monthOffset = 0;

  String _monthLabel(BuildContext context, int offset) {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month + offset);
    final locale = Localizations.localeOf(context).toString();
    final monthName = DateFormat('MMMM', locale).format(target);
    return context.l10n.reportsMonthLabel(monthName, target.year);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final expenseAsync = ref.watch(_expensePredictionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.predictionsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_expensePredictionProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Month navigator
            _MonthNavigator(
              label: _monthLabel(context, _monthOffset),
              onPrevious: () => setState(() => _monthOffset--),
              onNext: () => setState(() => _monthOffset++),
            ),
            const SizedBox(height: 16),
            expenseAsync.when(
              loading: () => const _PredictionCardSkeleton(),
              error: (e, _) => _ErrorCard(
                message: l10n.predictionsErrorLoad,
                onRetry: () => ref.invalidate(_expensePredictionProvider),
              ),
              data: (p) => p.confidenceLevel >= 0.60
                  ? _ExpenseForecastCard(result: p)
                  : _LowConfidenceCard(message: l10n.predictionsLowConfidence),
            ),
            const SizedBox(height: 16),
            _DisclaimerCard(text: l10n.predictionsDisclaimer),
          ],
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  const _MonthNavigator({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left, size: 22),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF1F2937),
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right, size: 22),
          style: IconButton.styleFrom(
            foregroundColor: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}

class _ExpenseForecastCard extends StatelessWidget {
  const _ExpenseForecastCard({required this.result});
  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confidencePct = (result.confidenceLevel * 100).toStringAsFixed(0);

    // Projected balance is total - predicted expenses (or the predicted amount as balance proxy)
    final projectedBalance = result.projectedBalance ?? result.predictedAmount;

    // Top categories from result (may be null for older API responses)
    final categories = result.topCategories ?? const <PredictionCategory>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Projected Balance card ──────────────────────────────────────
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.predictionsProjectedBalance,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'S/ ${projectedBalance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: const Color(0xFF1F2937),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF34D399).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$confidencePct% ${l10n.predictionsConfident}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.predictionsBasedOnMonths,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ── Expense Forecast card ────────────────────────────────────────
        Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.predictionsExpenseTitle,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      l10n.predictionsProjectedExpenses,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                    ),
                    const Spacer(),
                    Text(
                      'S/ ${result.predictedAmount.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFFEF4444),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (result.budgetUsageFraction ?? 0.9).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: const Color(0xFFFEE2E2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFFEF4444)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.arrow_upward,
                        size: 13, color: Color(0xFFEF4444)),
                    const SizedBox(width: 2),
                    Text(
                      result.vsLastMonthLabel ?? l10n.predictionsVsLastMonth,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // ── Top Expense Categories ───────────────────────────────────────
        if (categories.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.predictionsTopCategories,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: cat.color ?? const Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cat.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: const Color(0xFF1F2937)),
                            ),
                          ),
                          Text(
                            'S/ ${cat.amount.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        // ── AI Insight card ──────────────────────────────────────────────
        if (result.narrative != null && result.narrative!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.35)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zenda AI Insight',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.narrative!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF065F46),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _LowConfidenceCard extends StatelessWidget {
  const _LowConfidenceCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionCardSkeleton extends StatelessWidget {
  const _PredictionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
