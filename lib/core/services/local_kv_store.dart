import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _secureStorage = FlutterSecureStorage();

class LocalKvStore {
  static const _kAccounts = 'zenda.accounts.v1';
  static const _kTransactions = 'zenda.transactions.v1';
  static const _kStreak = 'zenda.streak.v1';

  Future<List<Map<String, dynamic>>> readJsonList(String key) async {
    final raw = await _secureStorage.read(key: key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return <Map<String, dynamic>>[];
    return decoded
        .whereType<Map>()
        .map((m) => m.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  Future<void> writeJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>?> readJsonMap(String key) async {
    final raw = await _secureStorage.read(key: key);
    if (raw == null || raw.isEmpty) return null;
    final decoded = jsonDecode(raw);
    if (decoded is! Map) return null;
    return decoded.map((k, v) => MapEntry(k.toString(), v));
  }

  Future<void> writeJsonMap(String key, Map<String, dynamic> value) async {
    await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  // Typed keys
  String get accountsKey => _kAccounts;
  String get transactionsKey => _kTransactions;
  String get streakKey => _kStreak;
}
