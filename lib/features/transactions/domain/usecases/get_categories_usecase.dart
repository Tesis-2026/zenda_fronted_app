import '../entities/category.dart';
import '../repositories/transaction_repository.dart';

class GetCategoriesUseCase {
  final TransactionRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}
