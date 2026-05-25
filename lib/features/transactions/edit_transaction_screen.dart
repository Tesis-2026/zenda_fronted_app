import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';
import '../../providers/repositories_providers.dart';
import '../../l10n/l10n_extension.dart';

/// Pass the raw API map of the transaction via GoRouter `extra`.
class EditTransactionScreen extends ConsumerStatefulWidget {
  const EditTransactionScreen({super.key, required this.transaction});

  final Map<String, dynamic> transaction;

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

  static const _categories = TransactionCategory.values;

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final typeStr = (tx['type'] as String? ?? 'EXPENSE').toUpperCase();
    _kind = typeStr == 'INCOME' ? TransactionKind.income : TransactionKind.expense;

    final catName = (tx['category'] as Map<String, dynamic>?)?['name'] as String?;
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
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txEditTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.txUpdateButton),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Type selector
          SegmentedButton<TransactionKind>(
            segments: [
              ButtonSegment(
                value: TransactionKind.expense,
                label: Text(l10n.txExpense),
                icon: const Icon(Icons.arrow_downward),
              ),
              ButtonSegment(
                value: TransactionKind.income,
                label: Text(l10n.txIncome),
                icon: const Icon(Icons.arrow_upward),
              ),
            ],
            selected: {_kind},
            onSelectionChanged: (s) => setState(() => _kind = s.first),
          ),
          const SizedBox(height: 16),

          // Amount
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.txAmountLabel,
              prefixText: 'S/ ',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Category
          DropdownButtonFormField<TransactionCategory>(
            initialValue: _category,
            decoration: InputDecoration(
              labelText: l10n.txCategoryLabel,
              border: const OutlineInputBorder(),
            ),
            items: _categories
                .map((c) => DropdownMenuItem(
                      value: c,
                      child: Text(_categoryLabel(context, c)),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _category = v);
            },
          ),
          const SizedBox(height: 16),

          // Date
          InkWell(
            onTap: () async {
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
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.txDateLabel,
                border: const OutlineInputBorder(),
              ),
              child: Text(DateFormat('dd/MM/yyyy').format(_date)),
            ),
          ),
          const SizedBox(height: 16),

          // Note
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              labelText: l10n.txNoteLabel,
              hintText: l10n.txNoteHint,
              border: const OutlineInputBorder(),
            ),
          ),

          if (_saving) ...[
            const SizedBox(height: 24),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = widget.transaction['id'] as String? ?? '';
    if (id.isEmpty) return;

    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTxInvalidAmount)),
      );
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.txSaved)),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorTxSaveFailed)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
