import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/budget.dart';
import '../../core/models/transaction.dart';
import '../../core/services/transaction_api_service.dart'
    show categoryToApiName;
import '../../core/utils/category_utils.dart';
import '../dashboard/dashboard_providers.dart';
import '../../providers/repositories_providers.dart';
import '../../core/widgets/amount_input_field.dart';
import '../../core/widgets/app_date_field.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/category_dropdown_field.dart';
import '../../core/widgets/category_selector.dart';
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
  TransactionCategory? _aiSuggestion;
  bool _isClassifying = false;

  @override
  void dispose() {
    ref.invalidate(newTransactionControllerProvider);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  /// User-initiated AI categorization. Triggered by the helper button next to
  /// the category field — never automatically — so the user explicitly asks for
  /// a suggestion. Needs a note and a positive amount to classify.
  Future<void> _requestAiSuggestion() async {
    final state = ref.read(newTransactionControllerProvider);
    final note = state.note.trim();
    final amount = state.amount;
    if (note.length < 3 || amount == null || amount <= 0) return;

    setState(() => _isClassifying = true);
    final result = await ref
        .read(transactionApiServiceProvider)
        .classify(description: note, amount: amount);
    if (!mounted) return;
    // Persist the suggestion on the controller regardless of whether the user
    // later accepts it. The backend uses it on save() to derive
    // `categorySource = AI / AI_OVERRIDDEN / USER`.
    if (result != null) {
      ref
          .read(newTransactionControllerProvider.notifier)
          .recordAiSuggestion(result.categoryName, result.confidence);
    }
    setState(() {
      _aiSuggestion = result?.category;
      _isClassifying = false;
    });
  }

  void _syncBudgetSelection(List<Budget> budgets, NewTransactionState state) {
    final hasValidSelection =
        state.selectedBudgetId != null &&
        budgets.any((budget) => budget.id == state.selectedBudgetId);

    if (hasValidSelection) return;

    final nextBudgetId = _preferredBudgetId(budgets, state.category);
    if (nextBudgetId == null && state.selectedBudgetId == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final controller = ref.read(newTransactionControllerProvider.notifier);
      if (nextBudgetId == null) {
        controller.clearBudget();
      } else {
        controller.setBudget(nextBudgetId);
      }
    });
  }

  String? _preferredBudgetId(
    List<Budget> budgets,
    TransactionCategory? category,
  ) {
    if (budgets.isEmpty) return null;
    if (budgets.length == 1) return budgets.first.id;

    if (category == null) return null;
    final categoryName = categoryToApiName(category).toLowerCase();
    for (final budget in budgets) {
      if ((budget.categoryName ?? '').toLowerCase() == categoryName) {
        return budget.id;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newTransactionControllerProvider);
    final controller = ref.read(newTransactionControllerProvider.notifier);
    final colors = context.colors;
    final l10n = context.l10n;
    final budgetPeriod = (month: state.date.month, year: state.date.year);
    final budgetsAsync = ref.watch(budgetsForPeriodProvider(budgetPeriod));

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
                Text(
                  l10n.txAmountLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                AmountInputField(
                  controller: _amountController,
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
                    // Editing the note invalidates a prior AI suggestion;
                    // the user must request a fresh one.
                    if (_aiSuggestion != null) {
                      setState(() => _aiSuggestion = null);
                    }
                  },
                ),

                const SizedBox(height: 18),
                Text(
                  l10n.txDateLabel,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                AppDateField(
                  value: state.date,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: state.date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) controller.setDate(picked);
                  },
                ),
                const SizedBox(height: 18),
                // Categoría (clasificación) — obligatoria
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
                CategoryDropdownField<TransactionCategory>(
                  value: state.category,
                  hintText: l10n.categorySelectHint,
                  sheetTitle: l10n.txCategoryLabel,
                  onChanged: controller.setCategory,
                  options: [
                    for (final c in TransactionCategory.values)
                      CategoryOption<TransactionCategory>(
                        value: c,
                        label: CategorySelector.labelFor(context, c),
                        icon: CategoryUtils.iconForCategory(c.name),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                // AI categorization helper — sits next to the category
                // field and is only triggered when the user asks for it.
                _AiCategoryHelper(
                  isLoading: _isClassifying,
                  suggestion: _aiSuggestion,
                  canRequest:
                      state.note.trim().length >= 3 &&
                      state.amount != null &&
                      state.amount! > 0,
                  onRequest: _requestAiSuggestion,
                  onApply: () {
                    if (_aiSuggestion != null) {
                      controller.setCategory(_aiSuggestion!);
                      setState(() => _aiSuggestion = null);
                    }
                  },
                ),
                // El presupuesto es un límite de gasto: solo aplica a gastos.
                // Un ingreso no "engorda" un límite, así que el campo se
                // omite para ingresos (presupuesto opcional a nivel backend).
                if (state.kind == TransactionKind.expense) ...[
                  const SizedBox(height: 18),
                  Text(
                    l10n.txBudgetLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  budgetsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (_, _) => _BudgetLoadError(
                      onRetry: () => ref.invalidate(
                        budgetsForPeriodProvider(budgetPeriod),
                      ),
                    ),
                    data: (budgets) {
                      _syncBudgetSelection(budgets, state);
                      if (budgets.isEmpty) {
                        return _NoBudgetsHint(
                          onRetry: () => ref.invalidate(
                            budgetsForPeriodProvider(budgetPeriod),
                          ),
                          onManage: () {
                            final router = GoRouter.of(context);
                            if (widget.isSheet) {
                              Navigator.of(context).pop();
                            }
                            router.push('/budgets');
                          },
                        );
                      }
                      final selectedId =
                          budgets.any((b) => b.id == state.selectedBudgetId)
                          ? state.selectedBudgetId
                          : null;
                      // Standardized picker (same bordered field + bottom-sheet
                      // pattern as category selection).
                      return CategoryDropdownField<String>(
                        value: selectedId,
                        hintText: l10n.txBudgetHint,
                        sheetTitle: l10n.txBudgetLabel,
                        onChanged: controller.setBudget,
                        options: [
                          for (final b in budgets)
                            CategoryOption<String>(
                              value: b.id,
                              label: (b.name != null && b.name!.isNotEmpty)
                                  ? b.name!
                                  : CategoryUtils.labelEs(b.categoryName),
                              icon: CategoryUtils.iconForCategory(
                                b.categoryName,
                              ),
                              trailing: 'S/ ${b.available.toStringAsFixed(0)}',
                            ),
                        ],
                      );
                    },
                  ),
                ],

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
            child: AppPrimaryButton(
              label: l10n.txSaveButton,
              isLoading: state.isSaving,
              onPressed: () async {
                await controller.save();
              },
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
      appBar: AppBar(title: Text(l10n.txNewTitle)),
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
              .map(
                (name) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF34D399),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(name)),
                    ],
                  ),
                ),
              )
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

/// AI categorization helper shown right below the category dropdown.
///
/// Three states:
///   - idle    → a "suggest with AI" button (disabled until there's enough info)
///   - loading → an inline spinner while the classifier runs
///   - ready   → the suggestion with an "apply" action
///
/// The suggestion is always user-initiated: it only runs when [onRequest] is
/// tapped, never automatically.
class _AiCategoryHelper extends StatelessWidget {
  const _AiCategoryHelper({
    required this.isLoading,
    required this.suggestion,
    required this.canRequest,
    required this.onRequest,
    required this.onApply,
  });

  final bool isLoading;
  final TransactionCategory? suggestion;
  final bool canRequest;
  final VoidCallback onRequest;
  final VoidCallback onApply;

  static const _accent = Color(0xFF818CF8);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: _accent),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.txAiAnalyzing,
            style: const TextStyle(
              color: _accent,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    if (suggestion != null) {
      final label = CategorySelector.labelFor(context, suggestion!);
      return InkWell(
        onTap: onApply,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _accent.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l10n.txAiSuggests(label),
                  style: const TextStyle(
                    color: _accent,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.txAiApply,
                style: const TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Idle — the request button.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: canRequest ? onRequest : null,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: canRequest
                  ? _accent.withValues(alpha: 0.10)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: canRequest
                    ? _accent.withValues(alpha: 0.4)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  l10n.txAiSuggestButton,
                  style: TextStyle(
                    color: canRequest ? _accent : const Color(0xFF9CA3AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!canRequest) ...[
          const SizedBox(height: 6),
          Text(
            l10n.txAiNeedsInfo,
            style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
          ),
        ],
      ],
    );
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

/// Shown when the user has no budgets yet — registering needs at least one.
class _NoBudgetsHint extends StatelessWidget {
  const _NoBudgetsHint({required this.onRetry, required this.onManage});

  final VoidCallback onRetry;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Color(0xFF34D399),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.txNoBudgetsHint,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.commonRetry),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF374151),
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  side: const BorderSide(color: Color(0xFFD1D5DB)),
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              FilledButton.icon(
                onPressed: onManage,
                icon: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 18,
                ),
                label: Text(l10n.budgetTitle),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetLoadError extends StatelessWidget {
  const _BudgetLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDC2626),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.budgetErrorLoad,
                  style: const TextStyle(
                    color: Color(0xFF991B1B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.commonRetry),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              textStyle: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
