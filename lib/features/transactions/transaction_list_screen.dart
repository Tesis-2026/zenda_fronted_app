import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/green_pill_button.dart';
import '../../core/widgets/icon_action_button.dart';
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

// ── Screen ────────────────────────────────────────────────────────────────────

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bg,
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
    final colors = context.colors;
    final onSurface = colors.textPrimary;

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
                      GreenPillButton(
                        label: l10n.txAddButton,
                        height: 36,
                        onTap: () => AddTransactionScreen.show(context),
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
                  child: AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: l10n.txListEmpty,
                    subtitle: l10n.txListEmptySubtitle,
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
                      border: Border.all(color: AppColors.fillLight),
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
              selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? null
              : Border.all(color: AppColors.border),
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
                : AppColors.textMuted,
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
    final categoryIconKey = category?['icon'] as String?;

    DateTime? parsedDate;
    if (occurredAt != null) {
      parsedDate = DateTime.tryParse(occurredAt)?.toLocal();
    }

    final isIncome = type.toLowerCase() == 'income';
    final amountColor =
        isIncome ? AppColors.income : AppColors.danger;
    final amountSign = isIncome ? '+' : '-';
    final bgColor = CategoryUtils.bgColorForCategory(categoryName, isIncome: isIncome);
    final iconColor = CategoryUtils.iconColorForCategory(categoryName, isIncome: isIncome);

    final displayLabel =
        description.isNotEmpty ? description : CategoryUtils.labelEs(categoryName);
    String relativeDay(DateTime d) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final txDay = DateTime(d.year, d.month, d.day);
      final diff = today.difference(txDay).inDays;
      if (diff == 0) return l10n.txListToday;
      if (diff == 1) return l10n.txListYesterday;
      return AppDateFormatter.shortMonthDay(d);
    }

    final timeStr = parsedDate != null
        ? AppDateFormatter.timeOfDay(parsedDate)
        : '';
    // Always translate the backend category name to Spanish (the backend
    // seeds system categories in English, e.g. 'Food'); the app is es-only.
    final categoryDisplay = CategoryUtils.labelEs(categoryName);
    final dateLabel = parsedDate != null
        ? '${relativeDay(parsedDate)}, $timeStr${categoryDisplay.isNotEmpty ? ' · $categoryDisplay' : ''}'
        : '';

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showTopBorder
            ? const Border(top: BorderSide(color: Color(0xFFF3F4F6)))
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                CategoryUtils.iconForCategory(categoryName,
                    iconKey: categoryIconKey),
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
                      color: AppColors.textSubtle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$amountSign S/ ${amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 8),
            // Standard edit + delete affordance (matches budgets / categories).
            IconActionButton(
              icon: Icons.edit_outlined,
              backgroundColor: AppColors.fillLight,
              iconColor: AppColors.textSubtle,
              onTap: () async {
                final refreshed = await EditTransactionScreen.show(context, tx);
                if (refreshed == true) onDeleted();
              },
            ),
            const SizedBox(width: 6),
            IconActionButton(
              icon: Icons.delete_outline,
              backgroundColor: const Color(0xFFFEE2E2),
              iconColor: const Color(0xFFEF4444),
              onTap: () => _confirmDelete(context, ref, id),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, String id) async {
    final l10n = context.l10n;
    final confirmed = await showDeleteConfirmSheet(
      context,
      title: l10n.txDeleteConfirmTitle,
      message: l10n.txDeleteConfirmMessage,
    );
    if (confirmed != true) return;
    try {
      await ref.read(transactionApiServiceProvider).deleteTransaction(id);
      onDeleted();
    } catch (_) {
      if (context.mounted) {
        showAppToast(context, l10n.txDeleteError, type: ToastType.error);
      }
    }
  }
}
