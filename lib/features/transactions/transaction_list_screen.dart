import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/category.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/category_utils.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_date_field.dart';
import '../../core/widgets/app_empty_state.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/category_dropdown_field.dart';
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
  final DateTime? from;
  final DateTime? to;
  final String? categoryId;
  final String? categoryLabel;
  final double? minAmount;
  final double? maxAmount;

  const _TxFilters({
    this.type = 'ALL',
    this.from,
    this.to,
    this.categoryId,
    this.categoryLabel,
    this.minAmount,
    this.maxAmount,
  });

  int get activeCount =>
      (type == 'ALL' ? 0 : 1) +
      (from == null && to == null ? 0 : 1) +
      (categoryId == null ? 0 : 1) +
      (minAmount == null && maxAmount == null ? 0 : 1);

  int get advancedCount =>
      (categoryId == null ? 0 : 1) +
      (minAmount == null && maxAmount == null ? 0 : 1);

  bool get hasDateRange => from != null || to != null;
  bool get hasAdvancedFilters => advancedCount > 0;

  _TxFilters copyWith({
    String? type,
    DateTime? from,
    DateTime? to,
    String? categoryId,
    String? categoryLabel,
    double? minAmount,
    double? maxAmount,
    bool clearFrom = false,
    bool clearTo = false,
    bool clearCategory = false,
    bool clearMinAmount = false,
    bool clearMaxAmount = false,
  }) => _TxFilters(
    type: type ?? this.type,
    from: clearFrom ? null : (from ?? this.from),
    to: clearTo ? null : (to ?? this.to),
    categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    categoryLabel: clearCategory ? null : (categoryLabel ?? this.categoryLabel),
    minAmount: clearMinAmount ? null : (minAmount ?? this.minAmount),
    maxAmount: clearMaxAmount ? null : (maxAmount ?? this.maxAmount),
  );

  _TxFilters clearDates() => _TxFilters(
    type: type,
    categoryId: categoryId,
    categoryLabel: categoryLabel,
    minAmount: minAmount,
    maxAmount: maxAmount,
  );

  _TxFilters clearAdvanced() => _TxFilters(type: type, from: from, to: to);

  _TxFilters clearAll() => const _TxFilters();
}

class _FiltersNotifier extends Notifier<_TxFilters> {
  @override
  _TxFilters build() => const _TxFilters();
  void update(_TxFilters filters) => state = filters;
}

final _txFiltersProvider = NotifierProvider<_FiltersNotifier, _TxFilters>(
  () => _FiltersNotifier(),
);

final _txCategoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((
  ref,
) {
  return ref.read(categoryApiServiceProvider).getAll();
});

// ── Data provider ─────────────────────────────────────────────────────────────

final transactionListProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final f = ref.watch(_txFiltersProvider);
      final apiService = ref.read(transactionApiServiceProvider);
      final typeParam = f.type == 'ALL' ? null : f.type;
      return apiService.getAll(
        type: typeParam,
        from: _startOfDayIso(f.from),
        to: _endOfDayIso(f.to),
        categoryId: f.categoryId,
        minAmount: f.minAmount,
        maxAmount: f.maxAmount,
      );
    });

String? _startOfDayIso(DateTime? date) {
  if (date == null) return null;
  return DateTime(date.year, date.month, date.day).toUtc().toIso8601String();
}

String? _endOfDayIso(DateTime? date) {
  if (date == null) return null;
  return DateTime(
    date.year,
    date.month,
    date.day,
    23,
    59,
    59,
    999,
  ).toUtc().toIso8601String();
}

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
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _TxChip(
                        label: l10n.txListFilterAll,
                        selected: filters.type == 'ALL',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'ALL')),
                      ),
                      _TxChip(
                        label: l10n.txListFilterIncome,
                        selected: filters.type == 'INCOME',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'INCOME')),
                      ),
                      _TxChip(
                        label: l10n.txListFilterExpenses,
                        selected: filters.type == 'EXPENSE',
                        onTap: () => ref
                            .read(_txFiltersProvider.notifier)
                            .update(filters.copyWith(type: 'EXPENSE')),
                      ),
                      _DateRangeChip(
                        label: _dateRangeLabel(context, filters),
                        selected: filters.hasDateRange,
                        onTap: () => _showDateRangeSheet(context, ref, filters),
                      ),
                      _AdvancedFiltersChip(
                        label: _advancedFilterLabel(context, filters),
                        selected: filters.hasAdvancedFilters,
                        onTap: () =>
                            _showAdvancedFiltersSheet(context, ref, filters),
                      ),
                      if (filters.activeCount > 0)
                        _ClearFiltersChip(
                          label: l10n.txFilterClear,
                          onTap: () => ref
                              .read(_txFiltersProvider.notifier)
                              .update(filters.clearAll()),
                        ),
                    ],
                  ),
                  if (filters.activeCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      l10n.txFilterActiveCount(filters.activeCount),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSubtle,
                      ),
                    ),
                  ],
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
                  style: TextStyle(color: onSurface.withValues(alpha: 0.75)),
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
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: selected ? null : Border.all(color: AppColors.border),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? Colors.white : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _DateRangeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DateRangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEFF6FF) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF93C5FD) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: selected ? const Color(0xFF2563EB) : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? const Color(0xFF1D4ED8)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClearFiltersChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ClearFiltersChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedFiltersChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AdvancedFiltersChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFF0FDF4) : Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? const Color(0xFF86EFAC) : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: selected ? const Color(0xFF15803D) : AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? const Color(0xFF166534)
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _dateRangeLabel(BuildContext context, _TxFilters filters) {
  final l10n = context.l10n;
  final from = filters.from;
  final to = filters.to;
  if (from != null && to != null) {
    return '${AppDateFormatter.shortDate(from)} - ${AppDateFormatter.shortDate(to)}';
  }
  if (from != null) {
    return '${l10n.txFilterDateFrom} ${AppDateFormatter.shortDate(from)}';
  }
  if (to != null) {
    return '${l10n.txFilterDateTo} ${AppDateFormatter.shortDate(to)}';
  }
  return l10n.txFilterCustomRange;
}

String _advancedFilterLabel(BuildContext context, _TxFilters filters) {
  final l10n = context.l10n;
  final hasCategory = filters.categoryId != null;
  final hasAmount = filters.minAmount != null || filters.maxAmount != null;
  if (hasCategory && !hasAmount) {
    return filters.categoryLabel ?? l10n.txFilterCategory;
  }
  if (!hasCategory && hasAmount) return 'Monto';
  if (hasCategory && hasAmount) return 'Categoria + monto';
  return l10n.txFilterAdvanced;
}

Future<void> _showDateRangeSheet(
  BuildContext context,
  WidgetRef ref,
  _TxFilters filters,
) async {
  final l10n = context.l10n;
  DateTime? from = filters.from;
  DateTime? to = filters.to;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          Future<void> pickDate({required bool isFrom}) async {
            final now = DateTime.now();
            final current = isFrom ? from : to;
            final fallback = current ?? (isFrom ? to : from) ?? now;
            final picked = await showDatePicker(
              context: context,
              initialDate: fallback,
              firstDate: DateTime(now.year - 5),
              lastDate: DateTime(now.year + 1, 12, 31),
            );
            if (picked == null) return;
            setState(() {
              if (isFrom) {
                from = picked;
                if (to != null && picked.isAfter(to!)) {
                  to = picked;
                }
              } else {
                to = picked;
                if (from != null && picked.isBefore(from!)) {
                  from = picked;
                }
              }
            });
          }

          void apply() {
            ref
                .read(_txFiltersProvider.notifier)
                .update(
                  filters.copyWith(
                    from: from,
                    to: to,
                    clearFrom: from == null,
                    clearTo: to == null,
                  ),
                );
            Navigator.of(sheetContext).pop();
          }

          void clearDates() {
            ref.read(_txFiltersProvider.notifier).update(filters.clearDates());
            Navigator.of(sheetContext).pop();
          }

          return SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.txFilterCustomRange,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).closeButtonTooltip,
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.txFilterDateFrom,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDateField(
                    value: from,
                    placeholder: l10n.txFilterDateFrom,
                    onTap: () => pickDate(isFrom: true),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l10n.txFilterDateTo,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppDateField(
                    value: to,
                    placeholder: l10n.txFilterDateTo,
                    onTap: () => pickDate(isFrom: false),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: clearDates,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.textMuted,
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.txFilterClearDates),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: apply,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(l10n.txFilterApply),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _showAdvancedFiltersSheet(
  BuildContext context,
  WidgetRef ref,
  _TxFilters filters,
) async {
  final l10n = context.l10n;
  String? categoryId = filters.categoryId;
  String? categoryLabel = filters.categoryLabel;
  final minController = TextEditingController(
    text: filters.minAmount?.toStringAsFixed(2) ?? '',
  );
  final maxController = TextEditingController(
    text: filters.maxAmount?.toStringAsFixed(2) ?? '',
  );

  double? parseAmount(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            void apply() {
              final minText = minController.text.trim();
              final maxText = maxController.text.trim();
              final minAmount = parseAmount(minText);
              final maxAmount = parseAmount(maxText);
              if ((minText.isNotEmpty && minAmount == null) ||
                  (maxText.isNotEmpty && maxAmount == null) ||
                  (minAmount != null && minAmount < 0) ||
                  (maxAmount != null && maxAmount < 0)) {
                setState(() {
                  errorText = 'Ingresa montos validos mayores o iguales a 0.';
                });
                return;
              }
              if (minAmount != null &&
                  maxAmount != null &&
                  minAmount > maxAmount) {
                setState(() {
                  errorText =
                      'El monto minimo no puede ser mayor que el maximo.';
                });
                return;
              }

              ref
                  .read(_txFiltersProvider.notifier)
                  .update(
                    filters.copyWith(
                      categoryId: categoryId,
                      categoryLabel: categoryLabel,
                      minAmount: minAmount,
                      maxAmount: maxAmount,
                      clearCategory: categoryId == null,
                      clearMinAmount: minAmount == null,
                      clearMaxAmount: maxAmount == null,
                    ),
                  );
              Navigator.of(sheetContext).pop();
            }

            void clearAdvanced() {
              ref
                  .read(_txFiltersProvider.notifier)
                  .update(filters.clearAdvanced());
              Navigator.of(sheetContext).pop();
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  20 + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.txFilterAdvanced,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: MaterialLocalizations.of(
                              context,
                            ).closeButtonTooltip,
                            onPressed: () => Navigator.of(sheetContext).pop(),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.txFilterCategory,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Consumer(
                        builder: (context, ref, _) {
                          final categoriesAsync = ref.watch(
                            _txCategoriesProvider,
                          );
                          return categoriesAsync.when(
                            loading: () => const SizedBox(
                              height: 56,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, _) => OutlinedButton.icon(
                              onPressed: () =>
                                  ref.invalidate(_txCategoriesProvider),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('Reintentar categorias'),
                            ),
                            data: (categories) {
                              return CategoryDropdownField<String?>(
                                value: categoryId,
                                hintText: l10n.txFilterAllCategories,
                                sheetTitle: l10n.txFilterCategory,
                                onChanged: (id) {
                                  setState(() {
                                    categoryId = id;
                                    CategoryModel? selected;
                                    for (final c in categories) {
                                      if (c.id == id) {
                                        selected = c;
                                        break;
                                      }
                                    }
                                    categoryLabel = selected == null
                                        ? null
                                        : CategoryUtils.labelEs(selected.name);
                                  });
                                },
                                options: [
                                  CategoryOption<String?>(
                                    value: null,
                                    label: l10n.txFilterAllCategories,
                                    icon: Icons.grid_view_rounded,
                                  ),
                                  for (final c in categories)
                                    CategoryOption<String?>(
                                      value: c.id,
                                      label: CategoryUtils.labelEs(c.name),
                                      icon: CategoryUtils.iconForCategory(
                                        c.name,
                                        iconKey: c.icon,
                                        isCustom: c.isCustom,
                                      ),
                                      iconColor:
                                          CategoryUtils.iconColorForCategory(
                                            c.name,
                                          ),
                                      bgColor: CategoryUtils.bgColorForCategory(
                                        c.name,
                                      ),
                                    ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: minController,
                              labelText: l10n.txFilterMinAmount,
                              prefixText: 'S/ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppTextField(
                              controller: maxController,
                              labelText: l10n.txFilterMaxAmount,
                              prefixText: 'S/ ',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (errorText != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          errorText!,
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: clearAdvanced,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                foregroundColor: AppColors.textMuted,
                                side: const BorderSide(color: AppColors.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(l10n.txFilterClear),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton(
                              onPressed: apply,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(l10n.txFilterApply),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  } finally {
    minController.dispose();
    maxController.dispose();
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
    final account = tx['account'] as Map<String, dynamic>?;
    final toAccount = tx['toAccount'] as Map<String, dynamic>?;
    final accountName = account?['name'] as String?;
    final toAccountName = toAccount?['name'] as String?;

    DateTime? parsedDate;
    if (occurredAt != null) {
      parsedDate = DateTime.tryParse(occurredAt)?.toLocal();
    }

    final normalizedType = type.toLowerCase();
    final isIncome = normalizedType == 'income';
    final isTransfer = normalizedType == 'transfer';
    final amountColor = isTransfer
        ? const Color(0xFF2563EB)
        : isIncome
        ? AppColors.income
        : AppColors.danger;
    final amountSign = isTransfer ? '' : (isIncome ? '+' : '-');
    final bgColor = isTransfer
        ? const Color(0xFFEFF6FF)
        : CategoryUtils.bgColorForCategory(categoryName, isIncome: isIncome);
    final iconColor = isTransfer
        ? const Color(0xFF2563EB)
        : CategoryUtils.iconColorForCategory(categoryName, isIncome: isIncome);

    final displayLabel = isTransfer
        ? (description.isNotEmpty ? description : 'Transferencia')
        : (description.isNotEmpty
              ? description
              : CategoryUtils.labelEs(categoryName));
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
    final transferAccounts = [
      accountName,
      toAccountName,
    ].whereType<String>().join(' → ');
    final categoryDisplay = isTransfer
        ? transferAccounts
        : CategoryUtils.labelEs(categoryName);
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
                isTransfer
                    ? Icons.swap_horiz_rounded
                    : CategoryUtils.iconForCategory(
                        categoryName,
                        iconKey: categoryIconKey,
                      ),
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
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
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
