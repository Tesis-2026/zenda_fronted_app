import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/transaction.dart';
import '../../core/utils/category_utils.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_date_field.dart';
import '../../core/widgets/app_form_sheet.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/category_dropdown_field.dart';
import '../../core/widgets/category_selector.dart';
import '../../core/widgets/field_label.dart';
import '../../core/widgets/kind_toggle.dart';
import '../../l10n/l10n_extension.dart';

/// Edit-transaction bottom sheet built on the standard [showAppFormSheet].
/// Open it with [show]; resolves to `true` when the edit was saved.
class EditTransactionScreen {
  const EditTransactionScreen._();

  static Future<bool?> show(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final l10n = context.l10n;
    final key = GlobalKey<_EditTransactionBodyState>();
    return showAppFormSheet(
      context,
      title: l10n.txEditTitle,
      primaryLabel: l10n.txUpdateButton,
      body: _EditTransactionBody(key: key, transaction: transaction),
      onSubmit: () => key.currentState?.submit() ?? Future.value(false),
    );
  }
}

class _EditTransactionBody extends ConsumerStatefulWidget {
  const _EditTransactionBody({super.key, required this.transaction});

  final Map<String, dynamic> transaction;

  @override
  ConsumerState<_EditTransactionBody> createState() =>
      _EditTransactionBodyState();
}

class _EditTransactionBodyState extends ConsumerState<_EditTransactionBody> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late TransactionKind _kind;
  late TransactionCategory _category;
  late DateTime _date;

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
    _amountController = TextEditingController(text: amount.toStringAsFixed(2));
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

  /// Validates and persists the edit. Returns `true` to close the sheet.
  Future<bool> submit() async {
    final l10n = context.l10n;
    final id = widget.transaction['id'] as String? ?? '';
    if (id.isEmpty) return false;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      showAppToast(context, l10n.errorTxInvalidAmount, type: ToastType.error);
      return false;
    }

    try {
      await ref.read(transactionApiServiceProvider).update(
            id: id,
            kind: _kind,
            amount: amount,
            category: _category,
            occurredAt: _date,
            description: _noteController.text.trim(),
          );
      return true;
    } catch (_) {
      if (mounted) {
        showAppToast(context, l10n.errorTxSaveFailed, type: ToastType.error);
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KindToggle(
          selected: _kind,
          onChanged: (k) => setState(() => _kind = k),
          expenseLabel: l10n.txExpense,
          incomeLabel: l10n.txIncome,
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.txAmountLabel),
        const SizedBox(height: 6),
        AmountInputField(controller: _amountController),
        const SizedBox(height: 16),
        FieldLabel(l10n.txNoteLabel),
        const SizedBox(height: 6),
        AppTextField(controller: _noteController),
        const SizedBox(height: 16),
        FieldLabel(l10n.txDateLabel),
        const SizedBox(height: 6),
        AppDateField(
          value: _date,
          onTap: () => _pickDate(context),
        ),
        const SizedBox(height: 16),
        FieldLabel(l10n.txCategoryLabel),
        const SizedBox(height: 8),
        CategoryDropdownField<TransactionCategory>(
          value: _category,
          hintText: l10n.categorySelectHint,
          sheetTitle: l10n.txCategoryLabel,
          onChanged: (c) => setState(() => _category = c),
          options: [
            for (final c in TransactionCategory.values)
              CategoryOption<TransactionCategory>(
                value: c,
                label: CategorySelector.labelFor(context, c),
                icon: CategoryUtils.iconForCategory(c.name),
              ),
          ],
        ),
      ],
    );
  }
}
