import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Base URL: Android emulator uses 10.0.2.2, iOS simulator uses localhost
const String _kBaseUrl = kIsWeb
    ? 'http://localhost:3000/api'
    : 'http://10.0.2.2:3000/api';

const String _kTokenKey = 'zenda.access_token';

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

  static Future<void> saveToken(String token) =>
      _storage.write(key: _kTokenKey, value: token);

  static Future<String?> getToken() => _storage.read(key: _kTokenKey);

  static Future<void> deleteToken() => _storage.delete(key: _kTokenKey);

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

    final response = await http.post(
      Uri.parse('$_kBaseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    _throwIfError(response);
    return _parseBody(response);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_kBaseUrl$path'),
      headers: headers,
    );
    _throwIfError(response);
    return _parseBody(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _authHeaders();
    final response = await http.put(
      Uri.parse('$_kBaseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );
    _throwIfError(response);
    return _parseBody(response);
  }
}
