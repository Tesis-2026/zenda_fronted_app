import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  final TransactionRepository repository;

  CreateTransactionUseCase(this.repository);

  Future<Transaction> call({
    required String categoryId,
    required double amount,
    required String description,
    required String type,
    required String currency,
    required DateTime occurredAt,
  }) async {
    return await repository.createTransaction(
      categoryId: categoryId,
      amount: amount,
      description: description,
      type: type,
      currency: currency,
      occurredAt: occurredAt,
    );
  }
}
