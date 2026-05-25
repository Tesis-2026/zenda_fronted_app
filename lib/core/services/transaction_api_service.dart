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

TransactionCategory? categoryFromApiName(String? name) {
  if (name == null) return null;
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

typedef CreateTransactionResult = ({
  List<String> completedChallenges,
  String? anomalyAlert,
});

/// Raw output of the AI classify call. The screen uses [category] to
/// render the suggestion chip; the controller persists [categoryName]
/// + [confidence] so they can be threaded back to the backend on save
/// (lets the BE derive `categorySource` = AI / AI_OVERRIDDEN / USER).
typedef ClassifyResult = ({
  TransactionCategory? category,
  String categoryName,
  double confidence,
});

class TransactionApiService {
  // Cache of lowercase category name → category UUID from the backend.
  // Populated once per app session; prevents a name-based DB lookup on every
  // transaction write by sending categoryId directly.
  static Map<String, String>? _categoryIdCache;

  static Future<Map<String, String>> _getCategoryCache() async {
    if (_categoryIdCache != null) return _categoryIdCache!;
    try {
      final list = await ApiClient.getList('/categories');
      _categoryIdCache = {
        for (final item in list.cast<Map<String, dynamic>>())
          (item['name'] as String).toLowerCase(): item['id'] as String,
      };
    } catch (_) {
      _categoryIdCache = {};
    }
    return _categoryIdCache!;
  }

  Future<CreateTransactionResult> create({
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
    String? customCategoryName,
    // AI provenance (Integration fix #4). When the user accepted an AI
    // suggestion at any point during this draft, the controller passes
    // the original suggested category name + confidence here so the
    // backend can derive `categorySource` = AI (final == suggestion)
    // or AI_OVERRIDDEN (user later changed the category).
    String? aiSuggestedCategoryName,
    double? aiConfidence,
  }) async {
    // Transfers are local-only; no backend call needed.
    if (kind == TransactionKind.transfer) {
      return (completedChallenges: <String>[], anomalyAlert: null);
    }

    final apiName = customCategoryName ?? categoryToApiName(category);
    final cache = await _getCategoryCache();
    final categoryId = cache[apiName.toLowerCase()];

    final body = <String, dynamic>{
      'type': kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
      'amount': amount,
      'description': description ?? '',
      'occurredAt': occurredAt.toUtc().toIso8601String(),
    };
    if (categoryId != null) {
      body['categoryId'] = categoryId;
    } else {
      body['newCategoryName'] = apiName;
    }

    // suggestedCategoryId + aiConfidence MUST be sent together (the
    // backend rejects with 400 when only one is present). We can only
    // resolve the suggestion to a UUID if it's a known seed category;
    // for AI suggestions that map to a brand-new category we silently
    // drop the suggestion fields to avoid the paired-field violation.
    if (aiSuggestedCategoryName != null && aiConfidence != null) {
      final suggestedId = cache[aiSuggestedCategoryName.toLowerCase()];
      if (suggestedId != null) {
        body['suggestedCategoryId'] = suggestedId;
        body['aiConfidence'] = aiConfidence;
      }
    }

    final json = await ApiClient.post('/transactions', body, authenticated: true);

    final rawChallenges = json['newlyCompletedChallenges'];
    final completedChallenges =
        rawChallenges is List ? rawChallenges.cast<String>() : <String>[];

    final rawAnomaly = json['anomalyAlert'];
    final anomalyAlert = rawAnomaly is Map
        ? rawAnomaly['categoryName'] as String?
        : null;

    return (completedChallenges: completedChallenges, anomalyAlert: anomalyAlert);
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

    final apiName = categoryToApiName(category);
    final cache = await _getCategoryCache();
    final categoryId = cache[apiName.toLowerCase()];

    final body = <String, dynamic>{
      'type': kind == TransactionKind.income ? 'INCOME' : 'EXPENSE',
      'amount': amount,
      'description': description ?? '',
      'occurredAt': occurredAt.toUtc().toIso8601String(),
    };
    if (categoryId != null) {
      body['categoryId'] = categoryId;
    } else {
      body['newCategoryName'] = apiName;
    }

    await ApiClient.put('/transactions/$id', body);
  }

  Future<void> deleteTransaction(String id) async {
    await ApiClient.delete('/transactions/$id');
  }

  Future<ClassifyResult?> classify({
    required String description,
    required double amount,
  }) async {
    try {
      final json = await ApiClient.post(
        '/transactions/classify',
        {'description': description, 'amount': amount},
        authenticated: true,
      );
      final name = json['categoryName'] as String?;
      if (name == null) return null;
      final confidence = (json['confidence'] as num?)?.toDouble() ?? 0.0;
      return (
        category: categoryFromApiName(name),
        categoryName: name,
        confidence: confidence,
      );
    } catch (_) {
      return null;
    }
  }
}
