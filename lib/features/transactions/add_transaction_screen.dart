import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../dashboard/dashboard_providers.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import 'controllers/new_transaction_controller.dart';
import '../../l10n/l10n_extension.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    ref.invalidate(newTransactionControllerProvider);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newTransactionControllerProvider);
    final controller = ref.read(newTransactionControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : Colors.black87;
    final l10n = context.l10n;

    ref.listen<NewTransactionState>(newTransactionControllerProvider, (
      prev,
      next,
    ) {
      final prevTick = prev?.saveTick ?? 0;
      if (next.saveTick != prevTick) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.txSaved)));
          Navigator.of(context).pop();
        }
      }
    });

    final accountsAsync = ref.watch(accountsProvider);

    // Keep text controllers in sync with OCR demo/autofill.
    if (state.amount != null) {
      final desired = state.amount!.toStringAsFixed(2);
      if (_amountController.text != desired) {
        _amountController.text = desired;
        _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length),
        );
      }
    }
    if (_noteController.text != state.note) {
      _noteController.text = state.note;
      _noteController.selection = TextSelection.fromPosition(
        TextPosition(offset: _noteController.text.length),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txNewTitle),
        actions: [
          TextButton.icon(
            onPressed: state.isSaving
                ? null
                : () {
                    controller.fillFromOcrDemo();
                  },
            icon: const Icon(Icons.document_scanner_rounded),
            label: Text(l10n.txScanReceipt),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(l10n.txErrorPrefix(e.toString()))),
          data: (accounts) {
            final from = _findAccount(accounts, state.fromAccountId);
            final to = _findAccount(accounts, state.toAccountId);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<TransactionKind>(
                          segments: [
                            ButtonSegment(
                              value: TransactionKind.expense,
                              label: Text(l10n.txExpense),
                              icon: const Icon(Icons.arrow_upward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionKind.income,
                              label: Text(l10n.txIncome),
                              icon: const Icon(Icons.arrow_downward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionKind.transfer,
                              label: Text(l10n.txTransfer),
                              icon: const Icon(Icons.swap_horiz_rounded),
                            ),
                          ],
                          selected: {state.kind},
                          onSelectionChanged: (sel) {
                            controller.setKind(sel.first);
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          l10n.txAccountLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AccountPicker(
                          label: l10n.txSourceLabel,
                          accounts: accounts,
                          selected: from,
                          onChanged: (id) => controller.setFromAccount(id),
                        ),
                        if (state.kind == TransactionKind.transfer) ...[
                          const SizedBox(height: 12),
                          _AccountPicker(
                            label: l10n.txDestLabel,
                            accounts: accounts,
                            selected: to,
                            onChanged: (id) => controller.setToAccount(id),
                          ),
                        ],

                        const SizedBox(height: 18),
                        Text(
                          l10n.txAmountLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'S/ ',
                            hintText: l10n.txAmountHint,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: controller.setAmountFromText,
                        ),

                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.txCategoryLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
                                ),
                              ),
                            ),
                            if (state.bucket != null)
                              _BucketChip(bucket: state.bucket!),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _CategoryGrid(
                          selected: state.category,
                          onSelected: controller.setCategory,
                        ),

                        const SizedBox(height: 18),
                        Text(
                          l10n.txNoteLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: l10n.txNoteHint,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: controller.setNote,
                        ),

                        const SizedBox(height: 18),
                        Text(
                          l10n.txDateLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DatePickerTile(
                          date: state.date,
                          onPick: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: state.date,
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (picked != null) controller.setDate(picked);
                          },
                        ),

                        if (state.error != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            state.error!,
                            style: const TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 16,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: state.isSaving
                            ? null
                            : () async {
                                await controller.save();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34D399),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state.isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.txSaveButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Account? _findAccount(List<Account> accounts, String? id) {
    if (id == null) return null;
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }
}

class _AccountPicker extends StatelessWidget {
  final String label;
  final List<Account> accounts;
  final Account? selected;
  final ValueChanged<String?> onChanged;

  const _AccountPicker({
    required this.label,
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      value: selected?.id,
      items: accounts
          .map(
            (a) => DropdownMenuItem(
              value: a.id,
              child: Row(
                children: [
                  Icon(a.iconData, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    a.type == AccountType.credit
                        ? 'Deuda: S/ ${a.creditDebt.toStringAsFixed(0)}'
                        : 'S/ ${a.balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPick;

  const _DatePickerTile({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = DateFormat('EEE d MMM, yyyy', 'es').format(date);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _BucketChip extends StatelessWidget {
  final Bucket503020 bucket;
  const _BucketChip({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (bucket) {
      Bucket503020.necesidad => (l10n.txNeed, const Color(0xFF34D399)),
      Bucket503020.deseo => (l10n.txWant, const Color(0xFFC084FC)),
      Bucket503020.ahorro => (l10n.txSavingBucket, const Color(0xFFFCD34D)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;

  const _CategoryGrid({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final items = TransactionCategory.values;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.25,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final c = items[index];
        final isSelected = c == selected;
        final icon = _categoryIcon(c);
        final label = _categoryLabel(c, l10n);
        return InkWell(
          onTap: () => onSelected(c),
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF34D399).withOpacity(0.18)
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF34D399)
                    : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _categoryIcon(TransactionCategory c) {
    return switch (c) {
      TransactionCategory.comida => Icons.restaurant_rounded,
      TransactionCategory.transporte => Icons.directions_car_rounded,
      TransactionCategory.vivienda => Icons.home_rounded,
      TransactionCategory.servicios => Icons.lightbulb_rounded,
      TransactionCategory.salud => Icons.health_and_safety_rounded,
      TransactionCategory.ocio => Icons.movie_rounded,
      TransactionCategory.compras => Icons.shopping_bag_rounded,
      TransactionCategory.suscripciones => Icons.subscriptions_rounded,
      TransactionCategory.antojos => Icons.icecream_rounded,
      TransactionCategory.ahorro => Icons.savings_rounded,
      TransactionCategory.otros => Icons.category_rounded,
    };
  }

  String _categoryLabel(TransactionCategory c, dynamic l10n) {
    return switch (c) {
      TransactionCategory.comida => l10n.txCategoryFood,
      TransactionCategory.transporte => l10n.txCategoryTransport,
      TransactionCategory.vivienda => l10n.txCategoryHousing,
      TransactionCategory.servicios => l10n.txCategoryUtilities,
      TransactionCategory.salud => l10n.txCategoryHealth,
      TransactionCategory.ocio => l10n.txCategoryEntertainment,
      TransactionCategory.compras => l10n.txCategoryShopping,
      TransactionCategory.suscripciones => l10n.txCategorySubscriptions,
      TransactionCategory.antojos => l10n.txCategoryCravings,
      TransactionCategory.ahorro => l10n.txCategorySavings,
      TransactionCategory.otros => l10n.txCategoryOther,
    };
  }
}
