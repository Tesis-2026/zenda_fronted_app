import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../theme/zenda_theme_x.dart';
import '../utils/category_utils.dart';
import '../../l10n/l10n_extension.dart';

/// One selectable cell in a [CategoryGrid].
class CategoryGridItem {
  const CategoryGridItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
}

/// Shared 4-column grid of category chips. Used by [CategorySelector] (the
/// fixed transaction enum) AND by the budget sheet (backend categories) so
/// every category picker in the app looks identical.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.items});

  final List<CategoryGridItem> items;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 4;
        const spacing = 8.0;
        final itemWidth =
            (constraints.maxWidth - spacing * (crossAxisCount - 1)) /
                crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: itemWidth,
                height: itemWidth / 1.1,
                child: _CategoryChip(item: item),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.item});

  final CategoryGridItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: item.selected
              ? const Color(0xFF34D399).withValues(alpha: 0.18)
              : colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.selected ? const Color(0xFF34D399) : colors.border,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(item.icon, size: 22),
            const SizedBox(height: 6),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: item.selected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard category picker for transaction create/edit sheets — the fixed
/// [TransactionCategory] enum rendered through the shared [CategoryGrid].
class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;

  /// Localized Spanish label for a category. Shared so the AI-suggestion chip
  /// and any other caller use the same names.
  static String labelFor(BuildContext context, TransactionCategory c) {
    final l10n = context.l10n;
    return switch (c) {
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
    return CategoryGrid(
      items: [
        for (final c in TransactionCategory.values)
          CategoryGridItem(
            icon: CategoryUtils.iconForCategory(c.name),
            label: labelFor(context, c),
            selected: c == selected,
            onTap: () => onSelected(c),
          ),
      ],
    );
  }
}
