import 'package:dio/dio.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_result_model.dart';
import 'dart:convert';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource({required this.dio});

  Future<AuthResultModel> register(String email, String password, String fullName) async {
    try {
      print('🚀 [AuthRemoteDataSource] Intentando Register API: ${dio.options.baseUrl}/auth/register');
      print('📦 [Payload enviado]: {"email": "$email", "fullName": "$fullName", "password": "***"}');

      final response = await dio.post(
        '/auth/register',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
          'fullName': fullName.trim(),
        },
      );

      print('✅ [Register Exitoso] RAW Response: ${response.data}');
      return _parseResponse(response);
    } on DioException catch (e) {
      print('❌ [Register DioError] CODE: ${e.response?.statusCode} MSG: ${e.message} DATA: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [Register Fatal Error] Exception: $e');
      rethrow;
    }
  }

  Future<AuthResultModel> login(String email, String password) async {
    try {
      print('🚀 [AuthRemoteDataSource] Intentando Login API: ${dio.options.baseUrl}/auth/login');
      print('📦 [Payload enviado]: {"email": "$email", "password": "***"}');

      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
      );

      print('✅ [Login Exitoso] RAW Response: ${response.data}');
      return _parseResponse(response);
    } on DioException catch (e) {
      print('❌ [Login DioError] CODE: ${e.response?.statusCode} MSG: ${e.message} DATA: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ [Login Fatal Error] Exception: $e');
      rethrow;
    }
  }

  AuthResultModel _parseResponse(Response response) {
    if (response.data is String) {
      try {
        final decoded = json.decode(response.data);
        return AuthResultModel.fromJson(decoded);
      } catch (_) {
        return AuthResultModel.fromJson({}, defaultToken: response.data.toString().trim());
      }
    } else if (response.data is Map<String, dynamic>) {
      return AuthResultModel.fromJson(response.data);
    }
    throw ServerException('Formato de respuesta desconocido');
  }

  ServerException _handleDioError(DioException error) {
    if (error.response?.data != null) {
      if (error.response?.data is Map) {
        final data = error.response!.data as Map<String, dynamic>;
        return ServerException(data['message'] ?? data['error'] ?? 'Credenciales incorrectas');
      }
    }
    return ServerException(error.message ?? 'Error inexperado de red');
  }
}
