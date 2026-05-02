import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../l10n/l10n_extension.dart';

final _contributionsProvider =
    FutureProvider.autoDispose.family<List<GoalContribution>, String>(
  (ref, goalId) => GoalsApiService().getContributions(goalId),
);

class GoalDetailScreen extends ConsumerStatefulWidget {
  final SavingsGoal goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  ConsumerState<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends ConsumerState<GoalDetailScreen> {
  late SavingsGoal _goal;

  @override
  void initState() {
    super.initState();
    _goal = widget.goal;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contributionsAsync = ref.watch(_contributionsProvider(_goal.id));

    return Scaffold(
      body: contributionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.goalsErrorLoad)),
        data: (contributions) => Column(
          children: [
            _GreenHeader(goal: _goal),
            Expanded(
              child: _Body(
                goal: _goal,
                contributions: contributions,
                onContribute: () => _showContributeDialog(context),
                onDelete: () => _deleteGoal(context),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 3),
    );
  }

  Future<void> _showContributeDialog(BuildContext context) async {
    final l10n = context.l10n;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.goalsContributeTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.goalsContributeLabel,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final amount = double.tryParse(controller.text.trim());
    if (amount == null || amount <= 0) return;

    final updated = await GoalsApiService().contribute(_goal.id, amount: amount);
    if (!context.mounted) return;
    setState(() => _goal = updated);
    ref.invalidate(_contributionsProvider(_goal.id));
  }

  Future<void> _deleteGoal(BuildContext context) async {
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
    await GoalsApiService().delete(_goal.id);
    if (!context.mounted) return;
    context.pop();
  }
}

class _GreenHeader extends StatelessWidget {
  final SavingsGoal goal;
  const _GreenHeader({required this.goal});

  IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('trip') ||
        lower.contains('travel') ||
        lower.contains('vacation') ||
        lower.contains('flight')) {
      return Icons.flight;
    }
    if (lower.contains('laptop') ||
        lower.contains('computer') ||
        lower.contains('tech')) {
      return Icons.laptop_outlined;
    }
    if (lower.contains('emergency') ||
        lower.contains('safety') ||
        lower.contains('shield')) {
      return Icons.security_outlined;
    }
    if (lower.contains('car') || lower.contains('auto')) {
      return Icons.directions_car_outlined;
    }
    if (lower.contains('home') || lower.contains('house')) {
      return Icons.home_outlined;
    }
    if (lower.contains('education') ||
        lower.contains('study') ||
        lower.contains('school')) {
      return Icons.school_outlined;
    }
    return Icons.savings_outlined;
  }

  String? _dueDateMonthYear(String? dueDateStr) {
    if (dueDateStr == null) return null;
    final due = DateTime.tryParse(dueDateStr);
    if (due == null) return null;
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[due.month - 1]} ${due.year}';
  }

  @override
  Widget build(BuildContext context) {
    final monthYear = _dueDateMonthYear(goal.dueDate);
    final dueLabel = monthYear != null ? context.l10n.goalsDueDate(monthYear) : null;

    return Container(
      color: const Color(0xFF34D399),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
            Icon(_iconFor(goal.name), size: 56, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              goal.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (dueLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                dueLabel,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final SavingsGoal goal;
  final List<GoalContribution> contributions;
  final VoidCallback onContribute;
  final VoidCallback onDelete;

  const _Body({
    required this.goal,
    required this.contributions,
    required this.onContribute,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = goal.targetAmount - goal.currentAmount;
    final pct = goal.progressPercent.clamp(0.0, 100.0);
    final isComplete = pct >= 100;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      children: [
        // Stats row: S/ X | Y% | S/ Z
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${goal.currentAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Spacer(),
            Text(
              '${pct.toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF34D399),
                  ),
            ),
            const Spacer(),
            Text(
              'S/ ${goal.targetAmount.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: pct / 100,
            minHeight: 8,
            backgroundColor: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.08),
            valueColor:
                const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
          ),
        ),
        const SizedBox(height: 8),
        if (!isComplete && remaining > 0)
          Text(
            l10n.goalsDetailLeftToReach(remaining.toStringAsFixed(0)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        const SizedBox(height: 28),
        // Contributions header + add button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.goalsDetailContributionHistory,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!isComplete)
              TextButton(
                onPressed: onContribute,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.goalsDetailAddContrib,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (contributions.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              l10n.goalsDetailNoContributions,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          )
        else
          ...contributions.reversed.map(
            (c) => _ContributionTile(contribution: c),
          ),
        const SizedBox(height: 32),
        // Delete button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline,
                size: 18, color: Theme.of(context).colorScheme.error),
            label: Text(
              l10n.goalsDetailDelete,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .error
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
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

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.goalManualContribution,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  formatted,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '+ S/ ${contribution.amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF34D399),
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
