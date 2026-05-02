import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';
import '../../core/services/transaction_api_service.dart';
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
  bool _deleting = false;

  static const _categoryEmojis = {
    TransactionCategory.comida: '🍔',
    TransactionCategory.transporte: '🚌',
    TransactionCategory.vivienda: '🏠',
    TransactionCategory.servicios: '⚡',
    TransactionCategory.salud: '💊',
    TransactionCategory.ocio: '🎮',
    TransactionCategory.compras: '🛒',
    TransactionCategory.suscripciones: '📱',
    TransactionCategory.antojos: '🍩',
    TransactionCategory.ahorro: '💰',
    TransactionCategory.otros: '📋',
  };

  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    final typeStr = (tx['type'] as String? ?? 'EXPENSE').toUpperCase();
    _kind =
        typeStr == 'INCOME' ? TransactionKind.income : TransactionKind.expense;

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
    final busy = _saving || _deleting;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.txEditTitle,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  GestureDetector(
                    onTap: busy ? null : _confirmDelete,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Center(
                        child: Text(
                          '🗑  ${l10n.txDeleteAction}',
                          style: const TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Expense / Income toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _kind = TransactionKind.expense),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _kind == TransactionKind.expense
                              ? const Color(0xFFEF4444)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            l10n.txExpense,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _kind == TransactionKind.expense
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: _kind == TransactionKind.expense
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _kind = TransactionKind.income),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: _kind == TransactionKind.income
                              ? const Color(0xFF34D399)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            l10n.txIncome,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _kind == TransactionKind.income
                                  ? FontWeight.w700
                                  : FontWeight.normal,
                              color: _kind == TransactionKind.income
                                  ? Colors.white
                                  : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Amount dark card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.txAmountLabel,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        prefixText: 'S/ ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Note
              _FieldLabel(label: l10n.txNoteLabel),
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

              // Date
              _FieldLabel(label: l10n.txDateLabel),
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
                      const Text(
                        '📅',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category
              _FieldLabel(label: l10n.txCategoryLabel),
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
                            Text(
                              _categoryEmojis[cat] ?? '📋',
                              style: const TextStyle(fontSize: 24),
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

              // Save button
              GestureDetector(
                onTap: busy ? null : _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: busy
                        ? const Color(0xFF34D399).withValues(alpha: 0.5)
                        : const Color(0xFF34D399),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            l10n.txUpdateButton,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
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

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.txDeleteConfirmTitle),
        content: Text(l10n.txDeleteConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444)),
            child: Text(l10n.txDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final id = widget.transaction['id'] as String? ?? '';
    if (id.isEmpty) return;

    setState(() => _deleting = true);
    try {
      await TransactionApiService().deleteTransaction(id);
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.txDeleteError)),
        );
      }
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = widget.transaction['id'] as String? ?? '';
    if (id.isEmpty) return;

    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorTxInvalidAmount)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await TransactionApiService().update(
        id: id,
        kind: _kind,
        amount: amount,
        category: _category,
        occurredAt: _date,
        description: _noteController.text.trim(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
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

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
