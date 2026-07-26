class SavingsGoal {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String? dueDate;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;
  final bool isCompleted;

  const SavingsGoal({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.dueDate,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.isCompleted = false,
  });

  double get progressPercent {
    if (targetAmount == 0) return 0;
    return (currentAmount / targetAmount * 100).clamp(0, 100);
  }

  bool get isComplete => isCompleted || progressPercent >= 100;

  DateTime? get dueDateValue {
    final raw = dueDate;
    if (raw == null) return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  int? daysRemaining({DateTime? now}) {
    if (isCompleted) return null;
    final due = dueDateValue;
    if (due == null) return null;

    final base = now ?? DateTime.now();
    final today = DateTime(base.year, base.month, base.day);
    final dueDay = DateTime(due.year, due.month, due.day);
    final days = dueDay.difference(today).inDays;
    return days < 0 ? 0 : days;
  }

  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      dueDate: json['dueDate'] as String?,
      completedAt: json['completedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      deletedAt: json['deletedAt'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}
