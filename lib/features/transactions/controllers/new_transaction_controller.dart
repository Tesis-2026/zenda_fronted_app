import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/error_codes.dart';
import '../../../core/models/account.dart';
import '../../../core/models/transaction.dart';
import '../../../core/services/budget_api_service.dart';
import '../../../core/services/pending_transaction_queue.dart';
import '../../../core/services/streak_repository.dart';
import '../../../providers/repositories_providers.dart';
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
  final String? budgetAlert; // category name at ≥80% after save
  final List<String> completedChallengeNames; // titles of auto-completed challenges

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
    this.completedChallengeNames = const [],
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
    List<String>? completedChallengeNames,
    bool clearError = false,
    bool clearCategory = false,
    bool clearCustomCategory = false,
    bool clearBudgetAlert = false,
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
      completedChallengeNames: completedChallengeNames ?? this.completedChallengeNames,
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
    state = state.copyWith(category: category, clearCustomCategory: true, clearError: true);
  }

  void setCustomCategory(String name) {
    state = state.copyWith(customCategoryName: name, clearCategory: true, clearError: true);
  }

  void setNote(String note) {
    state = state.copyWith(note: note, clearError: true);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date, clearError: true);
  }

  void fillFromOcrDemo() {
    state = state.copyWith(
      amount: 12.50,
      category: TransactionCategory.comida,
      note: 'Cafetería',
      source: TransactionSource.ocr,
      clearError: true,
    );
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
        userId: 'demo',
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
      List<String> completedNames = [];
      try {
        final apiService = ref.read(transactionApiServiceProvider);
        completedNames = await apiService.create(
          kind: kind,
          amount: amount,
          category: effectiveCategory,
          occurredAt: state.date,
          description: state.note.isEmpty ? null : state.note,
          customCategoryName: customName,
        );

        // Check if any budget crossed the 80% threshold after this expense.
        if (kind == TransactionKind.expense) {
          final now = state.date;
          final budgets = await BudgetApiService()
              .getAll(month: now.month, year: now.year);
          final triggered = budgets.where(
            (b) => b.percentageUsed >= 0.80 && b.percentageUsed < 1.0,
          );
          if (triggered.isNotEmpty) {
            budgetAlertName = triggered.first.categoryName ?? 'Budget';
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
        ));
      }

      // Update streak only on save.
      await streakRepo.updateOnTransaction(state.date);

      // Trigger dashboard refresh (providers are currently FutureProviders).
      ref.invalidate(accountsProvider);
      ref.invalidate(transactionsProvider);
      ref.invalidate(streakStateProvider);

      state = state.copyWith(
        isSaving: false,
        saveTick: state.saveTick + 1,
        budgetAlert: budgetAlertName,
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
