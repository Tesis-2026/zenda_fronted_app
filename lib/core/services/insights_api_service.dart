import 'api_client.dart';
import '../models/summary_models.dart';

class InsightsApiService {
  Future<PeriodSummary> getMonthSummary({required int year, required int month}) async {
    final json = await ApiClient.get('/summary/month?year=$year&month=$month');
    return PeriodSummary.fromJson(json);
  }

  Future<PeriodSummary> getWeekSummary({required int year, required int week}) async {
    final json = await ApiClient.get('/summary/week?year=$year&week=$week');
    return PeriodSummary.fromJson(json);
  }

  Future<PeriodSummary> getDaySummary({required String date}) async {
    final json = await ApiClient.get('/summary/day?date=$date');
    return PeriodSummary.fromJson(json);
  }

  Future<List<MonthComparisonEntry>> getComparison({required int months}) async {
    final list = await ApiClient.getList('/summary/comparison?months=$months');
    return list
        .cast<Map<String, dynamic>>()
        .map(MonthComparisonEntry.fromJson)
        .toList();
  }

  Future<List<int>> downloadPdfReport({required int year, required int month}) async {
    return ApiClient.getBytes('/reports/export/pdf?year=$year&month=$month');
  }
}
