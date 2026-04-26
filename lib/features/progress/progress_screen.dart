import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/progress_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _progressServiceProvider = Provider<ProgressApiService>(
  (_) => ProgressApiService(),
);

final _progressProvider =
    FutureProvider.autoDispose<FinancialProgress>((ref) {
  return ref.read(_progressServiceProvider).getProgress();
});

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final progressAsync = ref.watch(_progressProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.progressTitle)),
      body: progressAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.progressErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_progressProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (progress) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(_progressProvider),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _MonthCard(
                title: l10n.progressCurrentMonth,
                data: progress.currentMonth,
                isPrimary: true,
              ),
              const SizedBox(height: 16),
              _MonthCard(
                title: l10n.progressPreviousMonth,
                data: progress.previousMonth,
                isPrimary: false,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.progressChangesTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _ChangeRow(
                label: l10n.progressExpensesChange,
                value: progress.expensesChangePercent,
                lowerIsBetter: true,
              ),
              _ChangeRow(
                label: l10n.progressSavingsChange,
                value: progress.savingsChangePercent,
                lowerIsBetter: false,
              ),
              _ChangeRow(
                label: l10n.progressBalanceChange,
                value: progress.balanceChangePercent,
                lowerIsBetter: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthCard extends StatelessWidget {
  const _MonthCard({
    required this.title,
    required this.data,
    required this.isPrimary,
  });

  final String title;
  final MonthFinancials data;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      color: isPrimary ? colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: isPrimary ? colorScheme.onPrimaryContainer : null,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            _StatRow(
              label: context.l10n.reportsIncome,
              value: data.income,
              color: const Color(0xFF43A047),
              isPrimary: isPrimary,
            ),
            _StatRow(
              label: context.l10n.reportsExpense,
              value: data.expenses,
              color: const Color(0xFFE53935),
              isPrimary: isPrimary,
            ),
            const Divider(),
            _StatRow(
              label: context.l10n.reportsBalance,
              value: data.balance,
              color: data.balance >= 0
                  ? const Color(0xFF43A047)
                  : const Color(0xFFE53935),
              isPrimary: isPrimary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    required this.color,
    required this.isPrimary,
  });

  final String label;
  final double value;
  final Color color;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isPrimary ? colorScheme.onPrimaryContainer : null,
                ),
          ),
          Text(
            'S/ ${value.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isPrimary ? colorScheme.onPrimaryContainer : color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChangeRow extends StatelessWidget {
  const _ChangeRow({
    required this.label,
    required this.value,
    required this.lowerIsBetter,
  });

  final String label;
  final double? value;
  final bool lowerIsBetter;

  @override
  Widget build(BuildContext context) {
    if (value == null) {
      return ListTile(
        title: Text(label),
        trailing: Text(context.l10n.progressNoData),
        dense: true,
      );
    }

    final isPositive = value! > 0;
    final isGood = lowerIsBetter ? !isPositive : isPositive;
    final color =
        isGood ? const Color(0xFF43A047) : const Color(0xFFE53935);

    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            size: 16,
            color: color,
          ),
          Text(
            '${value!.abs().toStringAsFixed(1)}%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
