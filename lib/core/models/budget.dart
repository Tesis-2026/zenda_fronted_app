class Budget {
  final String id;
  final String userId;
  final String? categoryId;
  final String? categoryName;
  /// User-given name for the budget pot (e.g. "Alquiler"). Null falls back to
  /// the category label on the client.
  final String? name;
  final double amountLimit;
  final int month;
  final int year;
  final double currentSpent;
  final double percentageUsed;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  const Budget({
    required this.id,
    required this.userId,
    this.categoryId,
    this.categoryName,
    this.name,
    required this.amountLimit,
    required this.month,
    required this.year,
    required this.currentSpent,
    required this.percentageUsed,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  /// A budget is a pure monthly spending limit — income never inflates it
  /// (see docs/income-as-first-class-concept.md).
  double get total => amountLimit;

  /// Money still available to spend against this limit.
  double get available => amountLimit - currentSpent;

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
      name: json['name'] as String?,
      amountLimit: (json['amountLimit'] as num).toDouble(),
      month: json['month'] as int,
      year: json['year'] as int,
      currentSpent: (json['currentSpent'] as num).toDouble(),
      percentageUsed: (json['percentageUsed'] as num).toDouble(),
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deletedAt: json['deletedAt'] as String?,
    );
  }
}
