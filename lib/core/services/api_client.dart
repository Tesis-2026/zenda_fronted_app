import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String _kBaseUrl = 'https://5af7-181-65-1-2.ngrok-free.app/api';

const String _kAccessTokenKey = 'zenda.access_token';
const String _kRefreshTokenKey = 'zenda.refresh_token';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

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

  /// Attempts to exchange the stored refresh token for a new token pair.
  /// Returns true and saves new tokens on success; returns false on failure.
  static Future<bool> _tryRefresh() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_kBaseUrl/auth/refresh'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

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
    }

    // Refresh failed: clear all tokens to force re-login
    await deleteTokens();
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
      return {};
    }
  }

  static void _throwIfError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final body = _parseBody(response);
    final message = (body['message'] as String?) ?? 'Unexpected error';
    throw ApiException(statusCode: response.statusCode, message: message);
  }

  static void _log(String method, String url, int statusCode) {
    developer.log(
      '[$method] $url → $statusCode',
      name: 'ApiClient',
    );
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
  }) async {
    final url = '$_kBaseUrl$path';
    final headers = authenticated
        ? await _authHeaders()
        : {HttpHeaders.contentTypeHeader: 'application/json'};

    try {
      var response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 401 && authenticated) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          final retryHeaders = await _authHeaders();
          response = await http.post(
            Uri.parse(url),
            headers: retryHeaders,
            body: jsonEncode(body),
          );
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

  static Future<Map<String, dynamic>> get(String path) async {
    final url = '$_kBaseUrl$path';
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.get(
            Uri.parse(url),
            headers: await _authHeaders(),
          );
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
      var response = await http.put(
        Uri.parse(url),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.put(
            Uri.parse(url),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          );
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
      var response = await http.patch(
        Uri.parse(url),
        headers: await _authHeaders(),
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.patch(
            Uri.parse(url),
            headers: await _authHeaders(),
            body: jsonEncode(body),
          );
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
      var response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.get(
            Uri.parse(url),
            headers: await _authHeaders(),
          );
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
      var response = await http.delete(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.delete(
            Uri.parse(url),
            headers: await _authHeaders(),
          );
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
      var response = await http.get(
        Uri.parse(url),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 401) {
        final refreshed = await _tryRefresh();
        if (refreshed) {
          response = await http.get(
            Uri.parse(url),
            headers: await _authHeaders(),
          );
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
