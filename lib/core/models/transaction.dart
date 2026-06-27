enum TransactionSource { manual, ocr, voice }

enum TransactionKind { expense, income, transfer }

/// Provenance of the chosen category for a transaction (B10 / ARCH-11).
/// Mirrors the backend `CategorySource` Prisma enum.
///
///   - [ai]            AI suggested a category and the user accepted it.
///   - [aiOverridden]  AI suggested a category but the user picked another.
///   - [user]          User picked the category manually; no AI was involved.
///
/// Derived server-side from `(suggestedCategoryId, categoryId)`. The
/// frontend never sets this directly; it just reads what the API returns.
enum CategorySource { ai, aiOverridden, user }

CategorySource? categorySourceFromApi(String? value) => switch (value) {
  'AI' => CategorySource.ai,
  'AI_OVERRIDDEN' => CategorySource.aiOverridden,
  'USER' => CategorySource.user,
  _ => null,
};

String categorySourceToApi(CategorySource source) => switch (source) {
  CategorySource.ai => 'AI',
  CategorySource.aiOverridden => 'AI_OVERRIDDEN',
  CategorySource.user => 'USER',
};

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
  beca,
  trabajoPartTime,
  familia,
  freelance,
  otros,
}

List<TransactionCategory> categoriesForTransactionKind(TransactionKind kind) {
  return switch (kind) {
    TransactionKind.income => const [
      TransactionCategory.beca,
      TransactionCategory.trabajoPartTime,
      TransactionCategory.familia,
      TransactionCategory.freelance,
      TransactionCategory.otros,
    ],
    TransactionKind.expense || TransactionKind.transfer => const [
      TransactionCategory.comida,
      TransactionCategory.transporte,
      TransactionCategory.vivienda,
      TransactionCategory.servicios,
      TransactionCategory.salud,
      TransactionCategory.ocio,
      TransactionCategory.compras,
      TransactionCategory.suscripciones,
      TransactionCategory.antojos,
      TransactionCategory.ahorro,
      TransactionCategory.otros,
    ],
  };
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

  // ── AI tracking (B10 / ARCH-11) ─────────────────────────────────
  // Populated when parsed from the backend's `TransactionResponseDto`.
  // Always null for local-only transactions (offline cache, transfers).

  /// The category the AI proposed at create time. Null when no AI was involved.
  final String? suggestedCategoryId;

  /// AI confidence in its suggestion, 0..1. Null when no AI was involved.
  final double? aiConfidence;

  /// Provenance of the final category (AI accepted / overridden / manual).
  /// Derived server-side; absent on local-only records.
  final CategorySource? categorySource;

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
    this.suggestedCategoryId,
    this.aiConfidence,
    this.categorySource,
  });

  /// True when the AI suggested a category for this transaction — regardless
  /// of whether the user accepted or overrode the suggestion. Useful for
  /// showing an "AI" chip on the transaction list / detail.
  bool get aiInvolved =>
      categorySource == CategorySource.ai ||
      categorySource == CategorySource.aiOverridden;

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
    String? suggestedCategoryId,
    double? aiConfidence,
    CategorySource? categorySource,
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
      suggestedCategoryId: suggestedCategoryId ?? this.suggestedCategoryId,
      aiConfidence: aiConfidence ?? this.aiConfidence,
      categorySource: categorySource ?? this.categorySource,
    );
  }

  /// Parses a JSON payload produced by **local storage** (`toJson` round-trip).
  /// Keys match the Dart enum `.toString()` form. Use [TransactionModel.fromApiJson]
  /// when consuming a backend `TransactionResponseDto`.
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
      suggestedCategoryId: json['suggestedCategoryId'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      categorySource: categorySourceFromApi(json['categorySource'] as String?),
    );
  }

  /// Parses a backend `TransactionResponseDto` payload from
  /// `GET/POST/PUT /api/transactions`. Different shape from local storage:
  /// `type` instead of `kind`, `occurredAt` instead of `timestamp`, etc.
  ///
  /// Bucket is inferred from category via [bucketForCategory] since the
  /// backend does not send it.
  factory TransactionModel.fromApiJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String?)?.toUpperCase();
    final kind = switch (typeStr) {
      'INCOME' => TransactionKind.income,
      'TRANSFER' => TransactionKind.transfer,
      _ => TransactionKind.expense,
    };
    final categoryNode = json['category'];
    final categoryName = categoryNode is Map<String, dynamic>
        ? categoryNode['name'] as String?
        : null;
    final category = _categoryFromApiName(categoryName);
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String?,
      accountId: (json['accountId'] as String?) ?? '',
      toAccountId: json['toAccountId'] as String?,
      kind: kind,
      amount: (json['amount'] as num).toDouble(),
      currency: (json['currency'] as String?) ?? 'PEN',
      category: category,
      bucket: bucketForCategory(category),
      timestamp: DateTime.parse(
        (json['occurredAt'] ?? json['createdAt']) as String,
      ),
      note: json['description'] as String?,
      source: TransactionSource.manual,
      suggestedCategoryId: json['suggestedCategoryId'] as String?,
      aiConfidence: (json['aiConfidence'] as num?)?.toDouble(),
      categorySource: categorySourceFromApi(json['categorySource'] as String?),
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
      if (suggestedCategoryId != null)
        'suggestedCategoryId': suggestedCategoryId,
      if (aiConfidence != null) 'aiConfidence': aiConfidence,
      if (categorySource != null)
        'categorySource': categorySourceToApi(categorySource!),
    };
  }
}

TransactionCategory _categoryFromApiName(String? name) {
  if (name == null) return TransactionCategory.otros;
  return switch (name.toLowerCase()) {
    'food' || 'comida' => TransactionCategory.comida,
    'transportation' || 'transporte' => TransactionCategory.transporte,
    'housing' || 'vivienda' => TransactionCategory.vivienda,
    'utilities' || 'servicios' => TransactionCategory.servicios,
    'health' || 'salud' => TransactionCategory.salud,
    'entertainment' || 'entretenimiento' || 'ocio' => TransactionCategory.ocio,
    'shopping' || 'compras' => TransactionCategory.compras,
    'subscriptions' || 'suscripciones' => TransactionCategory.suscripciones,
    'cravings' || 'antojos' => TransactionCategory.antojos,
    'savings' || 'ahorro' => TransactionCategory.ahorro,
    'scholarship' || 'beca' => TransactionCategory.beca,
    'part-time work' ||
    'part time work' ||
    'trabajo part time' ||
    'sueldo' ||
    'salario' => TransactionCategory.trabajoPartTime,
    'family' || 'familia' || 'apoyo familiar' => TransactionCategory.familia,
    'freelance' || 'honorarios' => TransactionCategory.freelance,
    _ => TransactionCategory.otros,
  };
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
    case TransactionCategory.beca:
    case TransactionCategory.trabajoPartTime:
    case TransactionCategory.familia:
    case TransactionCategory.freelance:
    case TransactionCategory.otros:
      return Bucket503020.deseo;
  }
}
