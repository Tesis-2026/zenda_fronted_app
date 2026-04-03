class Budget {
  final String id;
  final String userId;
  final String? categoryId;
  final String? categoryName;
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
    required this.amountLimit,
    required this.month,
    required this.year,
    required this.currentSpent,
    required this.percentageUsed,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String?,
      categoryName: json['categoryName'] as String?,
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
