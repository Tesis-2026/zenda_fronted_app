import '../models/transaction.dart';
import 'api_client.dart';

/// Maps local TransactionCategory to backend category name (English, matching seed).
String categoryToApiName(TransactionCategory c) {
  return switch (c) {
    TransactionCategory.comida => 'Food',
    TransactionCategory.transporte => 'Transportation',
    TransactionCategory.vivienda => 'Housing',
    TransactionCategory.servicios => 'Utilities',
    TransactionCategory.salud => 'Health',
    TransactionCategory.ocio => 'Entertainment',
    TransactionCategory.compras => 'Shopping',
    TransactionCategory.suscripciones => 'Subscriptions',
    TransactionCategory.antojos => 'Cravings',
    TransactionCategory.ahorro => 'Savings',
    TransactionCategory.otros => 'Other',
  };
}

class TransactionApiService {
  Future<void> create({
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
  }) async {
    // Only EXPENSE and INCOME map to the backend (transfers are local-only).
    if (kind == TransactionKind.transfer) return;
    await ApiClient.post(
      '/transactions',
      {
        'type': kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
        'amount': amount,
        'newCategoryName': categoryToApiName(category),
        'description': description ?? '',
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      },
      authenticated: true,
    );
  }

  Future<List<Map<String, dynamic>>> getAll({
    String? type, // 'INCOME' or 'EXPENSE'
    String? from,
    String? to,
  }) async {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;

    final query = params.isEmpty
        ? ''
        : '?' + params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final body = await ApiClient.getList('/transactions$query');
    return body.cast<Map<String, dynamic>>();
  }
}
