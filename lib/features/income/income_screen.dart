import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/category_utils.dart';
import '../../core/widgets/category_selector.dart';
import '../../l10n/l10n_extension.dart';
import '../dashboard/dashboard_providers.dart';

/// Income is a first-class concept: it is tracked on its own and never inflates
/// a budget (see docs/income-as-first-class-concept.md). This screen is the fixed
/// "Ingresos" place — the month total plus every income entry.
class _MonthlyIncome {
  final double total;
  final List<TransactionModel> entries;
  const _MonthlyIncome({required this.total, required this.entries});
}

final _monthlyIncomeProvider =
    FutureProvider.autoDispose<_MonthlyIncome>((ref) async {
  final txs = await ref.watch(transactionsProvider.future);
  final now = DateTime.now();
  final entries =
      txs
          .where(
            (t) =>
                t.kind == TransactionKind.income &&
                t.timestamp.year == now.year &&
                t.timestamp.month == now.month,
          )
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  final total = entries.fold<double>(0, (sum, t) => sum + t.amount);
  return _MonthlyIncome(total: total, entries: entries);
});

class IncomeScreen extends ConsumerWidget {
  const IncomeScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = context.colors;
    final incomeAsync = ref.watch(_monthlyIncomeProvider);

    final body = RefreshIndicator(
      onRefresh: () async => ref.invalidate(_monthlyIncomeProvider),
      child: incomeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => ListView(
          children: [
            const SizedBox(height: 80),
            Center(child: Text(l10n.incomeLoadError)),
          ],
        ),
        data: (income) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              _IncomeTotalCard(total: income.total),
              const SizedBox(height: 20),
              Text(
                l10n.incomeEntriesTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              if (income.entries.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l10n.incomeEmptyMonth,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colors.textMuted),
                  ),
                )
              else
                for (final t in income.entries) _IncomeEntryTile(tx: t),
            ],
          );
        },
      ),
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: Text(l10n.incomeEntriesTitle)),
      body: SafeArea(child: body),
    );
  }
}

class _IncomeTotalCard extends StatelessWidget {
  const _IncomeTotalCard({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF059669),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.reportsTotalIncome,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'S/ ${total.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeEntryTile extends StatelessWidget {
  const _IncomeEntryTile({required this.tx});

  final TransactionModel tx;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = CategorySelector.labelFor(context, tx.category);
    final date = DateFormat('d MMM', 'es').format(tx.timestamp);
    final title = (tx.note != null && tx.note!.isNotEmpty) ? tx.note! : label;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF059669).withValues(alpha: 0.12),
            child: Icon(
              CategoryUtils.iconForCategory(tx.category.name),
              color: const Color(0xFF059669),
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                Text(
                  '$label · $date',
                  style: TextStyle(fontSize: 12, color: colors.textMuted),
                ),
              ],
            ),
          ),
          Text(
            '+ S/ ${tx.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF059669),
            ),
          ),
        ],
      ),
    );
  }
}
