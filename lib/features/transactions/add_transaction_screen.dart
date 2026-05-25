import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/models/transaction.dart';
import '../../core/services/transaction_api_service.dart' show categoryToApiName;
import '../../core/utils/category_utils.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/kind_toggle.dart';
import '../../core/widgets/sheet_header.dart';
import '../../core/theme/zenda_theme_x.dart';
import 'controllers/new_transaction_controller.dart';
import '../../l10n/l10n_extension.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key, this.isSheet = false});

  final bool isSheet;

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionScreen(isSheet: true),
    );
  }

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  Timer? _classifyDebounce;
  TransactionCategory? _aiSuggestion;
  bool _isClassifying = false;

  @override
  void dispose() {
    _classifyDebounce?.cancel();
    ref.invalidate(newTransactionControllerProvider);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onNoteChanged(String note, double? amount) {
    _classifyDebounce?.cancel();
    if (note.trim().length < 3 || amount == null || amount <= 0) {
      if (_aiSuggestion != null) setState(() => _aiSuggestion = null);
      return;
    }
    _classifyDebounce = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      setState(() => _isClassifying = true);
      final result = await ref
          .read(transactionApiServiceProvider)
          .classify(description: note.trim(), amount: amount);
      if (!mounted) return;
      // Persist the suggestion on the controller regardless of whether
      // the user later accepts it. The backend uses it on save() to
      // derive `categorySource = AI / AI_OVERRIDDEN / USER`.
      if (result != null) {
        ref
            .read(newTransactionControllerProvider.notifier)
            .recordAiSuggestion(result.categoryName, result.confidence);
      }
      setState(() {
        _aiSuggestion = result?.category;
        _isClassifying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newTransactionControllerProvider);
    final controller = ref.read(newTransactionControllerProvider.notifier);
    final colors = context.colors;
    final l10n = context.l10n;

    ref.listen<NewTransactionState>(newTransactionControllerProvider, (
      prev,
      next,
    ) {
      final prevTick = prev?.saveTick ?? 0;
      if (next.saveTick != prevTick) {
        if (!context.mounted) return;
        final savedExtra = {
          'amount': next.amount ?? 0.0,
          'categoryName': next.category != null
              ? categoryToApiName(next.category!)
              : 'Other',
          'date': next.date,
          'kind': next.kind,
        };

        if (next.completedChallengeNames.isNotEmpty) {
          // Show celebration dialog; navigate to saved screen after dismiss.
          _showChallengeCompletedDialog(
            context,
            next.completedChallengeNames,
            l10n,
          ).then((_) {
            if (context.mounted) {
              context.go('/transaction-saved', extra: savedExtra);
            }
          });
        } else {
          context.go('/transaction-saved', extra: savedExtra);
        }

        // Show budget alert after pop so it appears on the previous screen.
        if (next.budgetAlert != null) {
          final categoryName = next.budgetAlert!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              showAppToast(
                context,
                l10n.txBudgetAlert80(categoryName, '80'),
                type: ToastType.warning,
              );
            }
          });
        }

        // Show spending anomaly alert (US-016) after pop.
        if (next.anomalyAlert != null) {
          final categoryName = next.anomalyAlert!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              showAppToast(
                context,
                l10n.txAnomalyAlert(categoryName),
                type: ToastType.error,
              );
            }
          });
        }
      }
    });

    // Keep text controllers in sync with OCR demo/autofill.
    if (state.amount != null) {
      final desired = state.amount!.toStringAsFixed(2);
      if (_amountController.text != desired) {
        _amountController.text = desired;
        _amountController.selection = TextSelection.fromPosition(
          TextPosition(offset: _amountController.text.length),
        );
      }
    }
    if (_noteController.text != state.note) {
      _noteController.text = state.note;
      _noteController.selection = TextSelection.fromPosition(
        TextPosition(offset: _noteController.text.length),
      );
    }

    final formContent = Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expense / Income 2-tab toggle
                    KindToggle(
                      selected: state.kind,
                      onChanged: controller.setKind,
                      expenseLabel: l10n.txExpense,
                      incomeLabel: l10n.txIncome,
                    ),
                    const SizedBox(height: 16),

                    // Amount input
                    AmountInputField(
                      controller: _amountController,
                      label: l10n.txAmountLabel,
                      onChanged: controller.setAmountFromText,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 18),

                    // Note
                    Text(
                      l10n.txNoteLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      controller: _noteController,
                      hintText: l10n.txNoteHint,
                      textInputAction: TextInputAction.done,
                      onChanged: (val) {
                        controller.setNote(val);
                        _onNoteChanged(val, state.amount);
                      },
                    ),

                    if (_isClassifying || _aiSuggestion != null) ...[
                      const SizedBox(height: 10),
                      _AiSuggestionChip(
                        category: _aiSuggestion,
                        isLoading: _isClassifying,
                        onApply: _aiSuggestion != null
                            ? () {
                                controller.setCategory(_aiSuggestion!);
                                setState(() => _aiSuggestion = null);
                              }
                            : null,
                      ),
                    ],

                    const SizedBox(height: 18),
                    Text(
                      l10n.txDateLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _DatePickerTile(
                      date: state.date,
                      onPick: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: state.date,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365),
                          ),
                        );
                        if (picked != null) controller.setDate(picked);
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.txCategoryLabel,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        if (state.bucket != null)
                          _BucketChip(bucket: state.bucket!),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _CategoryGrid(
                      selected: state.category,
                      onSelected: controller.setCategory,
                    ),

                    if (state.error != null) ...[
                      const SizedBox(height: 14),
                      Text(
                        context.l10n.resolveError(state.error!),
                        style: const TextStyle(
                          color: Color(0xFFEF4444),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.card,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: state.isSaving ? null : () async { await controller.save(); },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      disabledBackgroundColor: const Color(0xFF34D399).withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.txSaveButton, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        );

    if (widget.isSheet) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: context.colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SheetHeader(
                title: l10n.txNewTitle,
                onClose: () => context.pop(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: formContent),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txNewTitle),
      ),
      body: SafeArea(child: formContent),
    );
  }

  Future<void> _showChallengeCompletedDialog(
    BuildContext context,
    List<String> names,
    dynamic l10n,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.emoji_events_rounded,
          color: Color(0xFFFCD34D),
          size: 48,
        ),
        title: Text(
          l10n.challengeAutoCompletedTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: names
              .map((name) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF34D399), size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(name)),
                      ],
                    ),
                  ))
              .toList(),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => ctx.pop(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF34D399),
              minimumSize: const Size(140, 44),
            ),
            child: Text(l10n.challengeAutoCompletedDismiss),
          ),
        ],
      ),
    );
  }

}


class _DatePickerTile extends StatelessWidget {
  final DateTime date;
  final VoidCallback onPick;

  const _DatePickerTile({required this.date, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = DateFormat('EEE d MMM, yyyy', 'es').format(date);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_month_rounded),
            const SizedBox(width: 10),
            Expanded(
              child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}

class _AiSuggestionChip extends StatelessWidget {
  final TransactionCategory? category;
  final bool isLoading;
  final VoidCallback? onApply;

  const _AiSuggestionChip({
    required this.category,
    required this.isLoading,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 8),
          Text(
            '...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      );
    }

    if (category == null) return const SizedBox.shrink();

    final categoryLabel = _categoryLabel(category!, l10n);

    return GestureDetector(
      onTap: onApply,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF818CF8).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded,
                size: 15, color: Color(0xFF818CF8)),
            const SizedBox(width: 6),
            Text(
              l10n.txAiSuggests(categoryLabel),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF818CF8),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              l10n.txAiApply,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF818CF8),
                    decoration: TextDecoration.underline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(TransactionCategory c, dynamic l10n) {
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
}

class _BucketChip extends StatelessWidget {
  final Bucket503020 bucket;
  const _BucketChip({required this.bucket});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, color) = switch (bucket) {
      Bucket503020.necesidad => (l10n.txNeed, const Color(0xFF34D399)),
      Bucket503020.deseo => (l10n.txWant, const Color(0xFFC084FC)),
      Bucket503020.ahorro => (l10n.txSavingBucket, const Color(0xFFFCD34D)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final TransactionCategory? selected;
  final ValueChanged<TransactionCategory> onSelected;

  const _CategoryGrid({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final items = TransactionCategory.values;

    Widget buildChip(int index) {
      final c = items[index];
      final isSelected = c == selected;
      final icon = _categoryIcon(c);
      final label = _categoryLabel(c, l10n);
      return InkWell(
        onTap: () => onSelected(c),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF34D399).withValues(alpha: 0.18)
                : colors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF34D399)
                  : colors.border,
            ),
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 4;
        const spacing = 8.0;
        final itemWidth = (constraints.maxWidth - spacing * (crossAxisCount - 1)) / crossAxisCount;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < items.length; i++)
              SizedBox(
                width: itemWidth,
                height: itemWidth / 1.1,
                child: buildChip(i),
              ),
          ],
        );
      },
    );
  }

  IconData _categoryIcon(TransactionCategory c) =>
      CategoryUtils.iconForCategory(c.name);

  String _categoryLabel(TransactionCategory c, dynamic l10n) {
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
}
