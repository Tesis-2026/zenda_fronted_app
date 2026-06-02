import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'app_primary_button.dart';
import 'app_sheet_container.dart';
import 'sheet_header.dart';

/// Opens a bottom-sheet month/year picker and resolves to the chosen period
/// (or `null` if dismissed). Pairs with an [AppDateField] period field so the
/// budget sheet can show a single "May 2026" field instead of two dropdowns.
Future<({int month, int year})?> showMonthYearPicker(
  BuildContext context, {
  required int initialMonth,
  required int initialYear,
  required String title,
  required String confirmLabel,
}) {
  return showModalBottomSheet<({int month, int year})>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _MonthYearPicker(
      initialMonth: initialMonth,
      initialYear: initialYear,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

class _MonthYearPicker extends StatefulWidget {
  const _MonthYearPicker({
    required this.initialMonth,
    required this.initialYear,
    required this.title,
    required this.confirmLabel,
  });

  final int initialMonth;
  final int initialYear;
  final String title;
  final String confirmLabel;

  @override
  State<_MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<_MonthYearPicker> {
  late int _month = widget.initialMonth;
  late int _year = widget.initialYear;

  InputDecoration get _decoration => InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return AppSheetContainer(
      topRadius: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: widget.title,
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  // ignore: deprecated_member_use
                  value: _month,
                  isExpanded: true,
                  decoration: _decoration,
                  items: List.generate(12, (i) {
                    final label =
                        DateFormat('MMMM', 'es').format(DateTime(2020, i + 1));
                    return DropdownMenuItem(value: i + 1, child: Text(label));
                  }),
                  onChanged: (v) => setState(() => _month = v ?? _month),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<int>(
                  // ignore: deprecated_member_use
                  value: _year,
                  isExpanded: true,
                  decoration: _decoration,
                  items: List.generate(5, (i) {
                    final y = currentYear + i - 1;
                    return DropdownMenuItem(value: y, child: Text('$y'));
                  }),
                  onChanged: (v) => setState(() => _year = v ?? _year),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            label: widget.confirmLabel,
            onPressed: () =>
                Navigator.of(context).pop((month: _month, year: _year)),
          ),
        ],
      ),
    );
  }
}
