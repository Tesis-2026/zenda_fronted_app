import 'api_client.dart';
import '../models/budget.dart';

class BudgetApiService {
  Future<List<Budget>> getAll({int? month, int? year}) async {
    final params = <String>[];
    if (month != null) params.add('month=$month');
    if (year != null) params.add('year=$year');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final list = await ApiClient.getList('/budgets$query');
    return list.cast<Map<String, dynamic>>().map(Budget.fromJson).toList();
  }

  Future<Budget> create({
    String? categoryId,
    String? name,
    required double amountLimit,
    required int month,
    required int year,
  }) async {
    final json = await ApiClient.post(
      '/budgets',
      {
        'categoryId': ?categoryId,
        'name': ?name,
        'amountLimit': amountLimit,
        'month': month,
        'year': year,
      },
      authenticated: true,
    );
    return Budget.fromJson(json);
  }

  Future<Budget> update(String id, {double? amountLimit, String? name}) async {
    final json = await ApiClient.put(
      '/budgets/$id',
      {
        'amountLimit': ?amountLimit,
        'name': ?name,
      },
    );
    return Budget.fromJson(json);
  }

  Future<void> delete(String id) => ApiClient.delete('/budgets/$id');
}
