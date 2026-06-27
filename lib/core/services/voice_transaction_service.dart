import '../models/transaction.dart';
import 'api_client.dart';
import 'transaction_api_service.dart' show categoryFromApiName;

class VoiceTransactionDraftResult {
  final TransactionKind kind;
  final double? amount;
  final String description;
  final DateTime? occurredAt;
  final String? suggestedCategoryName;
  final String? suggestedAccountName;
  final String? suggestedAccountType;
  final double confidence;
  final List<String> warnings;

  const VoiceTransactionDraftResult({
    required this.kind,
    required this.amount,
    required this.description,
    required this.occurredAt,
    required this.suggestedCategoryName,
    required this.suggestedAccountName,
    required this.suggestedAccountType,
    required this.confidence,
    required this.warnings,
  });

  TransactionCategory? get category =>
      categoryFromApiName(suggestedCategoryName);

  factory VoiceTransactionDraftResult.fromJson(Map<String, dynamic> json) {
    final type = (json['type'] as String? ?? '').toUpperCase();
    final warnings = json['warnings'] is List
        ? (json['warnings'] as List)
              .whereType<String>()
              .where((warning) => warning.trim().isNotEmpty)
              .toList()
        : const <String>[];

    return VoiceTransactionDraftResult(
      kind: type == 'INCOME' ? TransactionKind.income : TransactionKind.expense,
      amount: _doubleOrNull(json['amount']),
      description: _stringOrEmpty(json['description']),
      occurredAt: _dateOrNull(json['occurredAt']),
      suggestedCategoryName: _stringOrNull(json['suggestedCategoryName']),
      suggestedAccountName: _stringOrNull(json['suggestedAccountName']),
      suggestedAccountType: _stringOrNull(json['suggestedAccountType']),
      confidence: _doubleOrNull(json['confidence']) ?? 0,
      warnings: warnings,
    );
  }
}

abstract class VoiceTransactionService {
  Future<VoiceTransactionDraftResult> parseDraft({
    required String text,
    String timezone,
  });
}

class ApiVoiceTransactionService implements VoiceTransactionService {
  @override
  Future<VoiceTransactionDraftResult> parseDraft({
    required String text,
    String timezone = 'America/Lima',
  }) async {
    final json = await ApiClient.post('/transactions/voice-draft', {
      'text': text,
      'timezone': timezone,
    }, authenticated: true);
    return VoiceTransactionDraftResult.fromJson(json);
  }
}

double? _doubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

DateTime? _dateOrNull(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  return DateTime.tryParse(value);
}

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _stringOrEmpty(Object? value) => _stringOrNull(value) ?? '';
