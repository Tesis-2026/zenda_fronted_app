import 'package:flutter/material.dart';

import '../../l10n/l10n_extension.dart';

class MonthNavigator extends StatelessWidget {
  const MonthNavigator({
    super.key,
    required this.label,
    required this.onPrev,
    required this.onNext,
    this.trailing,
  });

  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: context.l10n.commonPreviousPeriod,
          onPressed: onPrev,
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          color: const Color(0xFF6B7280),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        IconButton(
          tooltip: context.l10n.commonNextPeriod,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          color: const Color(0xFF6B7280),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}
