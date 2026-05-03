import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/services/api_client.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../features/transactions/add_transaction_screen.dart';
import '../../features/transactions/edit_transaction_screen.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

// ── Filter state ──────────────────────────────────────────────────────────────

class _TxFilters {
  final String type; // 'ALL', 'INCOME', 'EXPENSE'
  const _TxFilters({this.type = 'ALL'});
  _TxFilters copyWith({String? type}) => _TxFilters(type: type ?? this.type);
}

class _FiltersNotifier extends Notifier<_TxFilters> {
  @override
  _TxFilters build() => const _TxFilters();
  void update(_TxFilters filters) => state = filters;
}

final _txFiltersProvider =
    NotifierProvider<_FiltersNotifier, _TxFilters>(() => _FiltersNotifier());

// ── Data provider ─────────────────────────────────────────────────────────────

final transactionListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final f = ref.watch(_txFiltersProvider);
  final apiService = ref.read(transactionApiServiceProvider);
  final typeParam = f.type == 'ALL' ? null : f.type;
  return apiService.getAll(type: typeParam);
});

// ── Category helpers ───────────────────────────────────────────────────────────

IconData _iconForCategory(String? name) {
  if (name == null) return Icons.swap_horiz_rounded;
  return switch (name.toLowerCase()) {
    'food' || 'comida' => Icons.restaurant_rounded,
    'transportation' || 'transporte' => Icons.directions_bus_rounded,
    'housing' || 'vivienda' => Icons.home_rounded,
    'utilities' || 'servicios' => Icons.bolt_rounded,
    'health' || 'salud' => Icons.favorite_rounded,
    'entertainment' || 'entretenimiento' => Icons.sports_esports_rounded,
    'shopping' || 'compras' => Icons.shopping_bag_rounded,
    'subscriptions' || 'suscripciones' => Icons.subscriptions_rounded,
    'cravings' || 'antojos' => Icons.icecream_rounded,
    'savings' || 'ahorro' => Icons.savings_rounded,
    _ => Icons.category_rounded,
  };
}

Color _bgColorForCategory(String? name, bool isIncome) {
  if (isIncome) return const Color(0xFFECFDF5);
  if (name == null) return const Color(0xFFFEE2E2);
  return switch (name.toLowerCase()) {
    'food' || 'comida' => const Color(0xFFFEF3C7),
    'transportation' || 'transporte' => const Color(0xFFDBEAFE),
    'housing' || 'vivienda' => const Color(0xFFEDE9FE),
    'health' || 'salud' => const Color(0xFFFCE7F3),
    'savings' || 'ahorro' => const Color(0xFFECFDF5),
    _ => const Color(0xFFFEE2E2),
  };
}

Color _iconColorForCategory(String? name, bool isIncome) {
  if (isIncome) return const Color(0xFF059669);
  if (name == null) return const Color(0xFFEF4444);
  return switch (name.toLowerCase()) {
    'food' || 'comida' => const Color(0xFFD97706),
    'transportation' || 'transporte' => const Color(0xFF3B82F6),
    'housing' || 'vivienda' => const Color(0xFF7C3AED),
    'health' || 'salud' => const Color(0xFFEC4899),
    'savings' || 'ahorro' => const Color(0xFF059669),
    _ => const Color(0xFFEF4444),
  };
}

// ── Screen ────────────────────────────────────────────────────────────────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
      body: const SafeArea(child: TransactionListScreen()),
      bottomNavigationBar: const AppBottomNav(activeIndex: 1),
    );
  }
}

// ── Transaction list ───────────────────────────────────────────────────────────

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1F2937);

    final filters = ref.watch(_txFiltersProvider);
    final txAsync = ref.watch(transactionListProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(transactionListProvider),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    children: [
                      Text(
                        l10n.txListTitle,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => AddTransactionScreen.show(context),
                        child: Container(
                          height: 36,
                          padding:
                              const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF34D399),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            l10n.txAddButton,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const UserMenuButton(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Type filter chips — matches design: Todos / Ingresos / Gastos
                  Row(
                    children: [
                      _TxChip(
                        label: l10n.txListFilterAll,
                        selected: filters.type == 'ALL',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'ALL')),
                      ),
                      const SizedBox(width: 8),
                      _TxChip(
                        label: l10n.txListFilterIncome,
                        selected: filters.type == 'INCOME',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'INCOME')),
                      ),
                      const SizedBox(width: 8),
                      _TxChip(
                        label: l10n.txListFilterExpenses,
                        selected: filters.type == 'EXPENSE',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'EXPENSE')),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
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
                  style:
                      TextStyle(color: onSurface.withValues(alpha: 0.75)),
                ),
              ),
            ),
            data: (txs) {
              if (txs.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Text(
                      l10n.txListEmpty,
                      style: TextStyle(
                          color: onSurface.withValues(alpha: 0.6)),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                sliver: SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      children: [
                        for (int i = 0; i < txs.length; i++)
                          _TransactionRow(
                            tx: txs[i],
                            showTopBorder: i > 0,
                            onDeleted: () {
                              ref.invalidate(transactionListProvider);
                              ref.invalidate(daySummaryProvider);
                              ref.invalidate(weekSummaryProvider);
                              ref.invalidate(monthSummaryProvider);
                              ref.invalidate(transactionsProvider);
                              ref.invalidate(accountsProvider);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Type chip ─────────────────────────────────────────────────────────────────

class _TxChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TxChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color:
              selected ? const Color(0xFF34D399) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            color: selected
                ? Colors.white
                : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}

// ── Transaction row ───────────────────────────────────────────────────────────

class _TransactionRow extends ConsumerWidget {
  final Map<String, dynamic> tx;
  final bool showTopBorder;
  final VoidCallback onDeleted;

  const _TransactionRow({
    required this.tx,
    required this.showTopBorder,
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
        isIncome ? const Color(0xFF059669) : const Color(0xFFEF4444);
    final amountSign = isIncome ? '+' : '-';
    final bgColor = _bgColorForCategory(categoryName, isIncome);
    final iconColor = _iconColorForCategory(categoryName, isIncome);

    final displayLabel =
        description.isNotEmpty ? description : (categoryName ?? '');
    String relativeDay(DateTime d) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final txDay = DateTime(d.year, d.month, d.day);
      final diff = today.difference(txDay).inDays;
      if (diff == 0) return l10n.txListToday;
      if (diff == 1) return l10n.txListYesterday;
      return DateFormat('MMMd').format(d);
    }

    final timeStr = parsedDate != null
        ? '${parsedDate.hour.toString().padLeft(2, '0')}:${parsedDate.minute.toString().padLeft(2, '0')} ${parsedDate.hour < 12 ? 'AM' : 'PM'}'
        : '';
    final categoryDisplay = categoryName != null
        ? categoryName[0].toUpperCase() + categoryName.substring(1).toLowerCase()
        : '';
    final dateLabel = parsedDate != null
        ? '${relativeDay(parsedDate)}, $timeStr${categoryDisplay.isNotEmpty ? ' · $categoryDisplay' : ''}'
        : '';

    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFFEF4444).withValues(alpha: 0.12),
        child: const Icon(Icons.delete_rounded, color: Color(0xFFEF4444)),
      ),
      confirmDismiss: (_) async {
        return showDialog<bool>(
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
            showAppToast(
              context,
              context.l10n.txDeleteError,
              type: ToastType.error,
            );
          }
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: showTopBorder
              ? const Border(
                  top: BorderSide(color: Color(0xFFF3F4F6)),
                )
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              final refreshed =
                  await EditTransactionScreen.show(context, tx);
              if (refreshed == true) onDeleted();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _iconForCategory(categoryName),
                      color: iconColor,
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
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dateLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$amountSign S/ ${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
