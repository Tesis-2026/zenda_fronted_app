import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';

/// Backend base URL. Resolved per flavor through [AppConfig] (set via
/// `--dart-define-from-file=dart_defines/<flavor>.json` or `--dart-define`).
/// Targets:
///   Windows desktop / web (Chrome,Edge) / iOS simulator: http://localhost:3000/api
///   Android emulator: http://10.0.2.2:3000/api
///   Physical device: http://YOUR-LAN-IP:3000/api  (or an ngrok tunnel)
const String _kBaseUrl = AppConfig.apiBaseUrl;

const String _kAccessTokenKey = 'zenda.access_token';
const String _kRefreshTokenKey = 'zenda.refresh_token';
const Duration _kRequestTimeout = Duration(seconds: 30);

class ApiException implements Exception {
  final int statusCode;
  final String message;

  /// Full parsed JSON body of the error response. Lets callers read
  /// contextual fields the server attaches (e.g. `failedAttempts`,
  /// `lockedUntil` on a login 401 — see B14). May be empty when the
  /// server returns no body or the body is not JSON.
  final Map<String, dynamic> body;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.body = const {},
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ── Session expired signal ────────────────────────────────────────
  // Emits when a token refresh fails so the auth notifier can force logout.
  static final StreamController<void> _sessionExpiredController =
      StreamController<void>.broadcast();
  static Stream<void> get onSessionExpired => _sessionExpiredController.stream;

  // ── Token helpers ────────────────────────────────────────────────

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessTokenKey, value: accessToken),
      _storage.write(key: _kRefreshTokenKey, value: refreshToken),
    ]);
  }

  static Future<void> saveToken(String token) =>
      _storage.write(key: _kAccessTokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _kAccessTokenKey);

  static Future<String?> getRefreshToken() =>
      _storage.read(key: _kRefreshTokenKey);

  static Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessTokenKey),
      _storage.delete(key: _kRefreshTokenKey),
    ]);
  }

  /// Kept for backwards compatibility — deletes both tokens.
  static Future<void> deleteToken() => deleteTokens();

  // ── Token refresh ────────────────────────────────────────────────

  static bool _refreshInProgress = false;

  /// Attempts to exchange the stored refresh token for a new token pair.
  /// Returns true and saves new tokens on success; returns false on failure.
  static Future<bool> _tryRefresh() async {
    if (_refreshInProgress) return false;
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      _sessionExpiredController.add(null);
      return false;
    }

    _refreshInProgress = true;
    try {
      final response = await http
          .post(
            Uri.parse('$_kBaseUrl/auth/refresh'),
            headers: {HttpHeaders.contentTypeHeader: 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(_kRequestTimeout);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        await saveTokens(
          accessToken: body['accessToken'] as String,
          refreshToken: body['refreshToken'] as String,
        );
        return true;
      }
    } catch (_) {
      // Network error during refresh — treat as failure
    } finally {
      _refreshInProgress = false;
    }

    // Refresh failed: clear tokens and notify listeners to redirect to login.
    await deleteTokens();
    _sessionExpiredController.add(null);
    return false;
  }

  // ── Request helpers ──────────────────────────────────────────────

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
    };
  }

  static Map<String, dynamic> _parseBody(http.Response response) {
    if (response.body.isEmpty) return {};
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      developer.log(
        'Non-JSON response body: ${response.body}',
        name: 'ApiClient',
        level: 800,
      );
      return {};
    }
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final body = _parseBody(response);
    // NestJS class-validator returns message as List<String>; other errors return String.
    final raw = body['message'];
    final message = raw is List
        ? raw.cast<Object>().join('; ')
        : (raw as String?) ?? 'Error inesperado';
    throw ApiException(
      statusCode: response.statusCode,
      message: message,
      body: body,
    );
  }

  static void _log(String method, String url, int statusCode) {
    developer.log('[$method] $url → $statusCode', name: 'ApiClient');
  }

  static void _logError(String method, String url, Object error) {
    developer.log(
      '[$method] $url → ERROR: $error',
      name: 'ApiClient',
      level: 900,
    );
  }

  // ── HTTP verbs ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
    String? idempotencyKey,
  }) async {
    final url = '$_kBaseUrl$path';
    final headers = authenticated
        ? await _authHeaders()
        : {HttpHeaders.contentTypeHeader: 'application/json'};
    // Idempotency-Key (B28) lets the server dedupe automatic retries —
    // a mobile network glitch that succeeds on retry should NOT create
    // a duplicate transaction. The key must be stable per logical
    // action (caller's responsibility); the server caches the first
    // response and replays it on subsequent calls with the same key.
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['idempotency-key'] = idempotencyKey;
    }

    try {
      var response = await http
          .post(Uri.parse(url), headers: headers, body: jsonEncode(body))
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401 && authenticated) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .post(
                Uri.parse(url),
                headers: await _authHeaders(),
                body: jsonEncode(body),
              )
              .timeout(_kRequestTimeout);
        }
      }

      _log('POST', url, response.statusCode);
      _throwIfError(response);
      return _parseBody(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('POST', url, e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> postMultipart(
    String path, {
    required String fieldName,
    required List<int> bytes,
    required String filename,
    required String contentType,
    bool authenticated = true,
  }) async {
    final url = '$_kBaseUrl$path';

    Future<http.Response> send() async {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      if (authenticated) {
        final headers = await _authHeaders();
        headers.remove(HttpHeaders.contentTypeHeader);
        request.headers.addAll(headers);
      }
      request.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          bytes,
          filename: filename,
          contentType: MediaType.parse(contentType),
        ),
      );
      final streamed = await request.send().timeout(_kRequestTimeout);
      return http.Response.fromStream(streamed).timeout(_kRequestTimeout);
    }

    try {
      var response = await send();

      if (response.statusCode == 401 && authenticated) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await send();
        }
      }

      _log('POST(multipart)', url, response.statusCode);
      _throwIfError(response);
      return _parseBody(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('POST(multipart)', url, e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .get(Uri.parse(url), headers: await _authHeaders())
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .get(Uri.parse(url), headers: await _authHeaders())
              .timeout(_kRequestTimeout);
        }
      }

      _log('GET', url, response.statusCode);
      _throwIfError(response);
      return _parseBody(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('GET', url, e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .put(
            Uri.parse(url),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .put(
                Uri.parse(url),
                headers: await _authHeaders(),
                body: jsonEncode(body),
              )
              .timeout(_kRequestTimeout);
        }
      }

      _log('PUT', url, response.statusCode);
      _throwIfError(response);
      return _parseBody(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('PUT', url, e);
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .patch(
            Uri.parse(url),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          )
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .patch(
                Uri.parse(url),
                headers: await _authHeaders(),
                body: jsonEncode(body),
              )
              .timeout(_kRequestTimeout);
        }
      }

      _log('PATCH', url, response.statusCode);
      _throwIfError(response);
      return _parseBody(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('PATCH', url, e);
      rethrow;
    }
  }

  static Future<List<dynamic>> getList(String path) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .get(Uri.parse(url), headers: await _authHeaders())
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .get(Uri.parse(url), headers: await _authHeaders())
              .timeout(_kRequestTimeout);
        }
      }

      _log('GET(list)', url, response.statusCode);
      _throwIfError(response);
      if (response.body.isEmpty) return [];
      try {
        return jsonDecode(response.body) as List<dynamic>;
      } catch (_) {
        return [];
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('GET(list)', url, e);
      rethrow;
    }
  }

  static Future<void> delete(String path) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .delete(Uri.parse(url), headers: await _authHeaders())
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .delete(Uri.parse(url), headers: await _authHeaders())
              .timeout(_kRequestTimeout);
        }
      }

      _log('DELETE', url, response.statusCode);
      _throwIfError(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('DELETE', url, e);
      rethrow;
    }
  }

  static Future<List<int>> getBytes(String path) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http
          .get(Uri.parse(url), headers: await _authHeaders())
          .timeout(_kRequestTimeout);

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http
              .get(Uri.parse(url), headers: await _authHeaders())
              .timeout(_kRequestTimeout);
        }
      }

      _log('GET(bytes)', url, response.statusCode);
      _throwIfError(response);
      return response.bodyBytes;
    } catch (e) {
      if (e is ApiException) rethrow;
      _logError('GET(bytes)', url, e);
      rethrow;
    }
  }
}
