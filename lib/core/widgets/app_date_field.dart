import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/zenda_theme_x.dart';

/// Standard tappable date/period field for create/edit sheets.
///
/// Shows an icon, the value text, and a chevron — consistent across transaction,
/// goal and budget sheets, which previously each rolled their own tile with
/// different styling/format. The caller owns the picker call inside [onTap].
///
/// Pass [value] for a calendar date (formatted in Spanish), or [displayText] to
/// render an arbitrary string (e.g. a "May 2026" budget period). [icon] lets a
/// period field use a different glyph than a single-date field.
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    this.value,
    required this.onTap,
    this.placeholder = '—',
    this.displayText,
    this.icon = Icons.calendar_today_outlined,
  });

  final DateTime? value;
  final VoidCallback onTap;
  final String placeholder;
  final String? displayText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasValue = displayText != null || value != null;
    final text = displayText ??
        (value != null
            ? DateFormat('d MMM yyyy', 'es').format(value!.toLocal())
            : placeholder);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: colors.textMuted),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: hasValue ? colors.textPrimary : colors.textSubtle,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
