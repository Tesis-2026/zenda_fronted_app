import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_codes.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/pending_transaction_queue.dart';
import '../../../core/services/streak_repository.dart';
import '../../../core/services/study_telemetry_service.dart';
import '../../../providers/repositories_providers.dart';
import '../../auth/auth_controller.dart';
import '../../budget/budget_screen.dart';
import '../../dashboard/dashboard_providers.dart';

@immutable
class NewTransactionState {
  final TransactionKind kind;
  final double? amount;
  final TransactionCategory? category;
  final String? customCategoryName;

  /// Budget the expense draws from (only required/sent for expenses). Income is
  /// never linked to a budget. Independent of the category.
  final String? selectedBudgetId;
  final String? selectedAccountId;
  final String? selectedToAccountId;
  final String note;
  final DateTime date;
  final TransactionSource source;
  final bool isSaving;
  final String? error;
  final int saveTick;
  final String? budgetAlert; // category name at ≥80% after save (US-020)
  final String?
  anomalyAlert; // category name when spending >20% over avg (US-016)
  final List<String>
  completedChallengeNames; // titles of auto-completed challenges
  // AI provenance (Integration fix #4). When the user accepted an AI
  // classify suggestion during this draft, we keep the original name +
  // confidence so they survive subsequent category overrides — the
  // backend uses them to derive AI vs AI_OVERRIDDEN.
  final String? aiSuggestedCategoryName;
  final double? aiConfidence;

  const NewTransactionState({
    required this.kind,
    required this.amount,
    required this.category,
    this.customCategoryName,
    this.selectedBudgetId,
    this.selectedAccountId,
    this.selectedToAccountId,
    required this.note,
    required this.date,
    required this.source,
    required this.isSaving,
    required this.error,
    required this.saveTick,
    this.budgetAlert,
    this.anomalyAlert,
    this.completedChallengeNames = const [],
    this.aiSuggestedCategoryName,
    this.aiConfidence,
  });

  factory NewTransactionState.initial() => NewTransactionState(
    kind: TransactionKind.expense,
    amount: null,
    category: null,
    customCategoryName: null,
    selectedAccountId: null,
    selectedToAccountId: null,
    note: '',
    date: DateTime.now(),
    source: TransactionSource.manual,
    isSaving: false,
    error: null,
    saveTick: 0,
    budgetAlert: null,
    anomalyAlert: null,
    completedChallengeNames: const [],
  );

  Bucket503020? get bucket {
    if (kind == TransactionKind.income) return null;
    final c = category;
    if (c == null) return null;
    return bucketForCategory(c);
  }

  NewTransactionState copyWith({
    TransactionKind? kind,
    double? amount,
    TransactionCategory? category,
    String? customCategoryName,
    String? selectedBudgetId,
    String? selectedAccountId,
    String? selectedToAccountId,
    String? note,
    DateTime? date,
    TransactionSource? source,
    bool? isSaving,
    String? error,
    int? saveTick,
    String? budgetAlert,
    String? anomalyAlert,
    List<String>? completedChallengeNames,
    String? aiSuggestedCategoryName,
    double? aiConfidence,
    bool clearError = false,
    bool clearCategory = false,
    bool clearCustomCategory = false,
    bool clearBudget = false,
    bool clearAccount = false,
    bool clearToAccount = false,
    bool clearBudgetAlert = false,
    bool clearAnomalyAlert = false,
    bool clearAiSuggestion = false,
  }) {
    return NewTransactionState(
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      category: clearCategory ? null : (category ?? this.category),
      customCategoryName: clearCustomCategory
          ? null
          : (customCategoryName ?? this.customCategoryName),
      selectedBudgetId: clearBudget
          ? null
          : (selectedBudgetId ?? this.selectedBudgetId),
      selectedAccountId: clearAccount
          ? null
          : (selectedAccountId ?? this.selectedAccountId),
      selectedToAccountId: clearToAccount
          ? null
          : (selectedToAccountId ?? this.selectedToAccountId),
      note: note ?? this.note,
      date: date ?? this.date,
      source: source ?? this.source,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      saveTick: saveTick ?? this.saveTick,
      budgetAlert: clearBudgetAlert ? null : (budgetAlert ?? this.budgetAlert),
      anomalyAlert: clearAnomalyAlert
          ? null
          : (anomalyAlert ?? this.anomalyAlert),
      completedChallengeNames:
          completedChallengeNames ?? this.completedChallengeNames,
      aiSuggestedCategoryName: clearAiSuggestion
          ? null
          : (aiSuggestedCategoryName ?? this.aiSuggestedCategoryName),
      aiConfidence: clearAiSuggestion
          ? null
          : (aiConfidence ?? this.aiConfidence),
    );
  }
}

final newTransactionControllerProvider =
    NotifierProvider<NewTransactionController, NewTransactionState>(
      NewTransactionController.new,
    );

class NewTransactionController extends Notifier<NewTransactionState> {
  @override
  NewTransactionState build() {
    return NewTransactionState.initial();
  }

  void setKind(TransactionKind kind) {
    final keepCategory =
        state.category == null ||
        categoriesForTransactionKind(kind).contains(state.category);
    state = state.copyWith(
      kind: kind,
      clearCategory: kind == TransactionKind.transfer || !keepCategory,
      clearBudget: kind != TransactionKind.expense,
      clearToAccount: kind != TransactionKind.transfer,
      clearError: true,
    );
  }

  void setAmountFromText(String raw) {
    final normalized = raw
        .replaceAll(',', '.')
        .replaceAll(RegExp(r'[^0-9\.]'), '');
    final value = double.tryParse(normalized);
    state = state.copyWith(amount: value, clearError: true);
  }

  void setCategory(TransactionCategory category) {
    // NOTE: do NOT clear the AI suggestion here — if the user accepted
    // an AI suggestion earlier and then changes their mind, the BE
    // needs both `suggestedCategoryId` and the (different) `categoryId`
    // to derive `categorySource = AI_OVERRIDDEN`.
    state = state.copyWith(
      category: category,
      clearCustomCategory: true,
      clearError: true,
    );
  }

  void setCustomCategory(String name) {
    state = state.copyWith(
      customCategoryName: name,
      clearCategory: true,
      clearError: true,
    );
  }

  void setBudget(String budgetId) {
    state = state.copyWith(selectedBudgetId: budgetId, clearError: true);
  }

  void setOptionalBudget(String? budgetId) {
    if (budgetId == null || budgetId.isEmpty) {
      clearBudget();
      return;
    }
    setBudget(budgetId);
  }

  void clearBudget() {
    state = state.copyWith(clearBudget: true, clearError: true);
  }

  void setAccount(String? accountId) {
    state = state.copyWith(selectedAccountId: accountId, clearError: true);
  }

  void setToAccount(String? accountId) {
    state = state.copyWith(selectedToAccountId: accountId, clearError: true);
  }

  /// Records that the AI suggested a category for the current draft.
  /// Called by the screen whether or not the user later accepts the
  /// suggestion — the data is needed at save time so the backend can
  /// classify the resulting transaction as AI / AI_OVERRIDDEN.
  void recordAiSuggestion(String categoryName, double confidence) {
    state = state.copyWith(
      aiSuggestedCategoryName: categoryName,
      aiConfidence: confidence,
    );
  }

  void setNote(String note) {
    state = state.copyWith(note: note, clearError: true);
  }

  void setDate(DateTime date) {
    final periodChanged =
        state.date.month != date.month || state.date.year != date.year;
    state = state.copyWith(
      date: date,
      clearBudget: periodChanged,
      clearError: true,
    );
  }

  void applyReceiptDraft({
    double? amount,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    String? accountId,
    String? aiSuggestedCategoryName,
    double? aiConfidence,
  }) {
    final normalizedNote = note?.trim();
    state = state.copyWith(
      amount: amount ?? state.amount,
      category: category,
      note: normalizedNote != null && normalizedNote.isNotEmpty
          ? normalizedNote
          : state.note,
      selectedAccountId: accountId,
      date: date ?? state.date,
      source: TransactionSource.ocr,
      clearCustomCategory: category != null,
      clearError: true,
      aiSuggestedCategoryName: aiSuggestedCategoryName,
      aiConfidence: aiConfidence,
      clearAiSuggestion:
          aiSuggestedCategoryName == null || aiConfidence == null,
    );
  }

  void applyVoiceDraft({
    required TransactionKind kind,
    double? amount,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    String? accountId,
    String? aiSuggestedCategoryName,
    double? aiConfidence,
  }) {
    final normalizedNote = note?.trim();
    final targetDate = date ?? state.date;
    final periodChanged =
        state.date.month != targetDate.month ||
        state.date.year != targetDate.year;
    state = state.copyWith(
      kind: kind,
      amount: amount ?? state.amount,
      category: category,
      note: normalizedNote != null && normalizedNote.isNotEmpty
          ? normalizedNote
          : state.note,
      selectedAccountId: accountId,
      date: targetDate,
      source: TransactionSource.voice,
      clearCustomCategory: category != null,
      clearBudget: kind == TransactionKind.income || periodChanged,
      clearError: true,
      aiSuggestedCategoryName: aiSuggestedCategoryName,
      aiConfidence: aiConfidence,
      clearAiSuggestion:
          aiSuggestedCategoryName == null || aiConfidence == null,
    );
  }

  Future<void> save() async {
    final amount = state.amount;
    if (amount == null || amount <= 0) {
      state = state.copyWith(error: TxErrorCode.invalidAmount);
      return;
    }

    final kind = state.kind;
    final accountId = state.selectedAccountId;
    final toAccountId = state.selectedToAccountId;

    if (kind == TransactionKind.transfer) {
      if (accountId == null || accountId.isEmpty) {
        state = state.copyWith(error: TxErrorCode.noSourceAccount);
        return;
      }
      if (toAccountId == null || toAccountId.isEmpty) {
        state = state.copyWith(error: TxErrorCode.noDestAccount);
        return;
      }
      if (accountId == toAccountId) {
        state = state.copyWith(error: TxErrorCode.sameAccount);
        return;
      }
    }

    final category = state.category;
    final customName = state.customCategoryName;
    if (kind != TransactionKind.transfer &&
        category == null &&
        (customName == null || customName.isEmpty)) {
      state = state.copyWith(error: TxErrorCode.noCategory);
      return;
    }
    final effectiveCategory = category ?? TransactionCategory.otros;

    // Budget is a spending limit, so it is optional metadata for expenses.
    // Income does not draw from / inflate a budget, so it is never sent.
    final budgetId = kind == TransactionKind.expense
        ? state.selectedBudgetId
        : null;

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final txRepo = ref.read(transactionsRepositoryProvider);
      final streakRepo = ref.read(streakRepositoryProvider);

      final tx = TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: ref.read(authNotifierProvider).user?.id ?? '',
        accountId: accountId ?? '',
        toAccountId: toAccountId,
        kind: kind,
        amount: amount,
        currency: 'PEN',
        category: effectiveCategory,
        bucket: bucketForCategory(effectiveCategory),
        timestamp: state.date,
        note: state.note.isEmpty ? null : state.note,
        source: state.source,
      );
      if (kind != TransactionKind.transfer) {
        await txRepo.addTransaction(tx);
      }

      // Sync to backend; enqueue for retry if offline or unreachable.
      String? budgetAlertName;
      String? anomalyAlertName;
      List<String> completedNames = [];
      try {
        if (kind == TransactionKind.transfer) {
          await ref
              .read(accountApiServiceProvider)
              .transfer(
                fromAccountId: accountId!,
                toAccountId: toAccountId!,
                amount: amount,
                occurredAt: state.date,
                description: state.note.isEmpty ? null : state.note,
              );
          await txRepo.addTransaction(tx);
        } else {
          final apiService = ref.read(transactionApiServiceProvider);
          final result = await apiService.create(
            kind: kind,
            amount: amount,
            category: effectiveCategory,
            budgetId: budgetId,
            accountId: accountId,
            occurredAt: state.date,
            description: state.note.isEmpty ? null : state.note,
            customCategoryName: customName,
            aiSuggestedCategoryName: state.aiSuggestedCategoryName,
            aiConfidence: state.aiConfidence,
            // Local tx id is unique per save attempt — reuse it as the
            // Idempotency-Key so any retry (network blip, queue flush)
            // replays the cached response instead of inserting again.
            idempotencyKey: tx.id,
          );
          completedNames = result.completedChallenges;

          // US-016: anomaly alert returned directly from the create endpoint.
          if (kind == TransactionKind.expense) {
            anomalyAlertName = result.anomalyAlert;
          }

          // US-020: check if any budget just reached ≥80% after this expense.
          if (kind == TransactionKind.expense) {
            final now = state.date;
            final budgets = await ref
                .read(budgetServiceProvider)
                .getAll(month: now.month, year: now.year);
            final triggered = budgets.where(
              (b) => b.percentageUsed >= 80.0 && b.percentageUsed < 100.0,
            );
            if (triggered.isNotEmpty) {
              budgetAlertName = triggered.first.categoryName ?? 'Presupuesto';
            }
          }
        }
      } catch (_) {
        if (kind == TransactionKind.transfer) rethrow;
        // Offline or unreachable — enqueue for retry when connectivity returns.
        final queue = ref.read(pendingTransactionQueueProvider);
        await queue.enqueue(
          PendingSyncEntry(
            txId: tx.id,
            kind: kind,
            amount: amount,
            category: effectiveCategory,
            budgetId: budgetId,
            accountId: accountId,
            toAccountId: toAccountId,
            occurredAt: state.date,
            description: state.note.isEmpty ? null : state.note,
            customCategoryName: customName,
            aiSuggestedCategoryName: state.aiSuggestedCategoryName,
            aiConfidence: state.aiConfidence,
          ),
        );
      }

      // Update streak only on save.
      await streakRepo.updateOnTransaction(state.date);
      StudyTelemetryService.track(
        'transaction_created',
        metadata: {
          'kind': kind.name,
          'source': state.source.name,
          'has_account': accountId != null && accountId.isNotEmpty,
          'has_budget': budgetId != null && budgetId.isNotEmpty,
        },
        backend: false,
      );

      // Trigger dashboard refresh (providers are currently FutureProviders).
      ref.invalidate(transactionsProvider);
      ref.invalidate(streakStateProvider);
      ref.invalidate(daySummaryProvider);
      ref.invalidate(weekSummaryProvider);
      ref.invalidate(monthSummaryProvider);
      ref.invalidate(budgetSummaryProvider);
      ref.invalidate(accountsProvider);
      ref.invalidate(
        accountReportProvider((month: state.date.month, year: state.date.year)),
      );
      ref.invalidate(
        budgetsForPeriodProvider((
          month: state.date.month,
          year: state.date.year,
        )),
      );

      state = state.copyWith(
        isSaving: false,
        saveTick: state.saveTick + 1,
        budgetAlert: budgetAlertName,
        anomalyAlert: anomalyAlertName,
        completedChallengeNames: completedNames,
      );
    } catch (_) {
      state = state.copyWith(isSaving: false, error: TxErrorCode.saveFailed);
    }
  }
}

extension StreakStateX on StreakState {
  String get label => '$currentDays';
}
