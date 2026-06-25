import 'package:flutter/material.dart';

import '../models/transaction.dart';

class KindToggle extends StatelessWidget {
  const KindToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.expenseLabel,
    required this.incomeLabel,
    this.transferLabel,
  });

  final TransactionKind selected;
  final ValueChanged<TransactionKind> onChanged;
  final String expenseLabel;
  final String incomeLabel;
  final String? transferLabel;

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        kind: TransactionKind.expense,
        label: expenseLabel,
        color: const Color(0xFFEF4444),
      ),
      (
        kind: TransactionKind.income,
        label: incomeLabel,
        color: const Color(0xFF34D399),
      ),
      if (transferLabel != null)
        (
          kind: TransactionKind.transfer,
          label: transferLabel!,
          color: const Color(0xFF2563EB),
        ),
    ];

    return Row(
      children: [
        for (final option in options) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(option.kind),
              child: _KindChip(
                label: option.label,
                isSelected: selected == option.kind,
                activeColor: option.color,
              ),
            ),
          ),
          if (option != options.last) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.isSelected,
    required this.activeColor,
  });

  final String label;
  final bool isSelected;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: isSelected ? activeColor : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
            color: isSelected ? Colors.white : const Color(0xFF9CA3AF),
          ),
        ),
      ),
    );
  }
}
