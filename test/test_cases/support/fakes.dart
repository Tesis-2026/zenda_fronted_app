// Recording test doubles for the UI test cases. They extend the app's demo
// mocks and only add what a case needs to observe or force (captured calls,
// API errors, empty data).
import 'package:zenda_fronted/core/mock/mock_services.dart';
import 'package:zenda_fronted/core/models/category.dart';
import 'package:zenda_fronted/core/models/transaction.dart';
import 'package:zenda_fronted/core/services/api_client.dart';
import 'package:zenda_fronted/core/services/transaction_api_service.dart';

class CreatedTx {
  CreatedTx(this.kind, this.amount, this.category, this.customCategoryName);
  final TransactionKind kind;
  final double amount;
  final TransactionCategory category;
  final String? customCategoryName;
}

class RecordingTransactionService extends MockTransactionApiService {
  RecordingTransactionService({
    this.anomalyCategory,
    this.rows,
    this.classifyResult,
  });

  /// When set, create() reports a spending anomaly for this category.
  final String? anomalyCategory;

  /// When set, getAll() serves these rows (filters applied by the mock).
  final List<Map<String, dynamic>>? rows;

  /// Overrides classify(); null keeps the demo keyword matcher.
  final ClassifyResult? Function(String description)? classifyResult;

  final created = <CreatedTx>[];
  final updated = <({String id, double amount})>[];
  final deleted = <String>[];
  final queries = <Map<String, Object?>>[];

  @override
  Future<CreateTransactionResult> create({
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? budgetId,
    String? accountId,
    String? description,
    String? customCategoryName,
    String? aiSuggestedCategoryName,
    double? aiConfidence,
    String? idempotencyKey,
    String? expectedUserId,
  }) async {
    created.add(CreatedTx(kind, amount, category, customCategoryName));
    return (
      completedChallenges: <String>[],
      anomalyAlert: anomalyCategory,
      anomalyAlertExplanation: anomalyCategory == null
          ? null
          : 'Tu gasto en $anomalyCategory supera tu promedio en 300%.',
    );
  }

  @override
  Future<void> update({
    required String id,
    required TransactionKind kind,
    required double amount,
    required TransactionCategory category,
    required DateTime occurredAt,
    String? description,
    String? accountId,
    String? existingCategoryId,
  }) async {
    updated.add((id: id, amount: amount));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    deleted.add(id);
    rows?.removeWhere((tx) => tx['id'] == id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll({
    String? type,
    String? from,
    String? to,
    String? categoryId,
    String? accountId,
    double? minAmount,
    double? maxAmount,
  }) async {
    queries.add({
      'type': type,
      'from': from,
      'to': to,
      'categoryId': categoryId,
      'minAmount': minAmount,
      'maxAmount': maxAmount,
    });
    final source = rows;
    if (source == null) {
      return super.getAll(
        type: type,
        from: from,
        to: to,
        categoryId: categoryId,
        accountId: accountId,
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
    }
    return source.where((tx) {
      if (type != null && (tx['type'] as String).toUpperCase() != type) {
        return false;
      }
      final amount = (tx['amount'] as num).toDouble();
      if (minAmount != null && amount < minAmount) return false;
      if (maxAmount != null && amount > maxAmount) return false;
      return true;
    }).toList();
  }

  @override
  Future<ClassifyResult?> classify({
    required String description,
    required double amount,
  }) async {
    final override = classifyResult;
    if (override != null) return override(description);
    return super.classify(description: description, amount: amount);
  }
}

/// Category service that rejects duplicate names with 409 like the backend,
/// and refuses deleting categories listed in [withTransactions].
class StrictCategoryService extends MockCategoryApiService {
  StrictCategoryService({this.withTransactions = const {}});
  final Set<String> withTransactions;
  final createdNames = <String>[];
  final renamed = <String, String>{};

  @override
  Future<CategoryModel> create(String name) async {
    final existing = await getAll();
    if (existing.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      throw const ApiException(statusCode: 409, message: 'La categoria ya existe');
    }
    createdNames.add(name);
    return super.create(name);
  }

  @override
  Future<CategoryModel> rename(String id, String name) async {
    renamed[id] = name;
    return super.rename(id, name);
  }

  @override
  Future<void> delete(String id) async {
    if (withTransactions.contains(id)) {
      throw const ApiException(
        statusCode: 409,
        message: 'No se puede eliminar una categoria con transacciones registradas',
      );
    }
    return super.delete(id);
  }
}

/// A transaction row in the API shape served by [RecordingTransactionService].
Map<String, dynamic> txRow({
  required String id,
  required double amount,
  String type = 'EXPENSE',
  String category = 'Comida',
  String description = 'Movimiento',
  DateTime? at,
}) => {
  'id': id,
  'userId': 'demo-user-1',
  'type': type,
  'amount': amount,
  'currency': 'PEN',
  'description': description,
  'occurredAt': (at ?? DateTime.now()).toIso8601String(),
  'createdAt': (at ?? DateTime.now()).toIso8601String(),
  'category': {'id': 'cat-$category', 'name': category},
  'categoryId': 'cat-$category',
};
