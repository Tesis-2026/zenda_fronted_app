enum TransactionSource { manual, ocr, voice }

enum TransactionCategory { comida, transporte, vivienda, salud, ocio, otros }

enum Bucket503020 { necesidad, deseo, ahorro }

class TransactionModel {
  final String id;
  final String userId;
  final double amount;
  final String currency;
  final TransactionCategory category;
  final Bucket503020 bucket;
  final DateTime timestamp;
  final String? note;
  final TransactionSource source;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    this.currency = 'PEN',
    required this.category,
    required this.bucket,
    required this.timestamp,
    this.note,
    required this.source,
  });
}
