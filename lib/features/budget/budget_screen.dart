import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/budget.dart';
import '../../core/models/category.dart';
import '../../core/services/budget_api_service.dart';
import '../../core/services/category_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
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
      appBar: AppBar(
        title: Text(l10n.budgetTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => _showMonthPicker(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_monthNames[_month - 1]} $_year',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_today_outlined, size: 14),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: budgetsAsync.when(
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
        data: (budgets) {
          if (budgets.isEmpty) {
            return _EmptyState(
              title: l10n.budgetEmptyTitle,
              subtitle: l10n.budgetEmptySubtitle,
            );
          }
          final summary = _computeSummary(budgets);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 3-column summary
              _BucketSummaryRow(summary: summary),
              const SizedBox(height: 20),
              // By Category header
              Text(
                l10n.budgetByCategory,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              ...budgets.map((b) => _BudgetCard(
                    budget: b,
                    onDelete: () => _deleteBudget(b.id),
                    onEdit: () => _showEditDialog(b),
                  )),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateDialog,
        backgroundColor: const Color(0xFF34D399),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 0),
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    // Simple prev/next dialog for month navigation
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.budgetSelectPeriod),
        content: StatefulBuilder(
          builder: (ctx, setDlg) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  _prevMonth();
                  setDlg(() {});
                },
                icon: const Icon(Icons.chevron_left),
              ),
              SizedBox(
                width: 110,
                child: Text(
                  '${_monthNames[_month - 1]} $_year',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () {
                  _nextMonth();
                  setDlg(() {});
                },
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.commonDone),
          ),
        ],
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
                        initialValue: selectedCategoryId,
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
                              initialValue: selectedMonth,
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
                              initialValue: selectedYear,
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
      await ref.read(budgetServiceProvider).create(
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

    await ref.read(budgetServiceProvider).update(budget.id, amountLimit: amount);
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

class _BucketSummary {
  final double needsSpent;
  final double needsLimit;
  final double wantsSpent;
  final double wantsLimit;
  final double savingsSpent;
  final double savingsLimit;

  const _BucketSummary({
    required this.needsSpent,
    required this.needsLimit,
    required this.wantsSpent,
    required this.wantsLimit,
    required this.savingsSpent,
    required this.savingsLimit,
  });
}

class _BucketSummaryRow extends StatelessWidget {
  final _BucketSummary summary;
  const _BucketSummaryRow({required this.summary});

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
  final String label;
  final double spent;
  final double limit;
  final Color color;

  const _BucketCell({
    required this.label,
    required this.spent,
    required this.limit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            'S/ ${spent.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (limit > 0)
            Text(
              'of S/ ${limit.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
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
    if (pct > 80) return const Color(0xFFEF4444); // red
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
