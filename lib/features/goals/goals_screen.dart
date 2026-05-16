import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_sheet_container.dart';
import '../../core/widgets/sheet_header.dart';
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
                      onTap: () => context.push(
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
                      onTap: () => context.push(
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
    final parsed = AppDateFormatter.tryParse(updatedAt);
    if (parsed == null) return const SizedBox.shrink();
    final formatted = AppDateFormatter.shortDate(parsed);
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

  IconData _icon() => _icons[goal.name.codeUnitAt(0) % _icons.length];
  Color _bgColor() => _bgColors[goal.name.length % _bgColors.length];
  Color _progressColor(double pct) {
    if (pct >= 100) return const Color(0xFF10B981);
    return _progressColors[goal.name.length % _progressColors.length];
  }

  String _dueDateLabel(BuildContext context) {
    final due = AppDateFormatter.tryParse(goal.dueDate);
    if (due == null) return '';
    return context.l10n.goalsDueDate(AppDateFormatter.monthYear(due));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = goal.progressPercent.clamp(0.0, 100.0);
    final colors = context.colors;
    final isComplete = pct >= 100;
    final color = _progressColor(pct);
    final dueDateStr = _dueDateLabel(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      hasShadow: true,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _bgColor(),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Icon(_icon(), size: 24, color: color),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
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
                          color: colors.textSubtle,
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    AppProgressBar(
                      value: pct / 100,
                      height: 8,
                      color: color,
                      backgroundColor: colors.border,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'S/ ${goal.currentAmount.toStringAsFixed(0)} ${l10n.txSaved.toLowerCase()}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
                          ),
                        ),
                        Text(
                          'S/ ${goal.targetAmount.toStringAsFixed(0)} ${l10n.goalTargetSuffix}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textMuted,
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

    return AppSheetContainer(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(title: l10n.goalsAddTitle),
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
                      ? AppDateFormatter.shortDate(_dueDate!)
                      : '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: l10n.goalsCreateButton,
              onPressed: _saving || !_valid ? null : _save,
              isLoading: _saving,
            ),
          ],
        ),
    );
  }
}
