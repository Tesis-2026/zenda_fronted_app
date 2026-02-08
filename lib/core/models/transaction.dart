enum TransactionSource { manual, ocr, voice }

enum TransactionKind { expense, income, transfer }

enum TransactionCategory {
  comida,
  transporte,
  vivienda,
  servicios,
  salud,
  ocio,
  compras,
  suscripciones,
  antojos,
  ahorro,
  otros,
}

enum Bucket503020 { necesidad, deseo, ahorro }

class TransactionModel {
  final String id;

  /// Optional for now (MVP is local-only).
  final String? userId;

  /// Mandatory origin account.
  final String accountId;

  /// Mandatory for transfers.
  final String? toAccountId;

  final TransactionKind kind;
  final double amount;
  final String currency;
  final TransactionCategory category;
  final Bucket503020 bucket;
  final DateTime timestamp;
  final String? note;
  final TransactionSource source;

  const TransactionModel({
    required this.id,
    required this.accountId,
    this.toAccountId,
    required this.kind,
    required this.amount,
    this.currency = 'PEN',
    required this.category,
    required this.bucket,
    required this.timestamp,
    this.note,
    required this.source,
    this.userId,
  });

  TransactionModel copyWith({
    String? id,
    String? userId,
    String? accountId,
    String? toAccountId,
    TransactionKind? kind,
    double? amount,
    String? currency,
    TransactionCategory? category,
    Bucket503020? bucket,
    DateTime? timestamp,
    String? note,
    TransactionSource? source,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      kind: kind ?? this.kind,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      category: category ?? this.category,
      bucket: bucket ?? this.bucket,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      source: source ?? this.source,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      accountId: json['accountId'] as String,
      toAccountId: json['toAccountId'] as String?,
      kind: TransactionKind.values.firstWhere(
        (e) => e.toString() == json['kind'],
        orElse: () => TransactionKind.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'PEN',
      category: TransactionCategory.values.firstWhere(
        (e) => e.toString() == json['category'],
        orElse: () => TransactionCategory.otros,
      ),
      bucket: Bucket503020.values.firstWhere(
        (e) => e.toString() == json['bucket'],
        orElse: () => Bucket503020.deseo,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      source: TransactionSource.values.firstWhere(
        (e) => e.toString() == json['source'],
        orElse: () => TransactionSource.manual,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'kind': kind.toString(),
      'amount': amount,
      'currency': currency,
      'category': category.toString(),
      'bucket': bucket.toString(),
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'source': source.toString(),
    };
  }
}

Bucket503020 bucketForCategory(TransactionCategory category) {
  // Rule (simple): unknown categories default to Deseo.
  switch (category) {
    case TransactionCategory.vivienda:
    case TransactionCategory.servicios:
    case TransactionCategory.transporte:
    case TransactionCategory.comida:
    case TransactionCategory.salud:
      return Bucket503020.necesidad;
    case TransactionCategory.ocio:
    case TransactionCategory.compras:
    case TransactionCategory.suscripciones:
    case TransactionCategory.antojos:
      return Bucket503020.deseo;
    case TransactionCategory.ahorro:
      return Bucket503020.ahorro;
    case TransactionCategory.otros:
      return Bucket503020.deseo;
  }
}
