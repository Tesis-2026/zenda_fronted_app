import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';

final goalsServiceProvider = Provider<GoalsApiService>((ref) {
  return GoalsApiService();
});

final _goalsProvider = FutureProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.read(goalsServiceProvider).getAll();
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
            padding: const EdgeInsets.only(right: 0),
            child: TextButton(
              onPressed: () => _showCreateSheet(context, ref),
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
          const Padding(
            padding: EdgeInsets.only(right: 12),
            child: UserMenuButton(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 3),
    );
  }

  Future<void> _showCreateSheet(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateGoalSheet(
        onSave: (name, target, dueDate) async {
          await ref.read(goalsServiceProvider).create(
                name: name,
                targetAmount: target,
                dueDate: dueDate?.toIso8601String(),
              );
          ref.invalidate(_goalsProvider);
        },
      ),
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

  const _GoalCard({
    required this.goal,
    required this.onTap,
  });

  static const _emojis = ['🎯', '✈️', '🎓', '🏠', '💻', '🎸', '📱', '🏋️', '🌎', '💰'];
  static const _bgColors = [
    Color(0xFFD1FAE5),
    Color(0xFFFEF3C7),
    Color(0xFFEDE9FE),
    Color(0xFFDCFCE7),
    Color(0xFFDBEAFE),
  ];
  static const _progressColors = [
    Color(0xFF34D399),
    Color(0xFFF59E0B),
    Color(0xFF818CF8),
    Color(0xFF10B981),
    Color(0xFF60A5FA),
  ];

  String _emoji() => _emojis[goal.name.codeUnitAt(0) % _emojis.length];
  Color _bgColor() => _bgColors[goal.name.length % _bgColors.length];
  Color _progressColor(double pct) {
    if (pct >= 100) return const Color(0xFF10B981);
    return _progressColors[goal.name.length % _progressColors.length];
  }

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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = goal.progressPercent.clamp(0.0, 100.0);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isComplete = pct >= 100;
    final color = _progressColor(pct);
    final dueDateStr = _dueDateLabel(context);
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFF3F4F6),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : _bgColor(),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(_emoji(), style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goal.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${pct.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    if (dueDateStr.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        dueDateStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pct / 100,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : const Color(0xFFF3F4F6),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'S/ ${goal.currentAmount.toStringAsFixed(0)} ${l10n.txSaved.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          'S/ ${goal.targetAmount.toStringAsFixed(0)} ${l10n.goalTargetSuffix}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
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
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create Goal bottom sheet ──────────────────────────────────────────────────

class _CreateGoalSheet extends StatefulWidget {
  final Future<void> Function(String name, double target, DateTime? dueDate)
      onSave;

  const _CreateGoalSheet({required this.onSave});

  @override
  State<_CreateGoalSheet> createState() => _CreateGoalSheetState();
}

class _CreateGoalSheetState extends State<_CreateGoalSheet> {
  final _nameCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  DateTime? _dueDate;
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  bool get _valid {
    final target = double.tryParse(_targetCtrl.text.trim());
    return _nameCtrl.text.trim().isNotEmpty && target != null && target > 0;
  }

  Future<void> _save() async {
    if (!_valid) return;
    setState(() => _saving = true);
    try {
      await widget.onSave(
        _nameCtrl.text.trim(),
        double.parse(_targetCtrl.text.trim()),
        _dueDate,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.goalsAddTitle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l10n.goalsNameLabel,
                hintText: l10n.goalsNameHint,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetCtrl,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: l10n.goalsTargetLabel,
                prefixText: 'S/ ',
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ??
                      DateTime.now().add(const Duration(days: 30)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) setState(() => _dueDate = picked);
              },
              borderRadius: BorderRadius.circular(14),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.goalsDueDateLabel,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
                ),
                child: Text(
                  _dueDate != null
                      ? '${_dueDate!.day.toString().padLeft(2, '0')}/${_dueDate!.month.toString().padLeft(2, '0')}/${_dueDate!.year}'
                      : '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving || !_valid ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      l10n.goalsCreateButton,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
