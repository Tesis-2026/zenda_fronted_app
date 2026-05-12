import 'package:flutter/material.dart';
import '../../../core/theme/zenda_theme_x.dart';
import '../../../l10n/l10n_extension.dart';

class SummaryCard extends StatelessWidget {
  final double todayExpense;
  final double weekExpense;
  final String currency;

  const SummaryCard({
    super.key,
    required this.todayExpense,
    required this.weekExpense,
    this.currency = 'S/',
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.summaryTodayLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currency ${todayExpense.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 40, color: colors.border),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.summaryWeekLabel,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currency ${weekExpense.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
