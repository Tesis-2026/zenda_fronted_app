import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

// ── Filter state providers ───────────────────────────────────────────────────

class _StringNotifier extends Notifier<String> {
  final String initial;
  _StringNotifier(this.initial);

  @override
  String build() => initial;

  void set(String value) => state = value;
}

/// 'ALL', 'INCOME', 'EXPENSE'
final _typeFilterProvider =
    NotifierProvider<_StringNotifier, String>(() => _StringNotifier('ALL'));

/// 'all', 'week', 'month'
final _dateFilterProvider =
    NotifierProvider<_StringNotifier, String>(() => _StringNotifier('all'));

// ── Data provider ────────────────────────────────────────────────────────────

final transactionListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final type = ref.watch(_typeFilterProvider);
  final dateFilter = ref.watch(_dateFilterProvider);

  final apiService = ref.read(transactionApiServiceProvider);

  String? typeParam = type == 'ALL' ? null : type;
  String? fromParam;

  final now = DateTime.now();
  if (dateFilter == 'week') {
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    fromParam = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
        .toUtc()
        .toIso8601String();
  } else if (dateFilter == 'month') {
    fromParam =
        DateTime(now.year, now.month, 1).toUtc().toIso8601String();
  }

  return apiService.getAll(type: typeParam, from: fromParam);
});

// ── Category icon helper ─────────────────────────────────────────────────────

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

// ── Screen ───────────────────────────────────────────────────────────────────

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    final onSurface = isDark ? Colors.white : Colors.black87;

    final typeFilter = ref.watch(_typeFilterProvider);
    final dateFilter = ref.watch(_dateFilterProvider);
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
                  Text(
                    l10n.txListTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Type filter chips
                  _FilterRow(
                    chips: [
                      _FilterChipData(
                        label: l10n.txListFilterAll,
                        value: 'ALL',
                      ),
                      _FilterChipData(
                        label: l10n.txListFilterExpenses,
                        value: 'EXPENSE',
                      ),
                      _FilterChipData(
                        label: l10n.txListFilterIncome,
                        value: 'INCOME',
                      ),
                    ],
                    selected: typeFilter,
                    onSelected: (v) =>
                        ref.read(_typeFilterProvider.notifier).set(v),
                  ),
                  const SizedBox(height: 8),
                  // Date filter chips
                  _FilterRow(
                    chips: [
                      _FilterChipData(
                        label: l10n.txListFilterAllTime,
                        value: 'all',
                      ),
                      _FilterChipData(
                        label: l10n.txListFilterThisWeek,
                        value: 'week',
                      ),
                      _FilterChipData(
                        label: l10n.txListFilterThisMonth,
                        value: 'month',
                      ),
                    ],
                    selected: dateFilter,
                    onSelected: (v) =>
                        ref.read(_dateFilterProvider.notifier).set(v),
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
            error: (err, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  err.toString(),
                  style: TextStyle(color: onSurface.withOpacity(0.75)),
                ),
              ),
            ),
            data: (txs) {
              if (txs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.txListEmpty,
                      style: TextStyle(color: onSurface.withOpacity(0.6)),
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
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final tx = txs[index];
                    return _TransactionTile(
                      tx: tx,
                      isDark: isDark,
                      onDeleted: () => ref.invalidate(transactionListProvider),
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
              selectedColor: const Color(0xFF34D399).withOpacity(0.2),
              checkmarkColor: const Color(0xFF34D399),
              labelStyle: TextStyle(
                color: isSelected
                    ? const Color(0xFF34D399)
                    : null,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
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

    final displayLabel = description.isNotEmpty ? description : (categoryName ?? '');
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
          color: const Color(0xFFEF4444).withOpacity(0.15),
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
        } catch (_) {
          // Deletion failed — list refresh will restore it
        }
        onDeleted();
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
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
                color: amountColor.withOpacity(0.15),
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
    );
  }
}
