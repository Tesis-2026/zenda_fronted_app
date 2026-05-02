import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _goalsServiceProvider = Provider<GoalsApiService>((ref) {
  return GoalsApiService();
});

final _goalsProvider = FutureProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.read(_goalsServiceProvider).getAll();
});

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goalsAsync = ref.watch(_goalsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.goalsTitle)),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.goalsErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_goalsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (goals) {
          final active = goals.where((g) => g.progressPercent < 100).toList();
          final completed = goals.where((g) => g.progressPercent >= 100).toList();

          if (goals.isEmpty) {
            return _EmptyState(
              title: l10n.goalsEmptyTitle,
              subtitle: l10n.goalsEmptySubtitle,
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (active.isNotEmpty) ...[
                _SectionHeader(title: l10n.goalsActiveSection),
                ...active.map((goal) => _GoalCard(
                      goal: goal,
                      onTap: () => context.go(
                        '/goals/${goal.id}',
                        extra: goal,
                      ),
                      onContribute: () =>
                          _showContributeDialog(context, ref, goal),
                      onComplete: () => _completeGoal(context, ref, goal),
                      onDelete: () => _deleteGoal(context, ref, goal.id),
                    )),
              ],
              if (completed.isNotEmpty) ...[
                const SizedBox(height: 8),
                _SectionHeader(title: l10n.goalsCompletedSection),
                ...completed.map((goal) => _GoalCard(
                      goal: goal,
                      onTap: () => context.go(
                        '/goals/${goal.id}',
                        extra: goal,
                      ),
                      onContribute: null,
                      onComplete: null,
                      onDelete: () => _deleteGoal(context, ref, goal.id),
                    )),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    DateTime? dueDate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.goalsAddTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: l10n.goalsNameLabel,
                  hintText: l10n.goalsNameHint,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: targetController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: l10n.goalsTargetLabel,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: dueDate ??
                        DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now(),
                    lastDate:
                        DateTime.now().add(const Duration(days: 3650)),
                  );
                  if (picked != null) setDialogState(() => dueDate = picked);
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.goalsDueDateLabel,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    suffixIcon:
                        const Icon(Icons.calendar_today_outlined, size: 18),
                  ),
                  child: Text(
                    dueDate != null
                        ? '${dueDate!.day.toString().padLeft(2, '0')}/${dueDate!.month.toString().padLeft(2, '0')}/${dueDate!.year}'
                        : '',
                    style: Theme.of(ctx).textTheme.bodyMedium,
                  ),
                ),
              ),
            ],
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
      ),
    );

    if (confirmed != true || !context.mounted) return;
    final name = nameController.text.trim();
    final target = double.tryParse(targetController.text.trim());
    if (name.isEmpty || target == null || target <= 0) return;

    await ref.read(_goalsServiceProvider).create(
          name: name,
          targetAmount: target,
          dueDate: dueDate?.toIso8601String(),
        );
    ref.invalidate(_goalsProvider);
  }

  Future<void> _showContributeDialog(
      BuildContext context, WidgetRef ref, SavingsGoal goal) async {
    final l10n = context.l10n;
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.goalsContributeTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: l10n.goalsContributeLabel,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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

    await ref.read(_goalsServiceProvider).contribute(goal.id, amount: amount);
    ref.invalidate(_goalsProvider);
  }

  Future<void> _completeGoal(
      BuildContext context, WidgetRef ref, SavingsGoal goal) async {
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

    await ref.read(_goalsServiceProvider).complete(goal.id);
    ref.invalidate(_goalsProvider);

    if (!context.mounted) return;
    _showCelebrationDialog(context, goal.name);
  }

  void _showCelebrationDialog(BuildContext context, String goalName) {
    showDialog(
      context: context,
      builder: (ctx) => _CelebrationDialog(goalName: goalName),
    );
  }

  Future<void> _deleteGoal(
      BuildContext context, WidgetRef ref, String id) async {
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
    await ref.read(_goalsServiceProvider).delete(id);
    ref.invalidate(_goalsProvider);
  }
}

class _CelebrationDialog extends StatefulWidget {
  final String goalName;
  const _CelebrationDialog({required this.goalName});

  @override
  State<_CelebrationDialog> createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      icon: ScaleTransition(
        scale: _scale,
        child: const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFF59E0B),
          size: 56,
        ),
      ),
      title: Text(l10n.goalsCelebrate, textAlign: TextAlign.center),
      content: Text(
        l10n.goalsCelebrateMessage(widget.goalName),
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.savings_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletedOnLabel extends StatelessWidget {
  final String updatedAt;
  const _CompletedOnLabel({required this.updatedAt});

  @override
  Widget build(BuildContext context) {
    final parsed = DateTime.tryParse(updatedAt)?.toLocal();
    if (parsed == null) return const SizedBox.shrink();
    final formatted =
        '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
    return Row(
      children: [
        Icon(
          Icons.check_circle_outline_rounded,
          size: 13,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 4),
        Text(
          context.l10n.goalCompletedOn(formatted),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF10B981),
              ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback? onContribute;
  final VoidCallback? onComplete;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onContribute,
    required this.onComplete,
    required this.onDelete,
  });

  String? _dueDateLabel(BuildContext context) {
    if (goal.dueDate == null) return null;
    final due = DateTime.tryParse(goal.dueDate!);
    if (due == null) return null;
    final daysLeft = due.difference(DateTime.now()).inDays;
    if (daysLeft < 0) return context.l10n.goalsOverdue;
    if (daysLeft == 0) return context.l10n.goalsDaysLeft(1);
    return context.l10n.goalsDaysLeft(daysLeft);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = goal.progressPercent;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = pct >= 100;
    final progressColor = isComplete
        ? const Color(0xFF10B981)
        : const Color(0xFF818CF8);
    final dueDateLabel = _dueDateLabel(context);
    final isOverdue = goal.dueDate != null &&
        DateTime.tryParse(goal.dueDate!)?.isBefore(DateTime.now()) == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (isComplete) ...[
                          const SizedBox(height: 2),
                          _CompletedOnLabel(updatedAt: goal.updatedAt),
                        ] else if (dueDateLabel != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                isOverdue && !isComplete
                                    ? Icons.warning_amber_rounded
                                    : Icons.schedule_rounded,
                                size: 13,
                                color: isOverdue && !isComplete
                                    ? const Color(0xFFFB7185)
                                    : Theme.of(context).colorScheme.outline,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dueDateLabel,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: isOverdue && !isComplete
                                          ? const Color(0xFFFB7185)
                                          : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isComplete)
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 20),
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 8,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 6),
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
              if (!isComplete && onContribute != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onContribute,
                        icon: const Icon(Icons.add, size: 18),
                        label: Text(l10n.goalsContributeTitle),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check, size: 18),
                        label: Text(l10n.goalsMarkComplete),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
