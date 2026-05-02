import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
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
                    )),
              ],
            ],
          );
        },
      ),
      appBar: AppBar(
        title: Text(l10n.goalsTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: () => _showCreateDialog(context, ref),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                l10n.goalsNewButton,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 3),
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

  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  String _dueDateLabel(BuildContext context) {
    if (goal.dueDate == null) return '';
    final due = DateTime.tryParse(goal.dueDate!);
    if (due == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return context.l10n.goalsDueDate('${months[due.month - 1]} ${due.year}');
  }

  Color _progressColor(double pct) {
    if (pct >= 100) return const Color(0xFF10B981);
    // Assign a color based on the goal name hash for visual variety
    final colors = [
      const Color(0xFF34D399),
      const Color(0xFFF59E0B),
      const Color(0xFF818CF8),
      const Color(0xFFEF4444),
      const Color(0xFF60A5FA),
    ];
    return colors[goal.name.length % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = goal.progressPercent.clamp(0.0, 100.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = pct >= 100;
    final color = _progressColor(pct);
    final dueDateStr = _dueDateLabel(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        if (dueDateStr.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            dueDateStr,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline,
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${pct.toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: pct / 100,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.08),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'S/ ${goal.currentAmount.toStringAsFixed(0)} ${l10n.txSaved.toLowerCase()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                  Text(
                    'S/ ${goal.targetAmount.toStringAsFixed(0)} ${context.l10n.goalTargetSuffix}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ),
              if (isComplete) ...[
                const SizedBox(height: 6),
                _CompletedOnLabel(updatedAt: goal.updatedAt),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
