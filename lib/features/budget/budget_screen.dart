import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/services/budget_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/category_utils.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_date_field.dart';
import '../../core/widgets/category_selector.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/field_label.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
import '../../core/widgets/month_navigator.dart';
import '../../core/widgets/month_year_picker.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';

final budgetServiceProvider = Provider<BudgetApiService>((ref) {
  return BudgetApiService();
});

typedef _BudgetFilter = ({int month, int year});

final _budgetsProvider =
    FutureProvider.autoDispose.family<List<Budget>, _BudgetFilter>(
  (ref, filter) async {
    return ref
        .read(budgetServiceProvider)
        .getAll(month: filter.month, year: filter.year);
  },
);

final _categoriesProvider =
    FutureProvider.autoDispose<List<CategoryModel>>((ref) {
  return ref.read(categoryApiServiceProvider).getAll();
});

class BudgetScreen extends ConsumerStatefulWidget {
  const BudgetScreen({super.key, this.embedded = false});

  /// When true, returns just the content (no Scaffold/AppBar) so it can be
  /// hosted inside the Management screen's tab stack.
  final bool embedded;

  @override
  ConsumerState<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends ConsumerState<BudgetScreen> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = now.month;
    _year = now.year;
  }

  _BudgetFilter get _filter => (month: _month, year: _year);

  void _prevMonth() => setState(() {
        if (_month == 1) {
          _month = 12;
          _year -= 1;
        } else {
          _month -= 1;
        }
      });

  void _nextMonth() => setState(() {
        if (_month == 12) {
          _month = 1;
          _year += 1;
        } else {
          _month += 1;
        }
      });

  String _monthLabel(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    final date = DateTime(_year, _month);
    return DateFormat('MMMM yyyy', locale).format(date);
  }

  static const _needsCategories = {
    'food', 'transportation', 'housing', 'utilities', 'health'
  };
  static const _savingsCategories = {'savings'};

  _BucketSummary _computeSummary(List<Budget> budgets) {
    double needsSpent = 0, needsLimit = 0;
    double wantsSpent = 0, wantsLimit = 0;
    double savingsSpent = 0, savingsLimit = 0;

    for (final b in budgets) {
      final cat = (b.categoryName ?? '').toLowerCase();
      if (_needsCategories.contains(cat)) {
        needsSpent += b.currentSpent;
        needsLimit += b.amountLimit;
      } else if (_savingsCategories.contains(cat)) {
        savingsSpent += b.currentSpent;
        savingsLimit += b.amountLimit;
      } else {
        wantsSpent += b.currentSpent;
        wantsLimit += b.amountLimit;
      }
    }
    return _BucketSummary(
      needsSpent: needsSpent,
      needsLimit: needsLimit,
      wantsSpent: wantsSpent,
      wantsLimit: wantsLimit,
      savingsSpent: savingsSpent,
      savingsLimit: savingsLimit,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final budgetsAsync = ref.watch(_budgetsProvider(_filter));

    final content = budgetsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(l10n.budgetErrorLoad),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(_budgetsProvider(_filter)),
                  child: Text(l10n.commonRetry),
                ),
              ],
            ),
          ),
          data: (budgets) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                child: MonthNavigator(
                  label: _monthLabel(context),
                  onPrev: _prevMonth,
                  onNext: _nextMonth,
                  trailing: widget.embedded
                      ? GreenPillButton(
                          label: l10n.catMgmtAddButton,
                          onTap: () => _showCreateSheet(context),
                        )
                      : null,
                ),
              ),
              if (budgets.isEmpty)
                Expanded(
                  child: _EmptyState(
                    title: l10n.budgetEmptyTitle,
                    subtitle: l10n.budgetEmptySubtitle,
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    children: [
                      _BucketSummaryRow(summary: _computeSummary(budgets)),
                      const SizedBox(height: 24),
                      Text(
                        l10n.budgetByCategory,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...budgets.map((b) => _BudgetCard(
                            budget: b,
                            onDelete: () => _deleteBudget(b.id),
                            onEdit: () => _showEditSheet(context, b),
                          )),
                    ],
                  ),
                ),
            ],
          ),
    );

    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(
        title: l10n.budgetTitle,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: GreenPillButton(
                label: l10n.catMgmtAddButton,
                onTap: () => _showCreateSheet(context),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(top: false, child: content),
    );
  }

  // ── Create bottom sheet ────────────────────────────────────────────────────

  Future<void> _showCreateSheet(BuildContext context) async {
    final l10n = context.l10n;
    final key = GlobalKey<_CreateBudgetBodyState>();
    await showAppFormSheet(
      context,
      title: l10n.budgetAddTitle,
      primaryLabel: l10n.commonSave,
      body: _CreateBudgetBody(
        key: key,
        initialMonth: _month,
        initialYear: _year,
        categoriesFuture: ref.read(_categoriesProvider.future),
      ),
      onSubmit: () async {
        final st = key.currentState;
        if (st == null) return false;
        final amount = double.tryParse(st.amountController.text.trim());
        if (amount == null || amount <= 0) return false;
        try {
          await ref.read(budgetServiceProvider).create(
                categoryId: st.categoryId,
                amountLimit: amount,
                month: st.month,
                year: st.year,
              );
          ref.invalidate(_budgetsProvider(_filter));
          return true;
        } on Exception catch (e) {
          if (!context.mounted) return false;
          final msg = e.toString().contains('409') ||
                  e.toString().contains('already exists')
              ? l10n.budgetDuplicate
              : l10n.commonUnknownError;
          showAppToast(context, msg, type: ToastType.error);
          return false;
        }
      },
    );
  }

  // ── Edit bottom sheet ──────────────────────────────────────────────────────

  Future<void> _showEditSheet(BuildContext context, Budget budget) async {
    final l10n = context.l10n;
    final key = GlobalKey<_EditBudgetBodyState>();
    await showAppFormSheet(
      context,
      title: l10n.budgetEditTitle,
      primaryLabel: l10n.commonSave,
      body: _EditBudgetBody(key: key, budget: budget),
      onSubmit: () async {
        final st = key.currentState;
        if (st == null) return false;
        final amount = double.tryParse(st.controller.text.trim());
        if (amount == null || amount <= 0) return false;
        await ref
            .read(budgetServiceProvider)
            .update(budget.id, amountLimit: amount);
        ref.invalidate(_budgetsProvider(_filter));
        return true;
      },
    );
  }

  // ── Delete ─────────────────────────────────────────────────────────────────

  Future<void> _deleteBudget(String id) async {
    final l10n = context.l10n;
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: l10n.budgetDeleteTitle,
      message: l10n.budgetDeleteMessage,
    );
    if (confirmed != true || !mounted) return;
    await ref.read(budgetServiceProvider).delete(id);
    ref.invalidate(_budgetsProvider(_filter));
  }
}

// ── Create Budget bottom sheet ─────────────────────────────────────────────

class _CreateBudgetBody extends StatefulWidget {
  const _CreateBudgetBody({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.categoriesFuture,
  });

  final int initialMonth;
  final int initialYear;
  final Future<List<CategoryModel>> categoriesFuture;

  @override
  State<_CreateBudgetBody> createState() => _CreateBudgetBodyState();
}

class _CreateBudgetBodyState extends State<_CreateBudgetBody> {
  final amountController = TextEditingController();
  String? categoryId;
  late int month;
  late int year;

  @override
  void initState() {
    super.initState();
    month = widget.initialMonth;
    year = widget.initialYear;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  String _periodText() {
    final text = DateFormat('MMMM yyyy', 'es').format(DateTime(year, month));
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _pickPeriod() async {
    final l10n = context.l10n;
    final result = await showMonthYearPicker(
      context,
      initialMonth: month,
      initialYear: year,
      title: 'Período',
      confirmLabel: l10n.commonOk,
    );
    if (result != null) {
      setState(() {
        month = result.month;
        year = result.year;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Categoría'),
        const SizedBox(height: 8),
        FutureBuilder<List<CategoryModel>>(
          future: widget.categoriesFuture,
          builder: (ctx, snap) {
            final categories = snap.data ?? [];
            return CategoryGrid(
              items: [
                CategoryGridItem(
                  icon: Icons.grid_view_rounded,
                  label: l10n.budgetCategoryAll,
                  selected: categoryId == null,
                  onTap: () => setState(() => categoryId = null),
                ),
                for (final c in categories)
                  CategoryGridItem(
                    icon: CategoryUtils.iconForCategory(
                      c.name,
                      iconKey: c.icon,
                      isCustom: c.isCustom,
                    ),
                    label: c.name,
                    selected: categoryId == c.id,
                    onTap: () => setState(() => categoryId = c.id),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.budgetAmountLabel),
        const SizedBox(height: 8),
        AmountInputField(controller: amountController),
        const SizedBox(height: 16),
        const FieldLabel('Período'),
        const SizedBox(height: 8),
        AppDateField(
          displayText: _periodText(),
          icon: Icons.event_rounded,
          onTap: _pickPeriod,
        ),
      ],
    );
  }
}

// ── Edit Budget bottom sheet ───────────────────────────────────────────────

class _EditBudgetBody extends StatefulWidget {
  const _EditBudgetBody({super.key, required this.budget});

  final Budget budget;

  @override
  State<_EditBudgetBody> createState() => _EditBudgetBodyState();
}

class _EditBudgetBodyState extends State<_EditBudgetBody> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(
        text: widget.budget.amountLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoryName =
        widget.budget.categoryName ?? l10n.budgetCategoryAll;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FieldLabel('Categoría'),
        const SizedBox(height: 8),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                CategoryUtils.iconForCategory(widget.budget.categoryName),
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.budgetAmountLabel),
        const SizedBox(height: 8),
        AmountInputField(controller: controller, autofocus: true),
      ],
    );
  }
}

// ── Bucket summary ─────────────────────────────────────────────────────────

class _BucketSummary {
  const _BucketSummary({
    required this.needsSpent,
    required this.needsLimit,
    required this.wantsSpent,
    required this.wantsLimit,
    required this.savingsSpent,
    required this.savingsLimit,
  });

  final double needsSpent;
  final double needsLimit;
  final double wantsSpent;
  final double wantsLimit;
  final double savingsSpent;
  final double savingsLimit;
}

class _BucketSummaryRow extends StatelessWidget {
  const _BucketSummaryRow({required this.summary});
  final _BucketSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _BucketCell(
            label: l10n.dashboardNeeds,
            spent: summary.needsSpent,
            limit: summary.needsLimit,
            color: const Color(0xFF34D399),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BucketCell(
            label: l10n.dashboardWants,
            spent: summary.wantsSpent,
            limit: summary.wantsLimit,
            color: const Color(0xFF60A5FA),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BucketCell(
            label: l10n.dashboardSavings,
            spent: summary.savingsSpent,
            limit: summary.savingsLimit,
            color: const Color(0xFFF59E0B),
          ),
        ),
      ],
    );
  }
}

class _BucketCell extends StatelessWidget {
  const _BucketCell({
    required this.label,
    required this.spent,
    required this.limit,
    required this.color,
  });

  final String label;
  final double spent;
  final double limit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'S/ ${spent.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
          if (limit > 0)
            Text(
              'de S/ ${limit.toStringAsFixed(0)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.textSubtle),
            ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
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

// ── Budget card ────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.budget,
    required this.onDelete,
    required this.onEdit,
  });

  final Budget budget;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  Color _progressColor(double pct) {
    if (pct > 100) return const Color(0xFFEF4444);
    if (pct > 80) return const Color(0xFFF59E0B);
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = (budget.amountLimit > 0
            ? (budget.currentSpent / budget.amountLimit) * 100
            : 0)
        .clamp(0, 200)
        .toDouble();
    final color = _progressColor(pct);
    final isOver =
        budget.currentSpent > budget.amountLimit && budget.amountLimit > 0;
    final categoryName = budget.categoryName ?? l10n.budgetCategoryAll;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.fillLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  CategoryUtils.iconForCategory(budget.categoryName),
                  size: 18,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoryName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconActionButton(
                icon: Icons.edit_outlined,
                onTap: onEdit,
                backgroundColor: AppColors.fillLight,
                iconColor: AppColors.textSubtle,
              ),
              const SizedBox(width: 6),
              IconActionButton(
                icon: Icons.delete_outline,
                onTap: onDelete,
                backgroundColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppProgressBar(
            value: (pct / 100).clamp(0.0, 1.0),
            height: 6,
            color: color,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (isOver) ...[
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 16),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  'S/ ${budget.currentSpent.toStringAsFixed(0)} de S/ ${budget.amountLimit.toStringAsFixed(0)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isOver
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pct.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
