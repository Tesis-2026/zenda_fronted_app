import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/transaction.dart';

const _secureStorage = FlutterSecureStorage();

class PendingSyncEntry {
  final String txId;
  final TransactionKind kind;
  final double amount;
  final TransactionCategory category;
  final DateTime occurredAt;
  final String? description;
  final String? customCategoryName;

  const PendingSyncEntry({
    required this.txId,
    required this.kind,
    required this.amount,
    required this.category,
    required this.occurredAt,
    this.description,
    this.customCategoryName,
  });

  Map<String, dynamic> toJson() => {
    'txId': txId,
    'kind': kind.name,
    'amount': amount,
    'category': category.name,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
    if (description != null) 'description': description,
    if (customCategoryName != null) 'customCategoryName': customCategoryName,
  };

  factory PendingSyncEntry.fromJson(Map<String, dynamic> json) {
    return PendingSyncEntry(
      txId: json['txId'] as String,
      kind: TransactionKind.values.byName(json['kind'] as String),
      amount: (json['amount'] as num).toDouble(),
      category: TransactionCategory.values.byName(json['category'] as String),
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      description: json['description'] as String?,
      customCategoryName: json['customCategoryName'] as String?,
    );
  }
}

class PendingTransactionQueue {
  static const _key = 'zenda.pending_sync.v1';

  Future<List<PendingSyncEntry>> getAll() async {
    final raw = await _secureStorage.read(key: _key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map>()
        .map((m) => PendingSyncEntry.fromJson(m.map((k, v) => MapEntry(k.toString(), v))))
        .toList();
  }

  Future<void> enqueue(PendingSyncEntry entry) async {
    final all = await getAll();
    if (all.any((e) => e.txId == entry.txId)) return;
    all.add(entry);
    await _save(all);
  }

  Future<void> remove(String txId) async {
    final all = await getAll();
    all.removeWhere((e) => e.txId == txId);
    await _save(all);
  }

  Future<void> _save(List<PendingSyncEntry> entries) async {
    await _secureStorage.write(
      key: _key,
      value: jsonEncode(entries.map((e) => e.toJson()).toList()),
    );
  }
}
