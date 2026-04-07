import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDataSource {
  final Dio dio;

  TransactionRemoteDataSource({required this.dio});

  Future<List<CategoryModel>> getCategories() async {
    try {
      print('🚀 [TransactionDataSource] Obteniendo /api/categories...');
      final response = await dio.get('/categories');
      print('✅ [API Categories] Data: ${response.data}');

      if (response.data is List) {
        return (response.data as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (response.data is Map && response.data.containsKey('data')) { // Soporta wrap paginado
        return (response.data['data'] as List)
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      print('❌ [API Categories DioError]: ${e.message} DATA: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  Future<CategoryModel> createCategory(String name) async {
    try {
      print('🚀 [TransactionDataSource] Creando Categoría: $name');
      final response = await dio.post(
        '/categories',
        data: {'name': name.trim()},
      );
      print('✅ [Categoría Creada] Response: ${response.data}');
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<TransactionModel> createTransaction({
    required String categoryId,
    required double amount,
    required String description,
    required String type,
    required String currency,
    required DateTime occurredAt,
  }) async {
    try {
      print('🚀 [TransactionDataSource] Creando Transacción de $amount en /api/transactions');
      final payload = {
        'categoryId': categoryId,
        'amount': amount,
        'description': description.trim(),
        'type': type,
        'currency': currency,
        'occurredAt': occurredAt.toUtc().toIso8601String(),
      };
      print('📦 Payload Transaction: $payload');

      final response = await dio.post(
        '/transactions',
        data: payload,
      );

      print('✅ [Transacción Creada] RAW: ${response.data}');
      return TransactionModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ [API Transaction Error]: ${e.response?.statusCode} ${e.message} \nDATA: ${e.response?.data}');
      throw _handleDioError(e);
    }
  }

  ServerException _handleDioError(DioException error) {
    if (error.response?.data != null && error.response!.data is Map) {
      final data = error.response!.data as Map<String, dynamic>;
      final msg = data['message'] ?? data['error'] ?? 'Error desconocido del servidor';
      return ServerException(msg.toString());
    }
    return ServerException(error.message ?? 'Corte inesperado de red');
  }
}
