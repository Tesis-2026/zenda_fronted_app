import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/services/budget_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/category_utils.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_sheet_container.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/field_label.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
import '../../core/widgets/month_navigator.dart';
import '../../core/widgets/sheet_header.dart';
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
  const BudgetScreen({super.key});

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

    return Scaffold(
      backgroundColor: context.colors.bg,
      body: SafeArea(
        child: budgetsAsync.when(
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
              _BudgetHeader(
                label: _monthLabel(context),
                onPrevious: _prevMonth,
                onNext: _nextMonth,
                onAdd: () => _showCreateSheet(context),
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
        ),
      ),
    );
  }

  // ── Create bottom sheet ────────────────────────────────────────────────────

  Future<void> _showCreateSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateBudgetSheet(
        initialMonth: _month,
        initialYear: _year,
        onSave: (categoryId, amount, month, year) async {
          final l10n = context.l10n;
          try {
            await ref.read(budgetServiceProvider).create(
                  categoryId: categoryId,
                  amountLimit: amount,
                  month: month,
                  year: year,
                );
            ref.invalidate(_budgetsProvider(_filter));
          } on Exception catch (e) {
            if (!context.mounted) return;
            final msg = e.toString().contains('409') ||
                    e.toString().contains('already exists')
                ? l10n.budgetDuplicate
                : l10n.commonUnknownError;
            showAppToast(context, msg, type: ToastType.error);
          }
        },
        categoriesFuture: ref.read(_categoriesProvider.future),
      ),
    );
  }

  // ── Edit bottom sheet ──────────────────────────────────────────────────────

  Future<void> _showEditSheet(BuildContext context, Budget budget) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditBudgetSheet(
        budget: budget,
        onSave: (amount) async {
          await ref
              .read(budgetServiceProvider)
              .update(budget.id, amountLimit: amount);
          ref.invalidate(_budgetsProvider(_filter));
        },
      ),
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

// ── Header ─────────────────────────────────────────────────────────────────

class _BudgetHeader extends StatelessWidget {
  const _BudgetHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onAdd,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 20, 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: Color(0xFF374151),
            ),
            onPressed: () => context.pop(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Text(
            l10n.budgetTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MonthNavigator(
              label: label,
              onPrev: onPrevious,
              onNext: onNext,
              trailing: GreenPillButton(
                label: l10n.catMgmtAddButton,
                onTap: onAdd,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Create Budget bottom sheet ─────────────────────────────────────────────

class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet({
    required this.initialMonth,
    required this.initialYear,
    required this.onSave,
    required this.categoriesFuture,
  });

  final int initialMonth;
  final int initialYear;
  final Future<void> Function(
      String? categoryId, double amount, int month, int year) onSave;
  final Future<List<CategoryModel>> categoriesFuture;

  @override
  State<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<_CreateBudgetSheet> {
  final _amountController = TextEditingController();
  String? _selectedCategoryId;
  late int _month;
  late int _year;
  bool _saving = false;

  static const _monthNames = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];

  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth;
    _year = widget.initialYear;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppSheetContainer(
      topRadius: 28,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(title: l10n.budgetAddTitle),
          const SizedBox(height: 20),
          // Category dropdown
          FieldLabel(l10n.budgetCategoryAll),
          const SizedBox(height: 8),
            FutureBuilder<List<CategoryModel>>(
              future: widget.categoriesFuture,
              builder: (ctx, snap) {
                final categories = snap.data ?? [];
                return DropdownButtonFormField<String?>(
                  // ignore: deprecated_member_use
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFFF9FAFB),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.budgetCategoryAll),
                    ),
                    ...categories.map((c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text(c.name),
                        )),
                  ],
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                );
              },
            ),
            const SizedBox(height: 16),
            FieldLabel(l10n.budgetAmountLabel),
            const SizedBox(height: 8),
            AmountInputField(
              controller: _amountController,
              label: l10n.budgetAmountLabel,
            ),
            const SizedBox(height: 16),
            // Period (month + year) row
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: _month,
                    decoration: InputDecoration(
                      labelText: l10n.budgetMonthLabel,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(_monthNames[i]),
                      ),
                    ),
                    onChanged: (v) => setState(() => _month = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    // ignore: deprecated_member_use
                    value: _year,
                    decoration: InputDecoration(
                      labelText: l10n.budgetYearLabel,
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                    items: List.generate(5, (i) {
                      final y = DateTime.now().year + i - 1;
                      return DropdownMenuItem(
                          value: y, child: Text('$y'));
                    }),
                    onChanged: (v) => setState(() => _year = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: l10n.commonSave,
              onPressed: _saving ? null : _submit,
              isLoading: _saving,
            ),
          ],
        ),
      );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await widget.onSave(_selectedCategoryId, amount, _month, _year);
    if (mounted) context.pop();
  }
}

// ── Edit Budget bottom sheet ───────────────────────────────────────────────

class _EditBudgetSheet extends StatefulWidget {
  const _EditBudgetSheet({required this.budget, required this.onSave});

  final Budget budget;
  final Future<void> Function(double amount) onSave;

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  late final TextEditingController _controller;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
        text: widget.budget.amountLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final categoryName =
        widget.budget.categoryName ?? l10n.budgetCategoryAll;

    return AppSheetContainer(
      topRadius: 28,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: l10n.budgetEditTitle,
            onClose: () => context.pop(),
          ),
          const SizedBox(height: 20),
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
                Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          FieldLabel(l10n.budgetAmountLabel),
          const SizedBox(height: 8),
          AmountInputField(
            controller: _controller,
            label: l10n.budgetAmountLabel,
            autofocus: true,
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: l10n.commonSave,
            onPressed: _saving ? null : _submit,
            isLoading: _saving,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await widget.onSave(amount);
    if (mounted) context.pop();
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
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'S/ ${spent.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          if (limit > 0)
            Text(
              'de S/ ${limit.toStringAsFixed(0)}',
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
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              if (isOver) ...[
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFEF4444), size: 18),
                const SizedBox(width: 4),
              ],
              Text(
                'S/ ${budget.currentSpent.toStringAsFixed(0)} / S/ ${budget.amountLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color:
                      isOver ? const Color(0xFFEF4444) : const Color(0xFF6B7280),
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
          const SizedBox(height: 10),
          AppProgressBar(
            value: (pct / 100).clamp(0.0, 1.0),
            height: 6,
            color: color,
          ),
        ],
      ),
    );
  }
}
