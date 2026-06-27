import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../../l10n/l10n_extension.dart';

/// Spanish labels for the fixed [TransactionCategory] enum.
///
/// The category *picker* UI now lives in [CategoryDropdownField]
/// (`category_dropdown_field.dart`). This class only keeps the shared label
/// lookup used to build the dropdown options and the AI-suggestion chip, so the
/// same Spanish names are used everywhere.
abstract final class CategorySelector {
  /// Localized Spanish label for a transaction category.
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
      TransactionCategory.beca => l10n.txCategoryScholarship,
      TransactionCategory.trabajoPartTime => l10n.txCategoryPartTimeWork,
      TransactionCategory.familia => l10n.txCategoryFamilyIncome,
      TransactionCategory.freelance => l10n.txCategoryFreelance,
      TransactionCategory.otros => l10n.txCategoryOther,
    };
  }
}
