import '../entities/category.dart';
import '../repositories/transaction_repository.dart';

class CreateCategoryUseCase {
  final TransactionRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<Category> call({required String name}) async {
    return await repository.createCategory(name);
  }
}
