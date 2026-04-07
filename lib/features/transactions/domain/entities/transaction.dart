
class Transaction {
  final String id;
  final String categoryId;
  final double amount;
  final String description;
  final String type; // "expense" or "income"
  final String currency; // "PEN", "USD"
  final DateTime occurredAt;

  const Transaction({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.description,
    required this.type,
    required this.currency,
    required this.occurredAt,
  });
}
