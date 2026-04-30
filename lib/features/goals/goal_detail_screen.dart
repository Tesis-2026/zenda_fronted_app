import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _contributionsProvider =
    FutureProvider.autoDispose.family<List<GoalContribution>, String>(
  (ref, goalId) => GoalsApiService().getContributions(goalId),
);

class GoalDetailScreen extends ConsumerWidget {
  final SavingsGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contributionsAsync = ref.watch(_contributionsProvider(goal.id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsDetailTitle)),
      body: contributionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(child: Text(l10n.goalsErrorLoad)),
        data: (contributions) => _Body(
          goal: goal,
          contributions: contributions,
          onComplete: () => _completeGoal(context, ref),
          onDelete: () => _deleteGoal(context, ref),
        ),
      ),
    );
  }

  Future<void> _completeGoal(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.goalsMarkCompleteConfirm),
        content: Text(l10n.goalsMarkCompleteConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.goalsMarkComplete),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await GoalsApiService().complete(goal.id);
    if (!context.mounted) return;
    _showCelebrationDialog(context, goal.name);
  }

  Future<void> _deleteGoal(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.goalsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.goalsDeleteLabel),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await GoalsApiService().delete(goal.id);
    if (!context.mounted) return;
    context.pop();
  }

  void _showCelebrationDialog(BuildContext context, String goalName) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.emoji_events_rounded,
            color: Color(0xFFF59E0B), size: 48),
        title: Text(l10n.goalsCelebrate, textAlign: TextAlign.center),
        content: Text(
          l10n.goalsCelebrateMessage(goalName),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (context.mounted) context.pop();
            },
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981)),
            child: const Text('🎉'),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final SavingsGoal goal;
  final List<GoalContribution> contributions;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _Body({
    required this.goal,
    required this.contributions,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = goal.targetAmount - goal.currentAmount;
    final pct = goal.progressPercent;
    final isComplete = pct >= 100;
    final progressColor =
        isComplete ? const Color(0xFF10B981) : const Color(0xFF818CF8);

    final projectionMsg = _buildProjection(context, contributions, remaining);
    final alertMsg = _buildAlert(context, contributions, remaining);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Goal summary card ──────────────────────────────────────
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        goal.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    if (isComplete)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF10B981), size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct / 100,
                    minHeight: 10,
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.goalsProgressLabel(
                        goal.currentAmount.toStringAsFixed(2),
                        goal.targetAmount.toStringAsFixed(2),
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: progressColor,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                if (goal.dueDate != null) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  _DueDateRow(goal: goal),
                ],
              ],
            ),
          ),
        ),

        // ── Projection / alert ─────────────────────────────────────
        if (!isComplete && alertMsg != null) ...[
          const SizedBox(height: 12),
          _AlertBanner(message: alertMsg),
        ] else if (!isComplete && projectionMsg != null) ...[
          const SizedBox(height: 12),
          _ProjectionBanner(message: projectionMsg),
        ],

        // ── Progress chart ─────────────────────────────────────────
        if (contributions.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            l10n.goalsDetailProgressChart,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _CumulativeChart(
            goal: goal,
            contributions: contributions,
          ),
        ],

        // ── Contribution history ───────────────────────────────────
        const SizedBox(height: 20),
        Text(
          l10n.goalsDetailContributionHistory,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        if (contributions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text(
                l10n.goalsDetailNoContributions,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
            ),
          )
        else
          ...contributions.reversed.map(
            (c) => _ContributionTile(contribution: c),
          ),

        // ── Action buttons ─────────────────────────────────────────
        const SizedBox(height: 24),
        if (!isComplete) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check, size: 18),
              label: Text(l10n.goalsDetailMarkComplete),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                size: 18, color: Theme.of(context).colorScheme.error),
            label: Text(
              l10n.goalsDetailDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String? _buildProjection(
    BuildContext context,
    List<GoalContribution> contributions,
    double remaining,
  ) {
    if (contributions.isEmpty || remaining <= 0) return null;
    final rate = _dailyRate(contributions);
    if (rate <= 0) return null;

    final daysNeeded = (remaining / rate).ceil();
    final projectedDate = DateTime.now().add(Duration(days: daysNeeded));
    final formatted =
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(projectedDate);
    return context.l10n.goalsDetailProjection(formatted);
  }

  String? _buildAlert(
    BuildContext context,
    List<GoalContribution> contributions,
    double remaining,
  ) {
    final dueDateStr = goal.dueDate;
    if (dueDateStr == null) return null;
    if (contributions.isEmpty || remaining <= 0) return null;

    final dueDate = DateTime.parse(dueDateStr);
    final rate = _dailyRate(contributions);
    if (rate <= 0) return null;

    final daysNeeded = (remaining / rate).ceil();
    final projectedDate = DateTime.now().add(Duration(days: daysNeeded));

    if (projectedDate.isAfter(dueDate)) {
      final formatted =
          DateFormat.yMMMd(Localizations.localeOf(context).toString())
              .format(dueDate);
      return context.l10n.goalsDetailAlert(formatted);
    }
    return null;
  }

  double _dailyRate(List<GoalContribution> contributions) {
    if (contributions.length < 2) {
      return contributions.isEmpty ? 0 : contributions.first.amount / 30;
    }
    final first = contributions.first.createdAt;
    final last = contributions.last.createdAt;
    final days = last.difference(first).inDays;
    if (days <= 0) return contributions.first.amount / 30;
    final total = contributions.fold<double>(0, (s, c) => s + c.amount);
    return total / days;
  }
}

class _DueDateRow extends StatelessWidget {
  final SavingsGoal goal;
  const _DueDateRow({required this.goal});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final due = DateTime.tryParse(goal.dueDate!);
    if (due == null) return const SizedBox.shrink();

    final daysLeft = due.difference(DateTime.now()).inDays;
    final isOverdue = daysLeft < 0;
    final isComplete = goal.progressPercent >= 100;
    final dueLabelColor = isOverdue && !isComplete
        ? const Color(0xFFFB7185)
        : Theme.of(context).colorScheme.outline;

    final formattedDate =
        DateFormat.yMMMd(Localizations.localeOf(context).toString())
            .format(due);

    final daysText = daysLeft < 0
        ? l10n.goalsOverdue
        : daysLeft == 0
            ? l10n.goalsDaysLeft(1)
            : l10n.goalsDaysLeft(daysLeft);

    return Row(
      children: [
        Expanded(
          child: _InfoChip(
            icon: Icons.calendar_today_outlined,
            label: l10n.goalsDetailDueDate,
            value: formattedDate,
            valueColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _InfoChip(
            icon: isOverdue && !isComplete
                ? Icons.warning_amber_rounded
                : Icons.schedule_rounded,
            label: l10n.goalsDetailDaysLeft,
            value: daysText,
            valueColor: dueLabelColor,
            iconColor: dueLabelColor,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;
  final Color? iconColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? Theme.of(context).colorScheme.outline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  const _AlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFB7185).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFB7185).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFFB7185), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFFFB7185),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectionBanner extends StatelessWidget {
  final String message;
  const _ProjectionBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF818CF8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.trending_up_rounded,
              color: Color(0xFF818CF8), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF818CF8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CumulativeChart extends StatelessWidget {
  final SavingsGoal goal;
  final List<GoalContribution> contributions;

  const _CumulativeChart({
    required this.goal,
    required this.contributions,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final spots = _buildSpots();
    final maxY = goal.targetAmount;

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          minY: 0,
          maxY: maxY,
          lineBarsData: [
            LineChartBarData(
              spots: [
                FlSpot(0, maxY),
                FlSpot(spots.last.x, maxY),
              ],
              isCurved: false,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.15),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF818CF8),
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF818CF8).withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    double cumulative = 0;
    final origin = contributions.first.createdAt;
    final spots = <FlSpot>[FlSpot(0, 0)];

    for (final c in contributions) {
      cumulative += c.amount;
      final x = c.createdAt.difference(origin).inHours.toDouble();
      spots.add(FlSpot(x, cumulative.clamp(0, goal.targetAmount)));
    }
    return spots;
  }
}

class _ContributionTile extends StatelessWidget {
  final GoalContribution contribution;

  const _ContributionTile({required this.contribution});

  @override
  Widget build(BuildContext context) {
    final formatted = DateFormat.yMMMd(
      Localizations.localeOf(context).toString(),
    ).format(contribution.createdAt);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Color(0xFF818CF8),
        radius: 18,
        child: Icon(Icons.add, color: Colors.white, size: 18),
      ),
      title: Text(
        'S/ ${contribution.amount.toStringAsFixed(2)}',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        formatted,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
