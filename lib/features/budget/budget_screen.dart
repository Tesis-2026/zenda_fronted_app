import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/services/budget_api_service.dart';
import '../../core/services/category_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';

final budgetServiceProvider = Provider<BudgetApiService>((ref) {
  return BudgetApiService();
});

final _categoryServiceProvider = Provider<CategoryApiService>((ref) {
  return CategoryApiService();
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
  return ref.read(_categoryServiceProvider).getAll();
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
      backgroundColor: const Color(0xFFF9FAFB),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.budgetDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Text(
            l10n.budgetByCategory.split(' ').first == 'By'
                ? 'Budget'
                : 'Budget',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(width: 4),
          // Inline ← month → navigator — consistent with predictions/progress
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: const Color(0xFF6B7280),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE5E7EB)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
            color: const Color(0xFF6B7280),
          ),
          const Spacer(),
          // Visible "+ Add" pill — matches Pencil design
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399),
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                l10n.catMgmtAddButton,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
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
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.budgetAddTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 20),
            // Category dropdown
            Text(
              l10n.budgetCategoryAll,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
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
            // Monthly limit — styled like the amount field in add transaction
            Text(
              l10n.budgetAmountLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34D399), width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'S/',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
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
            // Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n.commonSave,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await widget.onSave(_selectedCategoryId, amount, _month, _year);
    if (mounted) Navigator.pop(context);
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

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Title row
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.budgetEditTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.close_rounded,
                        size: 16, color: Color(0xFF6B7280)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Category (read-only)
            Text(
              l10n.budgetCategoryAll.split(' ').first == 'All'
                  ? 'Category'
                  : 'Categoría',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: [
                  Icon(
                    _iconForBudgetCategory(widget.budget.categoryName),
                    size: 16,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    categoryName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Monthly limit
            Text(
              l10n.budgetAmountLabel,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF34D399), width: 2),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'S/',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        l10n.commonSave,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_controller.text.trim());
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    await widget.onSave(amount);
    if (mounted) Navigator.pop(context);
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
              'of S/ ${limit.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
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

IconData _iconForBudgetCategory(String? name) {
  if (name == null) return Icons.account_balance_wallet_outlined;
  return switch (name.toLowerCase()) {
    'food' || 'comida' => Icons.restaurant_rounded,
    'transportation' || 'transporte' => Icons.directions_bus_rounded,
    'housing' || 'vivienda' => Icons.home_rounded,
    'utilities' || 'servicios' => Icons.bolt_rounded,
    'health' || 'salud' => Icons.favorite_rounded,
    'entertainment' || 'entretenimiento' => Icons.sports_esports_rounded,
    'shopping' || 'compras' => Icons.shopping_bag_rounded,
    'subscriptions' || 'suscripciones' => Icons.subscriptions_rounded,
    'savings' || 'ahorro' => Icons.savings_rounded,
    _ => Icons.category_rounded,
  };
}

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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconForBudgetCategory(budget.categoryName),
                  size: 18,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
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
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      size: 15, color: Color(0xFF9CA3AF)),
                ),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.delete_outline,
                      size: 15, color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: const Color(0xFFF3F4F6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}
