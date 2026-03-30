import '../errors/error_codes.dart';
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
      return AuthResult.error(AuthErrorCode.noConnection);
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
      return AuthResult.error(AuthErrorCode.noConnection);
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
      return AuthResult.error(AuthErrorCode.noConnection);
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
      return AuthResult.error(AuthErrorCode.noConnection);
    }
  }

  /// Maps an [ApiException] to a locale-agnostic error code.
  /// Screens resolve codes to localized strings via [AppLocalizations.resolveError].
  String _mapError(ApiException e) {
    return switch (e.statusCode) {
      401 => AuthErrorCode.invalidCredentials,
      409 => AuthErrorCode.emailTaken,
      404 => AuthErrorCode.tokenExpired,
      // 400: pass the backend's validation message as payload after '|'
      // so the UI can display it directly without a translation key.
      400 => '${AuthErrorCode.badRequest}|${e.message}',
      _ => AuthErrorCode.serverError,
    };
  }
}
