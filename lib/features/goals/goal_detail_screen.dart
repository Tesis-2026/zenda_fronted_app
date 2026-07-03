import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/field_label.dart';
import '../../l10n/l10n_extension.dart';
import 'goals_screen.dart';

final _contributionsProvider = FutureProvider.autoDispose
    .family<List<GoalContribution>, String>(
      (ref, goalId) => ref.read(goalsServiceProvider).getContributions(goalId),
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

  String? _dueDateLabel(BuildContext context) {
    if (_goal.dueDate == null) return null;
    final due = DateTime.tryParse(_goal.dueDate!);
    if (due == null) return null;
    return context.l10n.goalsDueDate(DateFormat('MMM yyyy').format(due));
  }

  static const _icons = [
    Icons.flag_rounded,
    Icons.flight_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.laptop_rounded,
    Icons.music_note_rounded,
    Icons.smartphone_rounded,
    Icons.fitness_center_rounded,
    Icons.public_rounded,
    Icons.savings_rounded,
  ];
  IconData _icon() => _icons[_goal.name.codeUnitAt(0) % _icons.length];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final contributionsAsync = ref.watch(_contributionsProvider(_goal.id));
    final colors = context.colors;
    final dueLabel = _dueDateLabel(context);

    return Scaffold(
      body: contributionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.goalsErrorLoad)),
        data: (contributions) => Stack(
          children: [
            Container(color: const Color(0xFF34D399)),
            SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(child: Icon(_icon(), size: 52, color: Colors.white70)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      _goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (dueLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      dueLabel,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                        child: _Body(
                          goal: _goal,
                          contributions: contributions,
                          onContribute: () => _showContributeSheet(context),
                          onComplete: () => _completeGoal(context),
                          onDelete: () => _deleteGoal(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showContributeSheet(BuildContext context) async {
    final l10n = context.l10n;
    final ctrl = TextEditingController();
    await showAppFormSheet(
      context,
      title: l10n.goalsContributeTitle,
      subtitle: _goal.name,
      primaryLabel: l10n.goalsContributeTitle,
      body: _ContributeBody(goal: _goal, controller: ctrl),
      onSubmit: () async {
        final amount = double.tryParse(ctrl.text.trim());
        if (amount == null || amount <= 0) return false;
        final updated = await ref
            .read(goalsServiceProvider)
            .contribute(_goal.id, amount: amount);
        if (mounted) {
          setState(() => _goal = updated);
          ref.invalidate(_contributionsProvider(_goal.id));
          // Refresh the goals list / Gestión so the card percentage reflects it.
          ref.invalidate(goalsListProvider);
        }
        return true;
      },
    );
    ctrl.dispose();
  }

  Future<void> _completeGoal(BuildContext context) async {
    final l10n = context.l10n;
    try {
      final updated = await ref.read(goalsServiceProvider).complete(_goal.id);
      if (!context.mounted) return;
      setState(() => _goal = updated);
      ref.invalidate(goalsListProvider);
      showAppToast(
        context,
        l10n.goalsDetailCompleteSuccess,
        type: ToastType.success,
      );
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, l10n.commonUnknownError, type: ToastType.error);
      }
    }
  }

  Future<void> _deleteGoal(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: l10n.goalDeleteTitle,
      message: l10n.goalDeleteMessage,
    );
    if (confirmed != true || !context.mounted) return;
    await ref.read(goalsServiceProvider).delete(_goal.id);
    ref.invalidate(goalsListProvider);
    if (!context.mounted) return;
    context.pop();
  }
}

// ── Contribute form body (rendered inside AppFormSheet) ──────────────────────

class _ContributeBody extends StatelessWidget {
  final SavingsGoal goal;
  final TextEditingController controller;

  const _ContributeBody({required this.goal, required this.controller});

  void _quickPick(double value) {
    final text = value.toStringAsFixed(0);
    controller.text = text;
    controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final pct = goal.progressPercent.clamp(0.0, 100.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppProgressBar(value: pct / 100, height: 8, color: colors.primary),
        const SizedBox(height: 20),
        FieldLabel(l10n.goalsContributeLabel),
        const SizedBox(height: 8),
        AmountInputField(controller: controller, autofocus: true),
        const SizedBox(height: 12),
        Row(
          children: [50.0, 100.0, 200.0].map((v) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: OutlinedButton(
                onPressed: () => _quickPick(v),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(color: colors.primary),
                  foregroundColor: colors.primary,
                ),
                child: Text('S/ ${v.toStringAsFixed(0)}'),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  final SavingsGoal goal;
  final List<GoalContribution> contributions;
  final VoidCallback onContribute;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _Body({
    required this.goal,
    required this.contributions,
    required this.onContribute,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final remaining = goal.targetAmount - goal.currentAmount;
    final pct = goal.progressPercent.clamp(0.0, 100.0);
    final daysRemaining = goal.daysRemaining();
    // Distinguish "reached the target amount" from "officially marked complete"
    // (the latter is server state that sets completedAt + awards the badge).
    final reachedTarget =
        goal.targetAmount > 0 && goal.currentAmount >= goal.targetAmount;
    final markedComplete = goal.isCompleted;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'S/ ${goal.currentAmount.toStringAsFixed(0)}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
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
        AppProgressBar(
          value: pct / 100,
          height: 8,
          color: const Color(0xFF34D399),
        ),
        const SizedBox(height: 8),
        if (!reachedTarget && remaining > 0)
          Text(
            l10n.goalsDetailLeftToReach(remaining.toStringAsFixed(0)),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        // Reached the target but not yet marked → offer the explicit completion
        // (sets completedAt server-side and awards the "Goal Achieved" badge).
        if (daysRemaining != null) ...[
          const SizedBox(height: 12),
          _DaysRemainingPanel(daysRemaining: daysRemaining),
        ],
        if (markedComplete) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: 18,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.goalsDetailCompletedLabel,
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ] else if (reachedTarget) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.emoji_events_rounded, size: 18),
              label: Text(l10n.goalsDetailMarkComplete),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.goalsDetailContributionHistory,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!reachedTarget)
              TextButton(
                onPressed: onContribute,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.goalsDetailAddContrib,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
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
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 18,
              color: Theme.of(context).colorScheme.error,
            ),
            label: Text(
              l10n.goalsDetailDelete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Contribution tile ─────────────────────────────────────────────────────────

class _DaysRemainingPanel extends StatelessWidget {
  const _DaysRemainingPanel({required this.daysRemaining});

  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final urgent = daysRemaining <= 7;
    final accent = urgent ? const Color(0xFFF59E0B) : colors.primary;
    final background = urgent
        ? const Color(0xFFFFFBEB)
        : const Color(0xFFEFFDF5);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.event_available_rounded, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.goalsDetailDaysLeft,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.goalsDaysLeft(daysRemaining),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: accent,
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
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
            '+ S/ ${contribution.amount.toStringAsFixed(0)}',
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
