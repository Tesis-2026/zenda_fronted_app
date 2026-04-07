import 'package:dio/dio.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor(this._tokenStorage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _tokenStorage.readToken();
    
    if (token != null && token.isNotEmpty) {
      print('🔑 [AuthInterceptor] Token inyectado en petición a: ${options.path}');
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      print('⚠️ [AuthInterceptor] NO HAY TOKEN. La petición a ${options.path} fallará con 401.');
    }
    
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';

    return super.onRequest(options, handler);
  }
}
