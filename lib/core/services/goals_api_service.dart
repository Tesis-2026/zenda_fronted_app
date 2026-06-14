import 'api_client.dart';
import '../models/savings_goal.dart';

class GoalContribution {
  final String id;
  final String goalId;
  final double amount;
  final DateTime createdAt;

  const GoalContribution({
    required this.id,
    required this.goalId,
    required this.amount,
    required this.createdAt,
  });

  factory GoalContribution.fromJson(Map<String, dynamic> json) {
    return GoalContribution(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      amount: (json['amount'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class GoalsApiService {
  Future<List<SavingsGoal>> getAll() async {
    final list = await ApiClient.getList('/goals');
    return list.cast<Map<String, dynamic>>().map(SavingsGoal.fromJson).toList();
  }

  Future<SavingsGoal> create({
    required String name,
    required double targetAmount,
    String? dueDate,
  }) async {
    final json = await ApiClient.post(
      '/goals',
      {
        'name': name,
        'targetAmount': targetAmount,
        'dueDate': ?dueDate,
      },
      authenticated: true,
    );
    return SavingsGoal.fromJson(json);
  }

  Future<SavingsGoal> update(
    String id, {
    String? name,
    double? targetAmount,
    String? dueDate,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (targetAmount != null) body['targetAmount'] = targetAmount;
    if (dueDate != null) body['dueDate'] = dueDate;
    final json = await ApiClient.put('/goals/$id', body);
    return SavingsGoal.fromJson(json);
  }

  Future<SavingsGoal> contribute(String id, {required double amount}) async {
    final json = await ApiClient.post(
      '/goals/$id/contribute',
      {'amount': amount},
      authenticated: true,
    );
    return SavingsGoal.fromJson(json);
  }

  Future<List<GoalContribution>> getContributions(String id) async {
    final list = await ApiClient.getList('/goals/$id/contributions');
    return list
        .cast<Map<String, dynamic>>()
        .map(GoalContribution.fromJson)
        .toList();
  }

  Future<SavingsGoal> complete(String id) async {
    final json = await ApiClient.post('/goals/$id/complete', {}, authenticated: true);
    return SavingsGoal.fromJson(json);
  }

  Future<void> delete(String id) => ApiClient.delete('/goals/$id');
}
