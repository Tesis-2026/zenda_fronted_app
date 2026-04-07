import '../../domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    required super.description,
    required super.type,
    required super.currency,
    required super.occurredAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? json['_id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      type: json['type'] ?? 'expense',
      currency: json['currency'] ?? 'PEN',
      occurredAt: json['occurredAt'] != null 
          ? DateTime.tryParse(json['occurredAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'description': description,
      'type': type,
      'currency': currency,
      'occurredAt': occurredAt.toIso8601String(),
    };
  }
}
