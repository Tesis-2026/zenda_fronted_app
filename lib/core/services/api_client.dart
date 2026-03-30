import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Production URL must use HTTPS. Dev builds target the local emulator over HTTP.
// Replace _kProdBaseUrl with your deployed API URL before shipping.
const String _kProdBaseUrl = 'https://api.zenda.pe/api';
const String _kDevBaseUrl = kIsWeb
    ? 'http://localhost:3000/api'
    : 'http://10.0.2.2:3000/api';

const String _kBaseUrl = kReleaseMode ? _kProdBaseUrl : _kDevBaseUrl;

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

  // ── HTTP verbs ───────────────────────────────────────────────────

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool authenticated = false,
  }) async {
    final headers = authenticated
        ? await _authHeaders()
        : {HttpHeaders.contentTypeHeader: 'application/json'};

    var response = await http.post(
      Uri.parse('$_kBaseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && authenticated) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _authHeaders();
        response = await http.post(
          Uri.parse('$_kBaseUrl$path'),
          headers: retryHeaders,
          body: jsonEncode(body),
        );
      }
    }

    _throwIfError(response);
    return _parseBody(response);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    var response = await http.get(
      Uri.parse('$_kBaseUrl$path'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.get(
          Uri.parse('$_kBaseUrl$path'),
          headers: await _authHeaders(),
        );
      }
    }

    _throwIfError(response);
    return _parseBody(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    var response = await http.put(
      Uri.parse('$_kBaseUrl$path'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.put(
          Uri.parse('$_kBaseUrl$path'),
          headers: await _authHeaders(),
          body: jsonEncode(body),
        );
      }
    }

    _throwIfError(response);
    return _parseBody(response);
  }

  static Future<List<dynamic>> getList(String path) async {
    var response = await http.get(
      Uri.parse('$_kBaseUrl$path'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.get(
          Uri.parse('$_kBaseUrl$path'),
          headers: await _authHeaders(),
        );
      }
    }

    _throwIfError(response);
    if (response.body.isEmpty) return [];
    try {
      return jsonDecode(response.body) as List<dynamic>;
    } catch (_) {
      return [];
    }
  }

  static Future<void> delete(String path) async {
    var response = await http.delete(
      Uri.parse('$_kBaseUrl$path'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.delete(
          Uri.parse('$_kBaseUrl$path'),
          headers: await _authHeaders(),
        );
      }
    }

    _throwIfError(response);
  }

  static Future<List<int>> getBytes(String path) async {
    var response = await http.get(
      Uri.parse('$_kBaseUrl$path'),
      headers: await _authHeaders(),
    );

    if (response.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        response = await http.get(
          Uri.parse('$_kBaseUrl$path'),
          headers: await _authHeaders(),
        );
      }
    }

    _throwIfError(response);
    return response.bodyBytes;
  }
}
