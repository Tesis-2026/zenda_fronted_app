import '../errors/error_codes.dart';
import '../models/user.dart';
import 'api_client.dart';

/// Lockout state extracted from a 401 login response body (B14 / B11).
/// Null when the response did not carry lockout fields (e.g. user-not-found
/// case, which deliberately omits them to prevent email enumeration).
class LockoutInfo {
  final int? failedAttempts;
  final int? attemptsRemaining;
  final DateTime? lockedUntil;

  const LockoutInfo({
    this.failedAttempts,
    this.attemptsRemaining,
    this.lockedUntil,
  });

  bool get isLocked {
    final until = lockedUntil;
    return until != null && until.isAfter(DateTime.now());
  }

  /// Parses the 401 body produced by `POST /auth/login` (B14). Returns null
  /// when the body has no lockout fields.
  static LockoutInfo? fromErrorBody(Map<String, dynamic> body) {
    final hasAny = body.containsKey('failedAttempts') ||
        body.containsKey('attemptsRemaining') ||
        body.containsKey('lockedUntil');
    if (!hasAny) return null;
    final lockedRaw = body['lockedUntil'];
    return LockoutInfo(
      failedAttempts: (body['failedAttempts'] as int?),
      attemptsRemaining: (body['attemptsRemaining'] as int?),
      lockedUntil: lockedRaw is String && lockedRaw.isNotEmpty
          ? DateTime.tryParse(lockedRaw)
          : null,
    );
  }
}

class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;
  final LockoutInfo? lockout;

  AuthResult._({this.user, this.error, required this.isSuccess, this.lockout});

  factory AuthResult.success(User user) =>
      AuthResult._(user: user, isSuccess: true);

  factory AuthResult.error(String message, {LockoutInfo? lockout}) =>
      AuthResult._(error: message, isSuccess: false, lockout: lockout);
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

      await ApiClient.saveTokens(
        accessToken: tokenBody['accessToken'] as String,
        refreshToken: tokenBody['refreshToken'] as String,
      );

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

      await ApiClient.saveTokens(
        accessToken: tokenBody['accessToken'] as String,
        refreshToken: tokenBody['refreshToken'] as String,
      );

      final profileBody = await ApiClient.get('/users/me');
      return AuthResult.success(User.fromJson(profileBody));
    } on ApiException catch (e) {
      // 401 may carry lockout state (failedAttempts/attemptsRemaining/
      // lockedUntil) per B14 — surface it so the login screen can render
      // a server-authoritative countdown (B11).
      final lockout = e.statusCode == 401 ? LockoutInfo.fromErrorBody(e.body) : null;
      return AuthResult.error(_mapError(e), lockout: lockout);
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

  Future<void> logout() async {
    try {
      // Revoke all refresh tokens on the server before clearing local storage
      await ApiClient.post('/auth/logout', {}, authenticated: true);
    } catch (_) {
      // Best-effort — always clear local tokens even if the server call fails
    }
    await ApiClient.deleteTokens();
  }

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

  Future<AuthResult> sendOtp(String email) async {
    try {
      await ApiClient.post('/auth/send-otp', {'email': email});
      return AuthResult.success(User(id: '', name: '', email: email));
    } on ApiException catch (e) {
      return AuthResult.error(_mapError(e));
    } catch (_) {
      return AuthResult.error(AuthErrorCode.noConnection);
    }
  }

  /// Returns the resetToken on success (store it for the reset-password step).
  Future<String?> verifyOtp({required String email, required String code}) async {
    try {
      final response = await ApiClient.post('/auth/verify-otp', {'email': email, 'code': code});
      return response['resetToken'] as String?;
    } catch (_) {
      return null;
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
    // 401 may be either invalid credentials OR account-locked (B14 attaches
    // `lockedUntil` to the body in the locked case). Use the body to
    // distinguish, fall back to message-substring for legacy responses.
    if (e.statusCode == 401) {
      final lockedUntil = e.body['lockedUntil'];
      if (lockedUntil is String && lockedUntil.isNotEmpty) {
        return AuthErrorCode.accountLocked;
      }
      if (e.message.toLowerCase().contains('locked')) {
        return AuthErrorCode.accountLocked;
      }
      return AuthErrorCode.invalidCredentials;
    }
    return switch (e.statusCode) {
      409 => AuthErrorCode.emailTaken,
      404 => AuthErrorCode.tokenExpired,
      400 => e.message.toLowerCase().contains('locked')
          ? AuthErrorCode.accountLocked
          : '${AuthErrorCode.badRequest}|${e.message}',
      _ => AuthErrorCode.serverError,
    };
  }
}
