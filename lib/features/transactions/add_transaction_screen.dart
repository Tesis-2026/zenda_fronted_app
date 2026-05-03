import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../dashboard/dashboard_providers.dart';
import '../../core/models/account.dart';
import '../../core/models/transaction.dart';
import '../../core/services/transaction_api_service.dart';
import 'controllers/new_transaction_controller.dart';
import '../../l10n/l10n_extension.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

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
      final suggestion = await TransactionApiService()
          .classify(description: note.trim(), amount: amount);
      if (!mounted) return;
      setState(() {
        _aiSuggestion = suggestion;
        _isClassifying = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newTransactionControllerProvider);
    final controller = ref.read(newTransactionControllerProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : Colors.black87;
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.txBudgetAlert80(categoryName, '80')),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFF59E0B),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          });
        }

        // Show spending anomaly alert (US-016) after pop.
        if (next.anomalyAlert != null) {
          final categoryName = next.anomalyAlert!;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.trending_up_rounded,
                          color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(l10n.txAnomalyAlert(categoryName)),
                      ),
                    ],
                  ),
                  backgroundColor: const Color(0xFFEF4444),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  margin: const EdgeInsets.all(16),
                  duration: const Duration(seconds: 6),
                ),
              );
            }
          });
        }
      }
    });

    final accountsAsync = ref.watch(accountsProvider);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.txNewTitle),
      ),
      body: SafeArea(
        child: accountsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text(l10n.txErrorPrefix(e.toString()))),
          data: (accounts) {
            final from = _findAccount(accounts, state.fromAccountId);
            final to = _findAccount(accounts, state.toAccountId);

            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SegmentedButton<TransactionKind>(
                          segments: [
                            ButtonSegment(
                              value: TransactionKind.expense,
                              label: Text(l10n.txExpense),
                              icon: const Icon(Icons.arrow_upward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionKind.income,
                              label: Text(l10n.txIncome),
                              icon: const Icon(Icons.arrow_downward_rounded),
                            ),
                            ButtonSegment(
                              value: TransactionKind.transfer,
                              label: Text(l10n.txTransfer),
                              icon: const Icon(Icons.swap_horiz_rounded),
                            ),
                          ],
                          selected: {state.kind},
                          onSelectionChanged: (sel) {
                            controller.setKind(sel.first);
                          },
                        ),
                        const SizedBox(height: 16),

                        Text(
                          l10n.txAccountLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _AccountPicker(
                          label: l10n.txSourceLabel,
                          accounts: accounts,
                          selected: from,
                          onChanged: (id) => controller.setFromAccount(id),
                        ),
                        if (state.kind == TransactionKind.transfer) ...[
                          const SizedBox(height: 12),
                          _AccountPicker(
                            label: l10n.txDestLabel,
                            accounts: accounts,
                            selected: to,
                            onChanged: (id) => controller.setToAccount(id),
                          ),
                        ],

                        const SizedBox(height: 18),
                        Text(
                          l10n.txAmountLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _amountController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                          decoration: InputDecoration(
                            prefixText: 'S/ ',
                            hintText: l10n.txAmountHint,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: controller.setAmountFromText,
                        ),

                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.txCategoryLabel,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: onSurface,
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
                          customCategoryName: state.customCategoryName,
                          onSelected: controller.setCategory,
                          onAddCustom: () async {
                            final name = await _showAddCategoryDialog(context, l10n);
                            if (name != null && name.isNotEmpty) {
                              controller.setCustomCategory(name);
                            }
                          },
                        ),

                        const SizedBox(height: 18),
                        Text(
                          l10n.txNoteLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _noteController,
                          textInputAction: TextInputAction.done,
                          decoration: InputDecoration(
                            hintText: l10n.txNoteHint,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
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
                            color: onSurface,
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
                      color: Theme.of(context).scaffoldBackgroundColor,
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
                      child: ElevatedButton(
                        onPressed: state.isSaving
                            ? null
                            : () async {
                                await controller.save();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF34D399),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: state.isSaving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                l10n.txSaveButton,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Account? _findAccount(List<Account> accounts, String? id) {
    if (id == null) return null;
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
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
            onPressed: () => Navigator.pop(ctx),
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

  Future<String?> _showAddCategoryDialog(BuildContext context, dynamic l10n) async {
    final ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.txAddCustomCategory),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: l10n.txAddCustomCategory,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
  }
}

class _AccountPicker extends StatelessWidget {
  final String label;
  final List<Account> accounts;
  final Account? selected;
  final ValueChanged<String?> onChanged;

  const _AccountPicker({
    required this.label,
    required this.accounts,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DropdownButtonFormField<String>(
      initialValue: selected?.id,
      items: accounts
          .map(
            (a) => DropdownMenuItem(
              value: a.id,
              child: Row(
                children: [
                  Icon(a.iconData, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    a.type == AccountType.credit
                        ? 'Debt: S/ ${a.creditDebt.toStringAsFixed(0)}'
                        : 'S/ ${a.balance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[300] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final text = DateFormat('EEE d MMM, yyyy', 'es').format(date);
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
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
  final String? customCategoryName;
  final ValueChanged<TransactionCategory> onSelected;
  final Future<void> Function() onAddCustom;

  const _CategoryGrid({
    required this.selected,
    required this.customCategoryName,
    required this.onSelected,
    required this.onAddCustom,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = context.l10n;
    final items = TransactionCategory.values;
    final hasCustom = customCategoryName != null && customCategoryName!.isNotEmpty;
    final allItems = [...items, null]; // null = "add custom" slot

    Widget buildChip(int index) {
      if (index == items.length) {
        return InkWell(
          onTap: onAddCustom,
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: hasCustom
                  ? const Color(0xFF818CF8).withValues(alpha: 0.18)
                  : (isDark ? const Color(0xFF1E293B) : Colors.white),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasCustom
                    ? const Color(0xFF818CF8)
                    : (isDark ? Colors.white10 : Colors.black12),
              ),
            ),
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasCustom ? Icons.label_rounded : Icons.add_rounded,
                  size: 22,
                  color: hasCustom ? const Color(0xFF818CF8) : null,
                ),
                const SizedBox(height: 6),
                Text(
                  hasCustom ? customCategoryName! : l10n.txAddCustomCategory,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: hasCustom ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                    color: hasCustom ? const Color(0xFF818CF8) : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }
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
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF34D399)
                  : (isDark ? Colors.white10 : Colors.black12),
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
        final itemWidth = (constraints.maxWidth - 20) / 3;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < allItems.length; i++)
              SizedBox(
                width: itemWidth,
                height: itemWidth / 1.25,
                child: buildChip(i),
              ),
          ],
        );
      },
    );
  }

  IconData _categoryIcon(TransactionCategory c) {
    return switch (c) {
      TransactionCategory.comida => Icons.restaurant_rounded,
      TransactionCategory.transporte => Icons.directions_car_rounded,
      TransactionCategory.vivienda => Icons.home_rounded,
      TransactionCategory.servicios => Icons.lightbulb_rounded,
      TransactionCategory.salud => Icons.health_and_safety_rounded,
      TransactionCategory.ocio => Icons.movie_rounded,
      TransactionCategory.compras => Icons.shopping_bag_rounded,
      TransactionCategory.suscripciones => Icons.subscriptions_rounded,
      TransactionCategory.antojos => Icons.icecream_rounded,
      TransactionCategory.ahorro => Icons.savings_rounded,
      TransactionCategory.otros => Icons.category_rounded,
    };
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
