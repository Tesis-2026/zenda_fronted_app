import '../models/account.dart';
import 'api_client.dart';

class AccountApiService {
  Future<List<FinancialAccount>> getAll() async {
    final list = await ApiClient.getList('/accounts');
    return list
        .whereType<Map<String, dynamic>>()
        .map(FinancialAccount.fromJson)
        .toList();
  }

  Future<AccountReport> getReport({int? month, int? year}) async {
    final params = <String, String>{};
    if (month != null) params['month'] = '$month';
    if (year != null) params['year'] = '$year';
    final query = params.isEmpty
        ? ''
        : '?${params.entries.map((entry) => '${entry.key}=${entry.value}').join('&')}';
    final json = await ApiClient.get('/accounts/report$query');
    return AccountReport.fromJson(json);
  }

  Future<Map<String, dynamic>> transfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime occurredAt,
    String? description,
  }) {
    return ApiClient.post('/accounts/transfer', {
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'amount': amount,
      'occurredAt': occurredAt.toUtc().toIso8601String(),
      if (description != null && description.trim().isNotEmpty)
        'description': description.trim(),
    }, authenticated: true);
  }
}
