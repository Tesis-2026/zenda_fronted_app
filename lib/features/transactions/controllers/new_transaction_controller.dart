import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_codes.dart';
import '../../../core/models/account.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/pending_transaction_queue.dart';
import '../../../core/services/streak_repository.dart';
import '../../../providers/repositories_providers.dart';
import '../../auth/auth_controller.dart';
import '../../budget/budget_screen.dart';
import '../../dashboard/dashboard_providers.dart';

@immutable
class NewTransactionState {
  final TransactionKind kind;
  final String? fromAccountId;
  final String? toAccountId;
  final double? amount;
  final TransactionCategory? category;
  final String? customCategoryName;
  final String note;
  final DateTime date;
  final TransactionSource source;
  final bool isSaving;
  final String? error;
  final int saveTick;
  final String? budgetAlert; // category name at ≥80% after save (US-020)
  final String? anomalyAlert; // category name when spending >20% over avg (US-016)
  final List<String> completedChallengeNames; // titles of auto-completed challenges
  // AI provenance (Integration fix #4). When the user accepted an AI
  // classify suggestion during this draft, we keep the original name +
  // confidence so they survive subsequent category overrides — the
  // backend uses them to derive AI vs AI_OVERRIDDEN.
  final String? aiSuggestedCategoryName;
  final double? aiConfidence;

  const NewTransactionState({
    required this.kind,
    required this.fromAccountId,
    required this.toAccountId,
    required this.amount,
    required this.category,
    this.customCategoryName,
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
    fromAccountId: null,
    toAccountId: null,
    amount: null,
    category: null,
    customCategoryName: null,
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
    final c = category;
    if (c == null) return null;
    return bucketForCategory(c);
  }

  NewTransactionState copyWith({
    TransactionKind? kind,
    String? fromAccountId,
    String? toAccountId,
    double? amount,
    TransactionCategory? category,
    String? customCategoryName,
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
    bool clearBudgetAlert = false,
    bool clearAnomalyAlert = false,
    bool clearAiSuggestion = false,
  }) {
    return NewTransactionState(
      kind: kind ?? this.kind,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      amount: amount ?? this.amount,
      category: clearCategory ? null : (category ?? this.category),
      customCategoryName: clearCustomCategory ? null : (customCategoryName ?? this.customCategoryName),
      note: note ?? this.note,
      date: date ?? this.date,
      source: source ?? this.source,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
      saveTick: saveTick ?? this.saveTick,
      budgetAlert: clearBudgetAlert ? null : (budgetAlert ?? this.budgetAlert),
      anomalyAlert: clearAnomalyAlert ? null : (anomalyAlert ?? this.anomalyAlert),
      completedChallengeNames: completedChallengeNames ?? this.completedChallengeNames,
      aiSuggestedCategoryName: clearAiSuggestion
          ? null
          : (aiSuggestedCategoryName ?? this.aiSuggestedCategoryName),
      aiConfidence:
          clearAiSuggestion ? null : (aiConfidence ?? this.aiConfidence),
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
    // Clear destination for non-transfer.
    state = state.copyWith(
      kind: kind,
      toAccountId: kind == TransactionKind.transfer ? state.toAccountId : null,
      clearError: true,
    );
  }

  void setFromAccount(String? id) {
    state = state.copyWith(fromAccountId: id, clearError: true);
  }

  void setToAccount(String? id) {
    state = state.copyWith(toAccountId: id, clearError: true);
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
    state = state.copyWith(category: category, clearCustomCategory: true, clearError: true);
  }

  void setCustomCategory(String name) {
    state = state.copyWith(customCategoryName: name, clearCategory: true, clearError: true);
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
    state = state.copyWith(date: date, clearError: true);
  }

  Future<void> save() async {
    final fromId = state.fromAccountId;
    if (fromId == null || fromId.isEmpty) {
      state = state.copyWith(error: TxErrorCode.noSourceAccount);
      return;
    }

    final amount = state.amount;
    if (amount == null || amount <= 0) {
      state = state.copyWith(error: TxErrorCode.invalidAmount);
      return;
    }

    final category = state.category;
    final customName = state.customCategoryName;
    if (category == null && (customName == null || customName.isEmpty)) {
      state = state.copyWith(error: TxErrorCode.noCategory);
      return;
    }
    final effectiveCategory = category ?? TransactionCategory.otros;

    final kind = state.kind;
    final toId = state.toAccountId;
    if (kind == TransactionKind.transfer) {
      if (toId == null || toId.isEmpty) {
        state = state.copyWith(error: TxErrorCode.noDestAccount);
        return;
      }
      if (toId == fromId) {
        state = state.copyWith(error: TxErrorCode.sameAccount);
        return;
      }
    }

    state = state.copyWith(isSaving: true, clearError: true);

    try {
      final accountsRepo = ref.read(accountsRepositoryProvider);
      final txRepo = ref.read(transactionsRepositoryProvider);
      final streakRepo = ref.read(streakRepositoryProvider);

      final from = await accountsRepo.getById(fromId);
      if (from == null) {
        state = state.copyWith(
          isSaving: false,
          error: TxErrorCode.invalidSourceAccount,
        );
        return;
      }

      Account? to;
      if (kind == TransactionKind.transfer) {
        to = await accountsRepo.getById(toId!);
        if (to == null) {
          state = state.copyWith(
            isSaving: false,
            error: TxErrorCode.invalidDestAccount,
          );
          return;
        }
      }

      final updates = await _applyAccountRules(
        kind: kind,
        from: from,
        to: to,
        amount: amount,
      );

      if (updates.errorMessage != null) {
        state = state.copyWith(isSaving: false, error: updates.errorMessage);
        return;
      }

      await accountsRepo.upsertMany(updates.updatedAccounts);

      final tx = TransactionModel(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        userId: ref.read(authNotifierProvider).user?.id ?? '',
        accountId: fromId,
        toAccountId: toId,
        kind: kind,
        amount: amount,
        currency: 'PEN',
        category: effectiveCategory,
        bucket: bucketForCategory(effectiveCategory),
        timestamp: state.date,
        note: state.note.isEmpty ? null : state.note,
        source: state.source,
      );
      await txRepo.addTransaction(tx);

      // Sync to backend; enqueue for retry if offline or unreachable.
      String? budgetAlertName;
      String? anomalyAlertName;
      List<String> completedNames = [];
      try {
        final apiService = ref.read(transactionApiServiceProvider);
        final result = await apiService.create(
          kind: kind,
          amount: amount,
          category: effectiveCategory,
          occurredAt: state.date,
          description: state.note.isEmpty ? null : state.note,
          customCategoryName: customName,
          aiSuggestedCategoryName: state.aiSuggestedCategoryName,
          aiConfidence: state.aiConfidence,
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
      } catch (_) {
        // Offline or unreachable — enqueue for retry when connectivity returns.
        final queue = ref.read(pendingTransactionQueueProvider);
        await queue.enqueue(PendingSyncEntry(
          txId: tx.id,
          kind: kind,
          amount: amount,
          category: effectiveCategory,
          occurredAt: state.date,
          description: state.note.isEmpty ? null : state.note,
          customCategoryName: customName,
          aiSuggestedCategoryName: state.aiSuggestedCategoryName,
          aiConfidence: state.aiConfidence,
        ));
      }

      // Update streak only on save.
      await streakRepo.updateOnTransaction(state.date);

      // Trigger dashboard refresh (providers are currently FutureProviders).
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(streakStateProvider);
      ref.invalidate(daySummaryProvider);
      ref.invalidate(weekSummaryProvider);
      ref.invalidate(monthSummaryProvider);

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

  Future<_AccountUpdates> _applyAccountRules({
    required TransactionKind kind,
    required Account from,
    required Account? to,
    required double amount,
  }) async {
    // Rules summary:
    // - cash/debit: expense -amount, income +amount, transfer -amount.
    // - credit:
    //   - expense increases debt (available decreases).
    //   - income decreases debt (available increases) (treated as payment).
    //   - transfer from credit is blocked (demo).
    // - transfer to credit from cash/debit: treated as payment to card.

    if (kind == TransactionKind.transfer && from.type == AccountType.credit) {
      return const _AccountUpdates(
        updatedAccounts: <Account>[],
        errorMessage: TxErrorCode.creditTransferNotSupported,
      );
    }

    final updated = <Account>[];

    if (kind == TransactionKind.expense) {
      if (from.type == AccountType.credit) {
        updated.add(from.applyCreditDebtDelta(amount));
      } else {
        updated.add(from.applyBalanceDelta(-amount));
      }
      return _AccountUpdates(updatedAccounts: updated);
    }

    if (kind == TransactionKind.income) {
      if (from.type == AccountType.credit) {
        // Rule: income into credit is treated as payment.
        updated.add(from.applyCreditDebtDelta(-amount));
      } else {
        updated.add(from.applyBalanceDelta(amount));
      }
      return _AccountUpdates(updatedAccounts: updated);
    }

    // transfer
    if (to == null) {
      return const _AccountUpdates(
        updatedAccounts: <Account>[],
        errorMessage: TxErrorCode.noDestAccount,
      );
    }

    if (from.type != AccountType.credit) {
      updated.add(from.applyBalanceDelta(-amount));
    }

    if (to.type == AccountType.credit) {
      updated.add(to.applyCreditDebtDelta(-amount));
    } else {
      updated.add(to.applyBalanceDelta(amount));
    }

    return _AccountUpdates(updatedAccounts: updated);
  }
}

class _AccountUpdates {
  final List<Account> updatedAccounts;
  final String? errorMessage;

  const _AccountUpdates({required this.updatedAccounts, this.errorMessage});
}

extension StreakStateX on StreakState {
  String get label => '$currentDays';
}
