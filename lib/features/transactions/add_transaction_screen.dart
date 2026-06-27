import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as speech;

import '../../core/models/budget.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/services/api_client.dart';
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
  final _amountFocusNode = FocusNode();
  final _noteController = TextEditingController();
  TransactionCategory? _aiSuggestion;
  bool _isClassifying = false;
  bool _isScanningReceipt = false;
  bool _isParsingVoice = false;

  @override
  void dispose() {
    ref.invalidate(newTransactionControllerProvider);
    _amountController.dispose();
    _amountFocusNode.dispose();
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

  Future<void> _showVoiceDraftSheet() async {
    if (_isParsingVoice) return;

    final transcript = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _VoiceInputSheet(),
    );
    final text = transcript?.trim();
    if (text == null || text.isEmpty) return;

    if (!mounted) return;
    setState(() => _isParsingVoice = true);

    try {
      final result = await ref
          .read(voiceTransactionServiceProvider)
          .parseDraft(text: text);
      final category = result.category;
      final accountId = _resolveSuggestedAccountId(
        suggestedType: result.suggestedAccountType,
        suggestedName: result.suggestedAccountName,
      );
      ref
          .read(newTransactionControllerProvider.notifier)
          .applyVoiceDraft(
            kind: result.kind,
            amount: result.amount,
            category: category,
            date: result.occurredAt,
            note: result.description.isNotEmpty ? result.description : text,
            accountId: accountId,
            aiSuggestedCategoryName: result.suggestedCategoryName,
            aiConfidence: result.suggestedCategoryName != null
                ? result.confidence
                : null,
          );

      if (!mounted) return;
      setState(() {
        _aiSuggestion = null;
        _isParsingVoice = false;
      });
      showAppToast(
        context,
        result.warnings.isNotEmpty
            ? result.warnings.first
            : context.l10n.txVoiceApplied,
        type: result.warnings.isNotEmpty
            ? ToastType.warning
            : ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isParsingVoice = false);
      showAppToast(
        context,
        e is ApiException ? e.message : context.l10n.txVoiceDraftFailed,
        type: ToastType.error,
      );
    }
  }

  void _syncBudgetSelection(List<Budget> budgets, NewTransactionState state) {
    if (state.selectedBudgetId == null) return;
    final hasValidSelection = budgets.any(
      (budget) => budget.id == state.selectedBudgetId,
    );
    if (hasValidSelection) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(newTransactionControllerProvider.notifier).clearBudget();
    });
  }

  Future<void> _showReceiptSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ReceiptSourceSheet(),
    );
    if (source == null) return;
    await _scanReceipt(source);
  }

  Future<void> _scanReceipt(ImageSource source) async {
    if (_isScanningReceipt) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1800,
    );
    if (picked == null) return;

    if (!mounted) return;
    setState(() => _isScanningReceipt = true);

    try {
      final result = await ref
          .read(ocrServiceProvider)
          .analyzeReceipt(
            bytes: await picked.readAsBytes(),
            filename: picked.name.isNotEmpty ? picked.name : 'receipt.jpg',
            contentType: _contentTypeForImage(picked.name),
          );
      final suggestedCategory = result.category;
      final accountId = _resolveSuggestedAccountId(
        suggestedType: result.suggestedAccountType,
        suggestedName: result.suggestedAccountName,
      );
      ref
          .read(newTransactionControllerProvider.notifier)
          .applyReceiptDraft(
            amount: result.amount,
            category: suggestedCategory,
            date: result.parsedDate,
            note: result.note.isNotEmpty ? result.note : result.merchant,
            accountId: accountId,
            aiSuggestedCategoryName: result.suggestedCategory,
            aiConfidence: result.suggestedCategory != null
                ? result.confidence
                : null,
          );

      if (!mounted) return;
      setState(() {
        _aiSuggestion = null;
        _isScanningReceipt = false;
      });
      showAppToast(
        context,
        result.warnings.isNotEmpty
            ? result.warnings.first
            : context.l10n.txReceiptApplied,
        type: result.warnings.isNotEmpty
            ? ToastType.warning
            : ToastType.success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isScanningReceipt = false);
      showAppToast(
        context,
        e is ApiException ? e.message : context.l10n.txReceiptScanFailed,
        type: ToastType.error,
      );
    }
  }

  String _contentTypeForImage(String filename) {
    return filename.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg';
  }

  String? _resolveSuggestedAccountId({
    required String? suggestedType,
    required String? suggestedName,
  }) {
    final accounts =
        ref.read(accountsProvider).asData?.value ?? const <FinancialAccount>[];
    if (accounts.isEmpty) return null;
    final type = suggestedType == null
        ? null
        : accountTypeFromApi(suggestedType);
    if (type != null) {
      final byType = accounts.where((account) => account.type == type);
      if (byType.isNotEmpty) return byType.first.id;
    }
    final name = suggestedName?.trim().toLowerCase();
    if (name != null && name.isNotEmpty) {
      for (final account in accounts) {
        if (account.name.toLowerCase().contains(name) ||
            name.contains(account.name.toLowerCase())) {
          return account.id;
        }
      }
    }
    return null;
  }

  List<CategoryOption<String>> _accountOptions(
    List<FinancialAccount> accounts, {
    required TransactionKind kind,
    required bool destination,
  }) {
    final filtered = accounts.where((account) {
      if (kind == TransactionKind.income) {
        return account.type != AccountType.creditCard;
      }
      if (kind == TransactionKind.transfer && !destination) {
        return account.type != AccountType.creditCard;
      }
      return true;
    });
    return [
      for (final account in filtered)
        CategoryOption<String>(
          value: account.id,
          label: account.name,
          icon: accountTypeIcon(account.type),
          trailing: account.type == AccountType.creditCard
              ? 'Deuda S/ ${account.debt.toStringAsFixed(0)}'
              : 'S/ ${account.currentBalance.toStringAsFixed(0)}',
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newTransactionControllerProvider);
    final controller = ref.read(newTransactionControllerProvider.notifier);
    final colors = context.colors;
    final l10n = context.l10n;
    final budgetPeriod = (month: state.date.month, year: state.date.year);
    final budgetsAsync = ref.watch(budgetsForPeriodProvider(budgetPeriod));
    final accountsAsync = ref.watch(accountsProvider);

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

    // Keep text controllers in sync with OCR/voice autofill, but never rewrite
    // the amount while the user is typing manually. Reformatting "5" to "5.00"
    // mid-input leaves the cursor at the end and turns the next digit into
    // "5.001".
    if (state.amount != null &&
        state.source != TransactionSource.manual &&
        !_amountFocusNode.hasFocus) {
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
                  transferLabel: 'Transferir',
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _VoiceDraftButton(
                        isLoading: _isParsingVoice,
                        onPressed: _showVoiceDraftSheet,
                      ),
                    ),
                    if (state.kind == TransactionKind.expense) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: _ReceiptScanButton(
                          isLoading: _isScanningReceipt,
                          onPressed: _showReceiptSourceSheet,
                        ),
                      ),
                    ],
                  ],
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
                  focusNode: _amountFocusNode,
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
                accountsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, _) => _AccountLoadError(
                    onRetry: () => ref.invalidate(accountsProvider),
                  ),
                  data: (accounts) {
                    if (state.kind == TransactionKind.transfer) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AccountPicker(
                            label: 'Desde',
                            value: state.selectedAccountId,
                            hintText: 'Selecciona cuenta origen',
                            options: _accountOptions(
                              accounts,
                              kind: state.kind,
                              destination: false,
                            ),
                            onChanged: controller.setAccount,
                          ),
                          const SizedBox(height: 14),
                          _AccountPicker(
                            label: 'Hacia',
                            value: state.selectedToAccountId,
                            hintText: 'Selecciona cuenta destino',
                            options: _accountOptions(
                              accounts,
                              kind: state.kind,
                              destination: true,
                            ),
                            onChanged: controller.setToAccount,
                          ),
                        ],
                      );
                    }

                    return _AccountPicker(
                      label: state.kind == TransactionKind.income
                          ? 'Recibir en'
                          : 'Pago con',
                      value: state.selectedAccountId,
                      hintText: 'Usar cuenta sugerida',
                      options: _accountOptions(
                        accounts,
                        kind: state.kind,
                        destination: false,
                      ),
                      onChanged: controller.setAccount,
                    );
                  },
                ),
                const SizedBox(height: 18),
                if (state.kind != TransactionKind.transfer) ...[
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
                      for (final c in categoriesForTransactionKind(state.kind))
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
                  // El presupuesto es un límite de gasto opcional: solo aplica a
                  // gastos. Un ingreso no "engorda" un límite, así que el campo
                  // se omite para ingresos.
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
                        // pattern as category selection). The first option lets
                        // the user save the expense outside any budget.
                        return CategoryDropdownField<String?>(
                          value: selectedId,
                          hintText: l10n.txBudgetHint,
                          sheetTitle: l10n.txBudgetLabel,
                          onChanged: controller.setOptionalBudget,
                          options: [
                            CategoryOption<String?>(
                              value: null,
                              label: l10n.txBudgetNone,
                              icon: Icons.block_rounded,
                              trailing: l10n.commonNotSet,
                            ),
                            for (final b in budgets)
                              CategoryOption<String?>(
                                value: b.id,
                                label: (b.name != null && b.name!.isNotEmpty)
                                    ? b.name!
                                    : CategoryUtils.labelEs(b.categoryName),
                                icon: CategoryUtils.iconForCategory(
                                  b.categoryName,
                                ),
                                trailing:
                                    'S/ ${b.available.toStringAsFixed(0)}',
                              ),
                          ],
                        );
                      },
                    ),
                  ],
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

class _VoiceDraftButton extends StatelessWidget {
  const _VoiceDraftButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  static const _accent = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('voice-loading'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accent,
                ),
              )
            : const Icon(
                Icons.mic_rounded,
                key: ValueKey('voice-icon'),
                size: 20,
              ),
      ),
      label: Text(isLoading ? l10n.txParsingVoice : l10n.txVoiceTransaction),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        disabledForegroundColor: _accent.withValues(alpha: 0.60),
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        side: BorderSide(color: _accent.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ReceiptScanButton extends StatelessWidget {
  const _ReceiptScanButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  static const _accent = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return OutlinedButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: isLoading
            ? const SizedBox(
                key: ValueKey('receipt-loading'),
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accent,
                ),
              )
            : const Icon(
                Icons.document_scanner_rounded,
                key: ValueKey('receipt-icon'),
                size: 20,
              ),
      ),
      label: Text(isLoading ? l10n.txScanningReceipt : l10n.txScanReceipt),
      style: OutlinedButton.styleFrom(
        foregroundColor: _accent,
        disabledForegroundColor: _accent.withValues(alpha: 0.60),
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        side: BorderSide(color: _accent.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _VoiceInputSheet extends StatefulWidget {
  const _VoiceInputSheet();

  @override
  State<_VoiceInputSheet> createState() => _VoiceInputSheetState();
}

class _VoiceInputSheetState extends State<_VoiceInputSheet> {
  final speech.SpeechToText _speechToText = speech.SpeechToText();

  bool _isInitializing = true;
  bool _isAvailable = false;
  bool _isListening = false;
  String _transcript = '';
  String? _localeId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
  }

  @override
  void dispose() {
    _speechToText.cancel();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    try {
      final available = await _speechToText.initialize(
        onStatus: _handleStatus,
        onError: (error) {
          if (!mounted) return;
          setState(() {
            _error = error.errorMsg;
            _isListening = false;
          });
        },
        options: [speech.SpeechToText.androidNoBluetooth],
      );
      String? localeId;
      if (available) {
        final locales = await _speechToText.locales();
        for (final locale in locales) {
          if (locale.localeId.toLowerCase().startsWith('es')) {
            localeId = locale.localeId;
            break;
          }
        }
        localeId ??= (await _speechToText.systemLocale())?.localeId;
      }

      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isAvailable = available;
        _localeId = localeId;
        _error = available ? null : context.l10n.txVoiceUnavailable;
      });

      if (available) {
        await _startListening();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _isAvailable = false;
        _isListening = false;
        _error = context.l10n.txVoiceUnavailable;
      });
    }
  }

  void _handleStatus(String status) {
    if (!mounted) return;
    setState(() {
      _isListening = status == 'listening';
    });
  }

  Future<void> _startListening() async {
    if (!_isAvailable || _isListening) return;
    setState(() => _error = null);
    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenOptions: speech.SpeechListenOptions(
        localeId: _localeId,
        listenMode: speech.ListenMode.confirmation,
        partialResults: true,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 12),
      ),
    );
    if (!mounted) return;
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (!mounted) return;
    setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() {
      _transcript = result.recognizedWords;
      if (result.finalResult) {
        _isListening = false;
      }
    });
  }

  Future<void> _acceptTranscript() async {
    final text = _transcript.trim();
    if (text.isEmpty) {
      setState(() => _error = context.l10n.txVoiceEmpty);
      return;
    }
    await _speechToText.stop();
    if (!mounted) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    final canUseTranscript = _transcript.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.78,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SheetHeader(
                  title: l10n.txVoiceSheetTitle,
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 18),
                Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color:
                          (_isListening
                                  ? const Color(0xFF2563EB)
                                  : const Color(0xFFEFF6FF))
                              .withValues(alpha: _isListening ? 1 : 0.95),
                      shape: BoxShape.circle,
                    ),
                    child: _isInitializing
                        ? const Padding(
                            padding: EdgeInsets.all(22),
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Icon(
                            _isListening
                                ? Icons.graphic_eq_rounded
                                : Icons.mic_rounded,
                            color: _isListening
                                ? Colors.white
                                : const Color(0xFF2563EB),
                            size: 30,
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _isListening ? l10n.txVoiceListening : l10n.txVoiceIdle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.txVoiceTranscriptLabel,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 86),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.bg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: colors.border),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        _transcript.isEmpty ? '...' : _transcript,
                        style: TextStyle(
                          color: _transcript.isEmpty
                              ? colors.textMuted
                              : colors.textPrimary,
                          fontSize: 15,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFEF4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: !_isAvailable || _isInitializing
                            ? null
                            : (_isListening ? _stopListening : _startListening),
                        icon: Icon(
                          _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                        ),
                        label: Text(
                          _isListening ? l10n.txVoiceStop : l10n.txVoiceStart,
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: canUseTranscript ? _acceptTranscript : null,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                          backgroundColor: const Color(0xFF34D399),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        child: Text(l10n.txVoiceUse),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptSourceSheet extends StatelessWidget {
  const _ReceiptSourceSheet();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 14),
              SheetHeader(
                title: l10n.txScanReceipt,
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 8),
              _ReceiptSourceTile(
                icon: Icons.camera_alt_rounded,
                label: l10n.txScanReceiptCamera,
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              const SizedBox(height: 8),
              _ReceiptSourceTile(
                icon: Icons.photo_library_rounded,
                label: l10n.txScanReceiptGallery,
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptSourceTile extends StatelessWidget {
  const _ReceiptSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF10B981), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF111827),
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
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

class _AccountPicker extends StatelessWidget {
  const _AccountPicker({
    required this.label,
    required this.value,
    required this.hintText,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final String hintText;
  final List<CategoryOption<String>> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        CategoryDropdownField<String>(
          value: value,
          hintText: hintText,
          sheetTitle: label,
          onChanged: onChanged,
          options: options,
        ),
      ],
    );
  }
}

class _AccountLoadError extends StatelessWidget {
  const _AccountLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_wallet_outlined,
            color: Color(0xFFDC2626),
            size: 18,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'No se pudieron cargar las cuentas.',
              style: TextStyle(
                color: Color(0xFF991B1B),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Reintentar',
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            color: const Color(0xFFDC2626),
          ),
        ],
      ),
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

/// Shown when the user has no budgets yet. Budgets are optional, so this is an
/// informational helper rather than a blocking validation state.
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
