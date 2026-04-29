import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/services/budget_api_service.dart';
import '../../core/services/category_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _budgetServiceProvider = Provider<BudgetApiService>((ref) {
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
        .read(_budgetServiceProvider)
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

  void _prevMonth() {
    setState(() {
      if (_month == 1) {
        _month = 12;
        _year -= 1;
      } else {
        _month -= 1;
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_month == 12) {
        _month = 1;
        _year += 1;
      } else {
        _month += 1;
      }
    });
  }

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final budgetsAsync = ref.watch(_budgetsProvider(_filter));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.budgetTitle)),
      body: Column(
        children: [
          _MonthSelector(
            label: '${_monthNames[_month - 1]} $_year',
            onPrev: _prevMonth,
            onNext: _nextMonth,
          ),
          Expanded(
            child: budgetsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (_, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.budgetErrorLoad),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.invalidate(_budgetsProvider(_filter)),
                      child: Text(l10n.commonRetry),
                    ),
                  ],
                ),
              ),
              data: (budgets) => budgets.isEmpty
                  ? _EmptyState(
                      title: l10n.budgetEmptyTitle,
                      subtitle: l10n.budgetEmptySubtitle,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: budgets.length,
                      itemBuilder: (context, index) => _BudgetCard(
                        budget: budgets[index],
                        onDelete: () => _deleteBudget(budgets[index].id),
                        onEdit: () => _showEditDialog(budgets[index]),
                      ),
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCreateDialog() async {
    final l10n = context.l10n;
    final categoriesAsync = ref.read(_categoriesProvider.future);

    final amountController = TextEditingController();
    String? selectedCategoryId;
    int selectedMonth = _month;
    int selectedYear = _year;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: Text(l10n.budgetAddTitle),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<CategoryModel>>(
              future: categoriesAsync,
              builder: (ctx, snap) {
                final categories = snap.data ?? [];
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String?>(
                        value: selectedCategoryId,
                        decoration: InputDecoration(
                          labelText: l10n.budgetCategoryAll,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(l10n.budgetCategoryAll),
                          ),
                          ...categories.map(
                            (c) => DropdownMenuItem<String?>(
                              value: c.id,
                              child: Text(c.name),
                            ),
                          ),
                        ],
                        onChanged: (v) =>
                            setDlgState(() => selectedCategoryId = v),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: InputDecoration(
                          labelText: l10n.budgetAmountLabel,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedMonth,
                              decoration: InputDecoration(
                                labelText: l10n.budgetMonthLabel,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              items: List.generate(
                                12,
                                (i) => DropdownMenuItem(
                                  value: i + 1,
                                  child: Text(_monthNames[i]),
                                ),
                              ),
                              onChanged: (v) =>
                                  setDlgState(() => selectedMonth = v!),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedYear,
                              decoration: InputDecoration(
                                labelText: l10n.budgetYearLabel,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              items: List.generate(
                                5,
                                (i) {
                                  final y = DateTime.now().year + i - 1;
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text('$y'),
                                  );
                                },
                              ),
                              onChanged: (v) =>
                                  setDlgState(() => selectedYear = v!),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
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
      ),
    );

    if (confirmed != true || !mounted) return;
    final amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) return;

    try {
      await ref.read(_budgetServiceProvider).create(
            categoryId: selectedCategoryId,
            amountLimit: amount,
            month: selectedMonth,
            year: selectedYear,
          );
      ref.invalidate(_budgetsProvider(_filter));
    } on Exception catch (e) {
      if (!mounted) return;
      final msg = e.toString().contains('409') || e.toString().contains('already exists')
          ? l10n.budgetDuplicate
          : l10n.commonUnknownError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  Future<void> _showEditDialog(Budget budget) async {
    final l10n = context.l10n;
    final controller =
        TextEditingController(text: budget.amountLimit.toStringAsFixed(2));

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.budgetEditTitle),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.budgetAmountLabel,
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

    if (confirmed != true || !mounted) return;
    final amount = double.tryParse(controller.text.trim());
    if (amount == null || amount <= 0) return;

    await ref.read(_budgetServiceProvider).update(budget.id, amountLimit: amount);
    ref.invalidate(_budgetsProvider(_filter));
  }

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
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(_budgetServiceProvider).delete(id);
    ref.invalidate(_budgetsProvider(_filter));
  }
}

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.label,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          SizedBox(
            width: 120,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
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

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _BudgetCard({
    required this.budget,
    required this.onDelete,
    required this.onEdit,
  });

  Color _progressColor(double pct) {
    if (pct >= 80) return const Color(0xFFEF4444); // red
    if (pct >= 60) return const Color(0xFFF59E0B); // yellow
    return const Color(0xFF10B981); // green
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pct = budget.percentageUsed.clamp(0, 100).toDouble();
    final color = _progressColor(pct);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    budget.categoryName ?? l10n.budgetCategoryAll,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                ),
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
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.budgetSpentOf(
                    budget.currentSpent.toStringAsFixed(2),
                    budget.amountLimit.toStringAsFixed(2),
                  ),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  l10n.budgetPercentUsed(pct.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
