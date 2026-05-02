import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/category.dart';
import '../../core/services/api_client.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

// ── Filter state ──────────────────────────────────────────────────────────────

class _TxFilters {
  final String type; // 'ALL', 'INCOME', 'EXPENSE'
  final String datePreset; // 'all', 'week', 'month'
  final DateTime? from;
  final DateTime? to;
  final String? categoryId;
  final String? categoryName;
  final double? minAmount;
  final double? maxAmount;

  const _TxFilters({
    this.type = 'ALL',
    this.datePreset = 'all',
    this.from,
    this.to,
    this.categoryId,
    this.categoryName,
    this.minAmount,
    this.maxAmount,
  });

  int get activeCount {
    int count = 0;
    if (type != 'ALL') count++;
    if (datePreset != 'all' || from != null || to != null) count++;
    if (categoryId != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    return count;
  }

  _TxFilters copyWith({
    String? type,
    String? datePreset,
    DateTime? from,
    DateTime? to,
    bool clearFrom = false,
    bool clearTo = false,
    String? categoryId,
    String? categoryName,
    bool clearCategory = false,
    double? minAmount,
    double? maxAmount,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) {
    return _TxFilters(
      type: type ?? this.type,
      datePreset: datePreset ?? this.datePreset,
      from: clearFrom ? null : (from ?? this.from),
      to: clearTo ? null : (to ?? this.to),
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
      minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
      maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
    );
  }
}

class _FiltersNotifier extends Notifier<_TxFilters> {
  @override
  _TxFilters build() => const _TxFilters();

  void update(_TxFilters filters) => state = filters;

  void reset() => state = const _TxFilters();
}

final _txFiltersProvider =
    NotifierProvider<_FiltersNotifier, _TxFilters>(() => _FiltersNotifier());

// ── Data provider ─────────────────────────────────────────────────────────────

final transactionListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final f = ref.watch(_txFiltersProvider);
  final apiService = ref.read(transactionApiServiceProvider);

  String? typeParam = f.type == 'ALL' ? null : f.type;
  String? fromParam;
  String? toParam;

  final now = DateTime.now();
  if (f.datePreset == 'week') {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    fromParam = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
        .toUtc()
        .toIso8601String();
  } else if (f.datePreset == 'month') {
    fromParam = DateTime(now.year, now.month, 1).toUtc().toIso8601String();
  } else if (f.datePreset == 'custom') {
    fromParam = f.from?.toUtc().toIso8601String();
    toParam = f.to?.toUtc().toIso8601String();
  }

  var txs = await apiService.getAll(
    type: typeParam,
    from: fromParam,
    to: toParam,
    categoryId: f.categoryId,
  );

  // Client-side amount range filter (backend doesn't support this param yet).
  if (f.minAmount != null) {
    txs = txs.where((tx) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      return amount >= f.minAmount!;
    }).toList();
  }
  if (f.maxAmount != null) {
    txs = txs.where((tx) {
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
      return amount <= f.maxAmount!;
    }).toList();
  }

  return txs;
});

// ── Category icon helper ──────────────────────────────────────────────────────

IconData _iconForCategory(String? categoryName) {
  if (categoryName == null) return Icons.swap_horiz_rounded;
  return switch (categoryName.toLowerCase()) {
    'food' => Icons.restaurant_rounded,
    'transportation' => Icons.directions_bus_rounded,
    'housing' => Icons.home_rounded,
    'utilities' => Icons.bolt_rounded,
    'health' => Icons.favorite_rounded,
    'entertainment' => Icons.sports_esports_rounded,
    'shopping' => Icons.shopping_bag_rounded,
    'subscriptions' => Icons.subscriptions_rounded,
    'cravings' => Icons.icecream_rounded,
    'savings' => Icons.savings_rounded,
    'other' => Icons.category_rounded,
    _ => Icons.category_rounded,
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final onSurface = isDark ? Colors.white : Colors.black87;

    final filters = ref.watch(_txFiltersProvider);
    final txAsync = ref.watch(transactionListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(transactionListProvider),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              isNarrow ? 16 : 20,
              isNarrow ? 16 : 24,
              isNarrow ? 16 : 20,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        l10n.txListTitle,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: onSurface,
                        ),
                      ),
                      const Spacer(),
                      // Filters button with active count badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.tune_rounded,
                              color: filters.activeCount > 0
                                  ? const Color(0xFF34D399)
                                  : onSurface.withValues(alpha: 0.6),
                            ),
                            tooltip: l10n.txFilterAdvanced,
                            onPressed: () => _showFilterSheet(context, ref),
                          ),
                          if (filters.activeCount > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF34D399),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${filters.activeCount}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Type filter chips
                  _FilterRow(
                    chips: [
                      _FilterChipData(label: l10n.txListFilterAll, value: 'ALL'),
                      _FilterChipData(label: l10n.txListFilterExpenses, value: 'EXPENSE'),
                      _FilterChipData(label: l10n.txListFilterIncome, value: 'INCOME'),
                    ],
                    selected: filters.type,
                    onSelected: (v) => ref
                        .read(_txFiltersProvider.notifier)
                        .update(filters.copyWith(type: v)),
                  ),
                  const SizedBox(height: 8),
                  // Date preset chips
                  _FilterRow(
                    chips: [
                      _FilterChipData(label: l10n.txListFilterAllTime, value: 'all'),
                      _FilterChipData(label: l10n.txListFilterThisWeek, value: 'week'),
                      _FilterChipData(label: l10n.txListFilterThisMonth, value: 'month'),
                    ],
                    selected: filters.datePreset == 'custom' ? '' : filters.datePreset,
                    onSelected: (v) => ref
                        .read(_txFiltersProvider.notifier)
                        .update(filters.copyWith(datePreset: v, clearFrom: true, clearTo: true)),
                  ),
                  // Active advanced filter summary
                  if (filters.categoryId != null || filters.minAmount != null || filters.maxAmount != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        children: [
                          if (filters.categoryId != null)
                            _ActiveFilterChip(
                              label: filters.categoryName ?? filters.categoryId!,
                              onRemove: () => ref
                                  .read(_txFiltersProvider.notifier)
                                  .update(filters.copyWith(clearCategory: true)),
                            ),
                          if (filters.minAmount != null)
                            _ActiveFilterChip(
                              label: '≥ S/${filters.minAmount!.toStringAsFixed(0)}',
                              onRemove: () => ref
                                  .read(_txFiltersProvider.notifier)
                                  .update(filters.copyWith(clearMinAmount: true)),
                            ),
                          if (filters.maxAmount != null)
                            _ActiveFilterChip(
                              label: '≤ S/${filters.maxAmount!.toStringAsFixed(0)}',
                              onRemove: () => ref
                                  .read(_txFiltersProvider.notifier)
                                  .update(filters.copyWith(clearMaxAmount: true)),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          txAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  l10n.commonUnknownError,
                  style: TextStyle(color: onSurface.withValues(alpha: 0.75)),
                ),
              ),
            ),
            data: (txs) {
              if (txs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.txListEmpty,
                      style: TextStyle(color: onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  isNarrow ? 16 : 20,
                  0,
                  isNarrow ? 16 : 20,
                  120,
                ),
                sliver: SliverList.separated(
                  itemCount: txs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return _TransactionTile(
                      tx: tx,
                      isDark: isDark,
                      onDeleted: () {
                        ref.invalidate(transactionListProvider);
                        ref.invalidate(daySummaryProvider);
                        ref.invalidate(weekSummaryProvider);
                        ref.invalidate(monthSummaryProvider);
                        ref.invalidate(transactionsProvider);
                        ref.invalidate(accountsProvider);
                      },
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _FilterSheet(
        initial: ref.read(_txFiltersProvider),
        onApply: (updated) {
          ref.read(_txFiltersProvider.notifier).update(updated);
          Navigator.pop(context);
        },
        onClear: () {
          ref.read(_txFiltersProvider.notifier).reset();
          Navigator.pop(context);
        },
      ),
    );
  }
}

// ── Advanced filter bottom sheet ──────────────────────────────────────────────

class _FilterSheet extends ConsumerStatefulWidget {
  final _TxFilters initial;
  final ValueChanged<_TxFilters> onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.initial,
    required this.onApply,
    required this.onClear,
  });

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late _TxFilters _draft;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();
  DateTime? _from;
  DateTime? _to;

  final _categoriesProvider = FutureProvider<List<CategoryModel>>(
    (ref) => ref.read(categoryApiServiceProvider).getAll(),
  );

  @override
  void initState() {
    super.initState();
    _draft = widget.initial;
    _from = widget.initial.from;
    _to = widget.initial.to;
    if (_draft.minAmount != null) {
      _minCtrl.text = _draft.minAmount!.toStringAsFixed(0);
    }
    if (_draft.maxAmount != null) {
      _maxCtrl.text = _draft.maxAmount!.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFrom(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _from ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _from = picked;
        _draft = _draft.copyWith(
          datePreset: 'custom',
          from: picked,
        );
      });
    }
  }

  Future<void> _pickTo(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _to = picked;
        _draft = _draft.copyWith(
          datePreset: 'custom',
          to: picked,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(_categoriesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.txFilterAdvanced,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 20),

          // Category
          Text(l10n.txFilterCategory,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (_, _) => const SizedBox.shrink(),
            data: (categories) => DropdownButtonFormField<String?>(
              key: ValueKey(_draft.categoryId),
              initialValue: _draft.categoryId,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(l10n.txFilterAllCategories),
                ),
                ...categories.map(
                  (c) => DropdownMenuItem<String?>(
                    value: c.id,
                    child: Text(c.name),
                  ),
                ),
              ],
              onChanged: (id) {
                final name = id == null
                    ? null
                    : categories.firstWhere((c) => c.id == id).name;
                setState(() {
                  _draft = _draft.copyWith(
                    categoryId: id,
                    categoryName: name,
                    clearCategory: id == null,
                  );
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          // Amount range
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.txFilterMinAmount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    setState(() {
                      _draft = parsed != null
                          ? _draft.copyWith(minAmount: parsed)
                          : _draft.copyWith(clearMinAmount: true);
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: l10n.txFilterMaxAmount,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  onChanged: (v) {
                    final parsed = double.tryParse(v);
                    setState(() {
                      _draft = parsed != null
                          ? _draft.copyWith(maxAmount: parsed)
                          : _draft.copyWith(clearMaxAmount: true);
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Date range
          Text(l10n.txFilterCustomRange,
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickFrom(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.txFilterDateFrom,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    child: Text(
                      _from != null
                          ? '${_from!.day.toString().padLeft(2, '0')}/${_from!.month.toString().padLeft(2, '0')}/${_from!.year}'
                          : '—',
                      style: TextStyle(
                        fontSize: 14,
                        color: _from != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _pickTo(context),
                  borderRadius: BorderRadius.circular(12),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.txFilterDateTo,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                    child: Text(
                      _to != null
                          ? '${_to!.day.toString().padLeft(2, '0')}/${_to!.month.toString().padLeft(2, '0')}/${_to!.year}'
                          : '—',
                      style: TextStyle(
                        fontSize: 14,
                        color: _to != null ? null : Colors.grey,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_from != null || _to != null)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _from = null;
                    _to = null;
                    _draft = _draft.copyWith(
                      datePreset: 'all',
                      clearFrom: true,
                      clearTo: true,
                    );
                  });
                },
                child: Text(l10n.txFilterClearDates),
              ),
            ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onClear,
                  child: Text(l10n.txFilterClear),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => widget.onApply(_draft),
                  child: Text(l10n.txFilterApply),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Filter row ────────────────────────────────────────────────────────────────

class _FilterChipData {
  final String label;
  final String value;

  const _FilterChipData({required this.label, required this.value});
}

class _FilterRow extends StatelessWidget {
  final List<_FilterChipData> chips;
  final String selected;
  final ValueChanged<String> onSelected;

  const _FilterRow({
    required this.chips,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          final isSelected = chip.value == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(chip.label),
              selected: isSelected,
              onSelected: (_) => onSelected(chip.value),
              selectedColor: const Color(0xFF34D399).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF34D399),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF34D399) : null,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Active filter chip (dismissible) ─────────────────────────────────────────

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      deleteIcon: const Icon(Icons.close, size: 14),
      onDeleted: onRemove,
      backgroundColor: const Color(0xFF34D399).withValues(alpha: 0.1),
      side: const BorderSide(color: Color(0xFF34D399), width: 0.5),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }
}

// ── Transaction tile ──────────────────────────────────────────────────────────

class _TransactionTile extends ConsumerWidget {
  final Map<String, dynamic> tx;
  final bool isDark;
  final VoidCallback onDeleted;

  const _TransactionTile({
    required this.tx,
    required this.isDark,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = tx['id'] as String? ?? '';
    final type = tx['type'] as String? ?? 'expense';
    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    final description = tx['description'] as String? ?? '';
    final occurredAt = tx['occurredAt'] as String?;
    final category = tx['category'] as Map<String, dynamic>?;
    final categoryName = category?['name'] as String?;

    DateTime? parsedDate;
    if (occurredAt != null) {
      parsedDate = DateTime.tryParse(occurredAt)?.toLocal();
    }

    final isIncome = type.toUpperCase() == 'INCOME';
    final amountColor =
        isIncome ? const Color(0xFF34D399) : const Color(0xFFEF4444);
    final amountSign = isIncome ? '+' : '-';

    final displayLabel =
        description.isNotEmpty ? description : (categoryName ?? '');
    final dateLabel = parsedDate != null
        ? '${parsedDate.day.toString().padLeft(2, '0')}/${parsedDate.month.toString().padLeft(2, '0')} ${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')}'
        : '';

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.txDeleteConfirmTitle),
            content: Text(l10n.txDeleteConfirmMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.commonCancel),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(
                  l10n.txDeleteAction,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) async {
        try {
          await ApiClient.delete('/transactions/$id');
          onDeleted();
        } catch (_) {
          onDeleted();
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.txDeleteError),
                backgroundColor: const Color(0xFFEF4444),
              ),
            );
          }
        }
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          final refreshed = await context.push<bool>(
            '/edit-transaction',
            extra: tx,
          );
          if (refreshed == true) onDeleted();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: amountColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForCategory(categoryName),
                  color: amountColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateLabel,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$amountSign S/ ${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
