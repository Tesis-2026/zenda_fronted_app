import 'package:flutter/material.dart';

import '../models/transaction.dart';

class KindToggle extends StatelessWidget {
  const KindToggle({
    super.key,
    required this.selected,
    required this.onChanged,
    required this.expenseLabel,
    required this.incomeLabel,
  });

  final TransactionKind selected;
  final ValueChanged<TransactionKind> onChanged;
  final String expenseLabel;
  final String incomeLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(TransactionKind.expense),
            child: _KindChip(
              label: expenseLabel,
              isSelected: selected == TransactionKind.expense,
              activeColor: const Color(0xFFEF4444),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(TransactionKind.income),
            child: _KindChip(
              label: incomeLabel,
              isSelected: selected == TransactionKind.income,
              activeColor: const Color(0xFF34D399),
            ),
          ),
        ),
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
