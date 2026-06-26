import '../models/transaction.dart';
import 'api_client.dart';
import 'transaction_api_service.dart' show categoryFromApiName;

class ReceiptOcrItem {
  final String? name;
  final double? amount;
  final double? quantity;

  const ReceiptOcrItem({this.name, this.amount, this.quantity});

  factory ReceiptOcrItem.fromJson(Map<String, dynamic> json) {
    return ReceiptOcrItem(
      name: _stringOrNull(json['name']),
      amount: _doubleOrNull(json['amount']),
      quantity: _doubleOrNull(json['quantity']),
    );
  }
}

class ReceiptOcrResult {
  final double? amount;
  final String? date;
  final String? time;
  final String? merchant;
  final double? tax;
  final List<ReceiptOcrItem> items;
  final String? suggestedCategory;
  final String? paymentMethod;
  final String? suggestedAccountName;
  final String? suggestedAccountType;
  final String note;
  final double confidence;
  final List<String> warnings;

  const ReceiptOcrResult({
    required this.amount,
    required this.date,
    required this.time,
    required this.merchant,
    required this.tax,
    required this.items,
    required this.suggestedCategory,
    required this.paymentMethod,
    required this.suggestedAccountName,
    required this.suggestedAccountType,
    required this.note,
    required this.confidence,
    required this.warnings,
  });

  TransactionCategory? get category => categoryFromApiName(suggestedCategory);

  DateTime? get parsedDate {
    final raw = date;
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  factory ReceiptOcrResult.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return ReceiptOcrResult(
      amount: _doubleOrNull(json['amount']),
      date: _stringOrNull(json['date']),
      time: _stringOrNull(json['time']),
      merchant: _stringOrNull(json['merchant']),
      tax: _doubleOrNull(json['tax']),
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(ReceiptOcrItem.fromJson)
                .toList()
          : const [],
      suggestedCategory: _stringOrNull(json['suggestedCategory']),
      paymentMethod: _stringOrNull(json['paymentMethod']),
      suggestedAccountName: _stringOrNull(json['suggestedAccountName']),
      suggestedAccountType: _stringOrNull(json['suggestedAccountType']),
      note: _stringOrNull(json['note']) ?? '',
      confidence: _doubleOrNull(json['confidence']) ?? 0,
      warnings: json['warnings'] is List
          ? (json['warnings'] as List)
                .whereType<String>()
                .where((warning) => warning.trim().isNotEmpty)
                .toList()
          : const [],
    );
  }
}

abstract class OcrService {
  Future<ReceiptOcrResult> analyzeReceipt({
    required List<int> bytes,
    required String filename,
    required String contentType,
  });
}

class ApiOcrService implements OcrService {
  @override
  Future<ReceiptOcrResult> analyzeReceipt({
    required List<int> bytes,
    required String filename,
    required String contentType,
  }) async {
    final json = await ApiClient.postMultipart(
      '/receipts/analyze',
      fieldName: 'file',
      bytes: bytes,
      filename: filename,
      contentType: contentType,
      authenticated: true,
    );
    return ReceiptOcrResult.fromJson(json);
  }
}

double? _doubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}

String? _stringOrNull(Object? value) {
  if (value is! String) return null;
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}
