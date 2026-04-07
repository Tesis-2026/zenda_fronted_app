import 'package:dio/dio.dart';
import 'api_config.dart';
import 'auth_interceptor.dart';
import '../storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(AuthInterceptor(tokenStorage));
    
    // Optional: add logging interceptor for debugging
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }
}
