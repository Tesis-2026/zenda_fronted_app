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

TransactionCategory? categoryFromApiName(String name) {
  return switch (name.toLowerCase()) {
    'food' => TransactionCategory.comida,
    'transportation' => TransactionCategory.transporte,
    'housing' => TransactionCategory.vivienda,
    'utilities' => TransactionCategory.servicios,
    'health' => TransactionCategory.salud,
    'entertainment' => TransactionCategory.ocio,
    'shopping' => TransactionCategory.compras,
    'subscriptions' => TransactionCategory.suscripciones,
    'cravings' => TransactionCategory.antojos,
    'savings' => TransactionCategory.ahorro,
    _ => TransactionCategory.otros,
  };
}

class TransactionApiService {
  Future<void> create({
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
    String? customCategoryName,
  }) async {
    // Only EXPENSE and INCOME map to the backend (transfers are local-only).
    if (kind == TransactionKind.transfer) return;
    await ApiClient.post(
      '/transactions',
      {
        'type': kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
        'amount': amount,
        'newCategoryName': customCategoryName ?? categoryToApiName(category),
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
    String? categoryId,
  }) async {
    final params = <String, String>{};
    if (type != null) params['type'] = type;
    if (from != null) params['from'] = from;
    if (to != null) params['to'] = to;
    if (categoryId != null) params['categoryId'] = categoryId;

    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final body = await ApiClient.getList('/transactions$query');
    return body.cast<Map<String, dynamic>>();
  }

  Future<void> update({
    required String id,
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
  }) async {
    if (kind == TransactionKind.transfer) return;
    await ApiClient.put(
      '/transactions/$id',
      {
        'type': kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
        'amount': amount,
        'newCategoryName': categoryToApiName(category),
        'description': description ?? '',
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      },
    );
  }

  Future<void> deleteTransaction(String id) async {
    await ApiClient.delete('/transactions/$id');
  }

  Future<TransactionCategory?> classify({
    required String description,
    required double amount,
  }) async {
    try {
      final json = await ApiClient.post(
        '/transactions/classify',
        {'description': description, 'amount': amount},
        authenticated: true,
      );
      final name = json['category'] as String?;
      if (name == null) return null;
      return categoryFromApiName(name);
    } catch (_) {
      return null;
    }
  }
}
