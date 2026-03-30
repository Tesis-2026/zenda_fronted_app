import 'api_client.dart';
import '../models/savings_goal.dart';

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
        if (dueDate != null) 'dueDate': dueDate,
      },
      authenticated: true,
    );
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

  Future<void> delete(String id) => ApiClient.delete('/goals/$id');
}
