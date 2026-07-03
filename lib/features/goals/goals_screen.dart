import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/savings_goal.dart';
import '../../core/services/goals_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_date_field.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/field_label.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';

final goalsServiceProvider = Provider<GoalsApiService>((ref) {
  return GoalsApiService();
});

final goalsListProvider = FutureProvider.autoDispose<List<SavingsGoal>>((ref) {
  return ref.read(goalsServiceProvider).getAll();
});

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key, this.embedded = false});

  /// When true, returns just the content (no Scaffold/AppBar/bottom nav) so it
  /// can be hosted inside the Management screen's tab stack.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goalsAsync = ref.watch(goalsListProvider);

    final content = goalsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(l10n.goalsErrorLoad),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(goalsListProvider),
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
              ...active.map(
                (goal) => _GoalCard(
                  goal: goal,
                  onTap: () => context.push('/goals/${goal.id}', extra: goal),
                  onEdit: () => _showEditSheet(context, ref, goal),
                  onDelete: () => _deleteGoal(context, ref, goal),
                ),
              ),
            ],
            if (completed.isNotEmpty) ...[
              const SizedBox(height: 8),
              _SectionHeader(title: l10n.goalsCompletedSection),
              ...completed.map(
                (goal) => _GoalCard(
                  goal: goal,
                  onTap: () => context.push('/goals/${goal.id}', extra: goal),
                  onEdit: () => _showEditSheet(context, ref, goal),
                  onDelete: () => _deleteGoal(context, ref, goal),
                ),
              ),
            ],
          ],
        );
      },
    );

    final newButton = GreenPillButton(
      label: l10n.goalsNewButton,
      height: 36,
      onTap: () => _showCreateSheet(context, ref),
    );

    if (embedded) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(children: [const Spacer(), newButton]),
          ),
          Expanded(child: content),
        ],
      );
    }

    return Scaffold(
      body: content,
      appBar: AppBar(
        title: Text(l10n.goalsTitle),
        actions: [
          Padding(padding: const EdgeInsets.only(right: 0), child: newButton),
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
    final l10n = context.l10n;
    final key = GlobalKey<_CreateGoalBodyState>();
    await showAppFormSheet(
      context,
      title: l10n.goalsAddTitle,
      primaryLabel: l10n.goalsCreateButton,
      body: _CreateGoalBody(key: key),
      onSubmit: () async {
        final st = key.currentState;
        if (st == null) return false;
        final name = st.nameCtrl.text.trim();
        final target = double.tryParse(st.targetCtrl.text.trim());
        if (name.isEmpty || target == null || target <= 0) return false;
        await ref
            .read(goalsServiceProvider)
            .create(
              name: name,
              targetAmount: target,
              dueDate: st.dueDate?.toIso8601String(),
            );
        ref.invalidate(goalsListProvider);
        return true;
      },
    );
  }

  Future<void> _showEditSheet(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final l10n = context.l10n;
    final key = GlobalKey<_EditGoalBodyState>();
    await showAppFormSheet(
      context,
      title: l10n.goalsEditTitle,
      primaryLabel: l10n.commonSave,
      body: _EditGoalBody(key: key, goal: goal),
      onSubmit: () async {
        final st = key.currentState;
        if (st == null) return false;
        final name = st.nameCtrl.text.trim();
        final target = double.tryParse(st.targetCtrl.text.trim());
        if (name.isEmpty || target == null || target <= 0) return false;
        try {
          await ref
              .read(goalsServiceProvider)
              .update(
                goal.id,
                name: name,
                targetAmount: target,
                dueDate: st.dueDate?.toIso8601String(),
              );
          ref.invalidate(goalsListProvider);
          return true;
        } on Exception catch (_) {
          if (context.mounted) {
            showAppToast(
              context,
              l10n.commonUnknownError,
              type: ToastType.error,
            );
          }
          return false;
        }
      },
    );
  }

  Future<void> _deleteGoal(
    BuildContext context,
    WidgetRef ref,
    SavingsGoal goal,
  ) async {
    final l10n = context.l10n;
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: l10n.goalDeleteTitle,
      message: l10n.goalDeleteMessage,
    );
    if (confirmed != true) return;
    try {
      await ref.read(goalsServiceProvider).delete(goal.id);
      ref.invalidate(goalsListProvider);
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, l10n.commonUnknownError, type: ToastType.error);
      }
    }
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
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: const Color(0xFF10B981)),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  final SavingsGoal goal;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _GoalCard({
    required this.goal,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
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
    final daysRemaining = goal.daysRemaining();

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
                child: Center(child: Icon(_icon(), size: 24, color: color)),
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
                    if (daysRemaining != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_rounded,
                            size: 14,
                            color: daysRemaining <= 7
                                ? const Color(0xFFF59E0B)
                                : colors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            l10n.goalsDaysLeft(daysRemaining),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: daysRemaining <= 7
                                  ? const Color(0xFFF59E0B)
                                  : colors.textMuted,
                            ),
                          ),
                        ],
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
              const SizedBox(width: 8),
              // Standard edit + delete affordance (matches budgets / categories).
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconActionButton(
                    icon: Icons.edit_outlined,
                    backgroundColor: AppColors.fillLight,
                    iconColor: AppColors.textSubtle,
                    onTap: onEdit,
                  ),
                  const SizedBox(height: 6),
                  IconActionButton(
                    icon: Icons.delete_outline,
                    backgroundColor: const Color(0xFFFEE2E2),
                    iconColor: const Color(0xFFEF4444),
                    onTap: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create Goal bottom sheet ──────────────────────────────────────────────────

class _CreateGoalBody extends StatefulWidget {
  const _CreateGoalBody({super.key});

  @override
  State<_CreateGoalBody> createState() => _CreateGoalBodyState();
}

class _CreateGoalBodyState extends State<_CreateGoalBody> {
  final nameCtrl = TextEditingController();
  final targetCtrl = TextEditingController();
  DateTime? dueDate;

  @override
  void dispose() {
    nameCtrl.dispose();
    targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l10n.goalsNameLabel),
        const SizedBox(height: 8),
        AppTextField(
          controller: nameCtrl,
          hintText: l10n.goalsNameHint,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.goalsTargetLabel),
        const SizedBox(height: 8),
        AmountInputField(controller: targetCtrl),
        const SizedBox(height: 16),
        FieldLabel(l10n.goalsDueDateLabel),
        const SizedBox(height: 8),
        AppDateField(
          value: dueDate,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate:
                  dueDate ?? DateTime.now().add(const Duration(days: 30)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 3650)),
            );
            if (picked != null) setState(() => dueDate = picked);
          },
        ),
      ],
    );
  }
}

// ── Edit Goal bottom sheet ────────────────────────────────────────────────────

class _EditGoalBody extends StatefulWidget {
  const _EditGoalBody({super.key, required this.goal});

  final SavingsGoal goal;

  @override
  State<_EditGoalBody> createState() => _EditGoalBodyState();
}

class _EditGoalBodyState extends State<_EditGoalBody> {
  late final TextEditingController nameCtrl;
  late final TextEditingController targetCtrl;
  DateTime? dueDate;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.goal.name);
    targetCtrl = TextEditingController(
      text: widget.goal.targetAmount.toStringAsFixed(2),
    );
    dueDate = AppDateFormatter.tryParse(widget.goal.dueDate);
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(l10n.goalsNameLabel),
        const SizedBox(height: 8),
        AppTextField(
          controller: nameCtrl,
          hintText: l10n.goalsNameHint,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.goalsTargetLabel),
        const SizedBox(height: 8),
        AmountInputField(controller: targetCtrl),
        const SizedBox(height: 16),
        FieldLabel(l10n.goalsDueDateLabel),
        const SizedBox(height: 8),
        AppDateField(
          value: dueDate,
          onTap: () async {
            final now = DateTime.now();
            final initial = dueDate ?? now.add(const Duration(days: 30));
            // Allow a past existing due date so the picker doesn't assert.
            final first = initial.isBefore(now) ? initial : now;
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: first,
              lastDate: now.add(const Duration(days: 3650)),
            );
            if (picked != null) setState(() => dueDate = picked);
          },
        ),
      ],
    );
  }
}
