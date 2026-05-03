import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/transaction.dart';
import '../../l10n/l10n_extension.dart';

class TransactionSavedScreen extends StatelessWidget {
  final double amount;
  final String categoryName;
  final DateTime date;
  final TransactionKind kind;
  final double? budgetSpent;
  final double? budgetLimit;

  const TransactionSavedScreen({
    super.key,
    required this.amount,
    required this.categoryName,
    required this.date,
    required this.kind,
    this.budgetSpent,
    this.budgetLimit,
  });

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  String _formattedDate() =>
      '${_months[date.month - 1]} ${date.day}, ${date.year}';

  String _formattedAmount() {
    final sign = kind == TransactionKind.income ? '+ S/' : '- S/';
    return '$sign ${amount.toStringAsFixed(2)}';
  }

  Color _amountColor() =>
      kind == TransactionKind.income
          ? const Color(0xFF059669)
          : const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF34D399).withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 48,
                  color: Color(0xFF34D399),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.txSavedTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.txSavedBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor),
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: l10n.txSavedLabelAmount,
                      value: _formattedAmount(),
                      valueColor: _amountColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _SummaryRow(
                      label: l10n.txSavedLabelCategory,
                      value: categoryName,
                    ),
                    Divider(height: 1, color: Theme.of(context).dividerColor),
                    _SummaryRow(
                      label: l10n.txSavedLabelDate,
                      value: _formattedDate(),
                    ),
                    if (budgetSpent != null && budgetLimit != null) ...[
                      Divider(height: 1, color: Theme.of(context).dividerColor),
                      _SummaryRow(
                        label: l10n.txSavedLabelBudget,
                        value: 'S/ ${budgetSpent!.toStringAsFixed(0)} / S/ ${budgetLimit!.toStringAsFixed(0)}',
                        valueColor: budgetSpent! >= budgetLimit!
                            ? const Color(0xFFEF4444)
                            : const Color(0xFF34D399),
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: () => context.go('/transactions'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28)),
                  ),
                  child: Text(
                    l10n.txSavedBackButton,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go('/add-transaction'),
                child: Text(
                  l10n.txSavedAddAnother,
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final FontWeight? fontWeight;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: fontWeight,
                ),
          ),
        ],
      ),
    );
  }
}
