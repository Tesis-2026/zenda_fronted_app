import 'package:flutter/material.dart';

import '../theme/zenda_theme_x.dart';
import 'app_sheet_container.dart';
import 'sheet_header.dart';

/// One selectable option in a [CategoryDropdownField] / [showCategoryPicker].
///
/// Generic over [T] so it can carry the fixed transaction enum, a backend
/// category id (`String`), `null` (e.g. the budget "all categories" choice), or
/// anything else the caller selects by.
class CategoryOption<T> {
  const CategoryOption({
    required this.value,
    required this.label,
    required this.icon,
    this.iconColor,
    this.bgColor,
    this.trailing,
  });

  final T value;
  final String label;
  final IconData icon;

  /// Optional accent colors for the icon. When omitted the picker falls back to
  /// neutral grays so unconfigured categories still read as tidy, bordered rows.
  final Color? iconColor;
  final Color? bgColor;

  /// Optional trailing text shown at the right of the picker row (e.g. a
  /// budget's available amount). Not shown on the collapsed field.
  final String? trailing;
}

/// Standard bordered category picker for create/edit sheets.
///
/// Renders a single tappable field — icon + selected label + chevron — that
/// opens a bottom-sheet list of [options], mirroring [AppDateField] so every
/// form reads the same way. It replaces the old grid of chips that grew
/// cluttered once there were many categories.
///
/// Data-source agnostic: the caller builds [options], so it works identically
/// against the real backend and the demo mocks.
class CategoryDropdownField<T> extends StatelessWidget {
  const CategoryDropdownField({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.hintText,
    required this.sheetTitle,
  });

  /// The currently selected value. May be `null` either because nothing is
  /// selected yet or because `null` is itself a valid option (e.g. "all").
  final T? value;
  final List<CategoryOption<T>> options;
  final ValueChanged<T> onChanged;

  /// Shown when no option matches [value].
  final String hintText;

  /// Title of the selection bottom sheet.
  final String sheetTitle;

  CategoryOption<T>? get _selected {
    for (final o in options) {
      if (o.value == value) return o;
    }
    return null;
  }

  Future<void> _openPicker(BuildContext context) async {
    final chosen = await showCategoryPicker<T>(
      context,
      title: sheetTitle,
      options: options,
      selected: value,
    );
    // A non-null result means a row was tapped; its value may itself be null
    // (a valid "all categories" choice), so we forward it as-is.
    if (chosen != null) onChanged(chosen.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = _selected;
    final hasValue = selected != null;

    return InkWell(
      onTap: options.isEmpty ? null : () => _openPicker(context),
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
            Icon(
              hasValue ? selected.icon : Icons.category_outlined,
              size: 18,
              color: hasValue
                  ? (selected.iconColor ?? colors.textMuted)
                  : colors.textMuted,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                hasValue ? selected.label : hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: hasValue ? colors.textPrimary : colors.textSubtle,
                ),
              ),
            ),
            Icon(Icons.expand_more_rounded, size: 20, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}

/// Opens the category selection bottom sheet and resolves to the chosen option
/// (or `null` if dismissed). Returning the whole option — not just its value —
/// lets a valid `null` value be distinguished from a dismissal.
Future<CategoryOption<T>?> showCategoryPicker<T>(
  BuildContext context, {
  required String title,
  required List<CategoryOption<T>> options,
  required T? selected,
}) {
  return showModalBottomSheet<CategoryOption<T>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _CategoryPickerSheet<T>(
      title: title,
      options: options,
      selected: selected,
    ),
  );
}

class _CategoryPickerSheet<T> extends StatelessWidget {
  const _CategoryPickerSheet({
    required this.title,
    required this.options,
    required this.selected,
  });

  final String title;
  final List<CategoryOption<T>> options;
  final T? selected;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.7;
    return AppSheetContainer(
      topRadius: 28,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetHeader(
            title: title,
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final o in options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _CategoryPickerTile<T>(
                        option: o,
                        selected: o.value == selected,
                        onTap: () => Navigator.of(context).pop(o),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerTile<T> extends StatelessWidget {
  const _CategoryPickerTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CategoryOption<T> option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF34D399);
    final bg = option.bgColor ?? const Color(0xFFF3F4F6);
    final fg = option.iconColor ?? const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.10) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE5E7EB),
            width: selected ? 1.5 : 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, size: 20, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            if (option.trailing != null) ...[
              const SizedBox(width: 8),
              Text(
                option.trailing!,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
            ],
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle_rounded, size: 20, color: accent),
            ],
          ],
        ),
      ),
    );
  }
}
