import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;

  TransactionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Category>> getCategories() async {
    try {
      final models = await remoteDataSource.getCategories();
      return models; // Models extend Domain Entities
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Error obteniendo categorías de red: $e');
    }
  }

  @override
  Future<Category> createCategory(String name) async {
    try {
      final model = await remoteDataSource.createCategory(name);
      return model;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Error desconocido armando categoria');
    }
  }

  @override
  Future<Transaction> createTransaction({
    required String categoryId,
    required double amount,
    required String description,
    required String type,
    required String currency,
    required DateTime occurredAt,
  }) async {
    try {
      final model = await remoteDataSource.createTransaction(
        categoryId: categoryId,
        amount: amount,
        description: description,
        type: type,
        currency: currency,
        occurredAt: occurredAt,
      );
      return model;
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    } catch (e) {
      throw ServerFailure('Ocurrió un error general creando la transacción');
    }
  }
}
