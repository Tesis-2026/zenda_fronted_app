import 'dart:collection';
import 'package:flutter/material.dart';
import '../core/models/transaction.dart';
import '../core/models/breakdown_503020.dart';

class TransactionsService extends ChangeNotifier {
  final List<TransactionModel> _items = [];
  String _generateId() => DateTime.now().microsecondsSinceEpoch.toString();

  UnmodifiableListView<TransactionModel> get items => UnmodifiableListView(_items);

  void addTransaction({required String userId, required double amount, required TransactionCategory category, required TransactionSource source, String? note}) {
    final bucket = _mapCategoryToBucket(category);
    final tx = TransactionModel(
      id: _generateId(),
      userId: userId,
      accountId: 'unknown',
      kind: TransactionKind.expense,
      amount: amount,
      category: category,
      bucket: bucket,
      timestamp: DateTime.now(),
      note: note,
      source: source,
    );
    _items.add(tx);
    notifyListeners();
  }

  Bucket503020 _mapCategoryToBucket(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.comida:
      case TransactionCategory.transporte:
      case TransactionCategory.vivienda:
      case TransactionCategory.servicios:
      case TransactionCategory.salud:
        return Bucket503020.necesidad;
      case TransactionCategory.ocio:
      case TransactionCategory.compras:
      case TransactionCategory.suscripciones:
      case TransactionCategory.antojos:
      case TransactionCategory.otros:
        return Bucket503020.deseo;
      case TransactionCategory.ahorro:
        return Bucket503020.ahorro;
    }
  }

  BudgetBreakdown503020 calculateBreakdown({DateTime? from, DateTime? to}) {
    final start = from ?? DateTime.now().subtract(const Duration(days: 30));
    final end = to ?? DateTime.now();
    double needs = 0, wants = 0, savings = 0;
    for (final tx in _items) {
      if (tx.timestamp.isAfter(start) && tx.timestamp.isBefore(end.add(const Duration(days: 1)))) {
        switch (tx.bucket) {
          case Bucket503020.necesidad:
            needs += tx.amount;
            break;
          case Bucket503020.deseo:
            wants += tx.amount;
            break;
          case Bucket503020.ahorro:
            savings += tx.amount;
            break;
        }
      }
    }
    return BudgetBreakdown503020(totalNecesidades: needs, totalDeseos: wants, totalAhorro: savings);
  }
}
