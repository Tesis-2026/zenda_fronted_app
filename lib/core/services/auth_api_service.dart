import '../models/user.dart';
import 'api_client.dart';

class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.user, this.error, required this.isSuccess});

  factory AuthResult.success(User user) =>
      AuthResult._(user: user, isSuccess: true);

  factory AuthResult.error(String message) =>
      AuthResult._(error: message, isSuccess: false);
}

class AuthApiService {
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final tokenBody = await ApiClient.post('/auth/register', {
        'fullName': name,
        'email': email,
        'password': password,
      });

      final accessToken = tokenBody['accessToken'] as String;
      await ApiClient.saveToken(accessToken);

      final profileBody = await ApiClient.get('/users/me');
      return AuthResult.success(User.fromJson(profileBody));
    } on ApiException catch (e) {
      return AuthResult.error(_mapError(e));
    } catch (_) {
      return AuthResult.error('No se pudo conectar con el servidor');
    }
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenBody = await ApiClient.post('/auth/login', {
        'email': email,
        'password': password,
      });

      final accessToken = tokenBody['accessToken'] as String;
      await ApiClient.saveToken(accessToken);

      final profileBody = await ApiClient.get('/users/me');
      return AuthResult.success(User.fromJson(profileBody));
    } on ApiException catch (e) {
      return AuthResult.error(_mapError(e));
    } catch (_) {
      return AuthResult.error('No se pudo conectar con el servidor');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final token = await ApiClient.getToken();
      if (token == null) return null;
      final body = await ApiClient.get('/users/me');
      return User.fromJson(body);
    } catch (_) {
      return null;
    }
  }

  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  Future<void> logout() => ApiClient.deleteToken();

  Future<AuthResult> forgotPassword(String email) async {
    try {
      await ApiClient.post('/auth/forgot-password', {'email': email});
      return AuthResult.success(
        User(id: '', name: '', email: email),
      );
    } on ApiException catch (e) {
      return AuthResult.error(_mapError(e));
    } catch (_) {
      return AuthResult.error('No se pudo conectar con el servidor');
    }
  }

  Future<AuthResult> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await ApiClient.post('/auth/reset-password', {
        'token': token,
        'newPassword': newPassword,
      });
      return AuthResult.success(User(id: '', name: '', email: ''));
    } on ApiException catch (e) {
      return AuthResult.error(_mapError(e));
    } catch (_) {
      return AuthResult.error('No se pudo conectar con el servidor');
    }
  }

  String _mapError(ApiException e) {
    switch (e.statusCode) {
      case 401:
        return 'Email o contraseña incorrectos';
      case 409:
        return 'Este email ya está registrado';
      case 404:
        return 'Token inválido o expirado';
      case 400:
        return e.message;
      default:
        return 'Error inesperado. Inténtalo de nuevo';
    }
  }
}
