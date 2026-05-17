import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';
import '../../core/utils/category_utils.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_sheet_container.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/field_label.dart';
import '../../core/widgets/sheet_header.dart';
import '../../core/widgets/kind_toggle.dart';
import '../../l10n/l10n_extension.dart';

class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final Map<String, dynamic> transaction;

  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditTransactionScreen(transaction: transaction),
    );
  }

  @override
  ConsumerState<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends ConsumerState<EditTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionKind _kind;
  late TransactionCategory _category;
  late DateTime _date;
  bool _saving = false;


  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final typeStr = (tx['type'] as String? ?? 'expense').toLowerCase();
    _kind =
        typeStr == 'income' ? TransactionKind.income : TransactionKind.expense;

    final catName =
        (tx['category'] as Map<String, dynamic>?)?['name'] as String?;
    _category = _categoryFromApiName(catName);

    final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
    _amountController =
        TextEditingController(text: amount.toStringAsFixed(2));
    _noteController = TextEditingController(
      text: tx['description'] as String? ?? '',
    );

    final dateStr = tx['occurredAt'] as String?;
    _date = dateStr != null
        ? (DateTime.tryParse(dateStr)?.toLocal() ?? DateTime.now())
        : DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  TransactionCategory _categoryFromApiName(String? name) {
    return switch ((name ?? '').toLowerCase()) {
      'food' => TransactionCategory.comida,
      'transportation' => TransactionCategory.transporte,
      'housing' => TransactionCategory.vivienda,
      'utilities' => TransactionCategory.servicios,
      'health' => TransactionCategory.salud,
      'entertainment' => TransactionCategory.ocio,
      'shopping' => TransactionCategory.compras,
      'subscriptions' => TransactionCategory.suscripciones,
      'cravings' => TransactionCategory.antojos,
      'savings' => TransactionCategory.ahorro,
      _ => TransactionCategory.otros,
    };
  }

  String _categoryLabel(BuildContext context, TransactionCategory cat) {
    final l10n = context.l10n;
    return switch (cat) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppSheetContainer(
      topRadius: 28,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SheetHeader(
              title: l10n.txEditTitle,
              onClose: () => context.pop(),
            ),
            const SizedBox(height: 16),
            KindToggle(
              selected: _kind,
              onChanged: (k) => setState(() => _kind = k),
              expenseLabel: l10n.txExpense,
              incomeLabel: l10n.txIncome,
            ),
            const SizedBox(height: 16),
            AmountInputField(
              controller: _amountController,
              label: l10n.txAmountLabel,
            ),
            const SizedBox(height: 16),
            FieldLabel(l10n.txNoteLabel),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _noteController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 16),
            FieldLabel(l10n.txDateLabel),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMMM d, yyyy').format(_date),
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 14,
                      ),
                    ),
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: Color(0xFF9CA3AF),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FieldLabel(l10n.txCategoryLabel),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: TransactionCategory.values.map((cat) {
                  final isSelected = cat == _category;
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: Container(
                      width: 72,
                      height: 68,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFECFDF5)
                            : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(
                                color: const Color(0xFF34D399), width: 2)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            CategoryUtils.iconForCategory(cat.name),
                            size: 24,
                            color: isSelected
                                ? const Color(0xFF065F46)
                                : const Color(0xFF6B7280),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _categoryLabel(context, cat),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: isSelected
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: l10n.txUpdateButton,
              onPressed: _saving ? null : _save,
              isLoading: _saving,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _date.hour,
            _date.minute,
          ));
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = widget.transaction['id'] as String? ?? '';
    if (id.isEmpty) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showAppToast(context, l10n.errorTxInvalidAmount, type: ToastType.error);
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(transactionApiServiceProvider).update(
        id: id,
        kind: _kind,
        amount: amount,
        category: _category,
        occurredAt: _date,
        description: _noteController.text.trim(),
      );
      if (mounted) context.pop(true);
    } catch (_) {
      if (mounted) {
        showAppToast(context, l10n.errorTxSaveFailed, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
