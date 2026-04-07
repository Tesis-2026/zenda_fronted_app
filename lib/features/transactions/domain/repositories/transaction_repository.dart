import '../entities/category.dart';
import '../entities/transaction.dart';

abstract class TransactionRepository {
  Future<List<Category>> getCategories();
  Future<Category> createCategory(String name);
  Future<Transaction> createTransaction({
    required String categoryId,
    required double amount,
    required String description,
    required String type,
    required String currency,
    required DateTime occurredAt,
  });
}
