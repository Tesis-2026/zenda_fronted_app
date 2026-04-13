import '../models/user.dart';
import 'api_client.dart';

class UserApiService {
  Future<User> getProfile() async {
    final body = await ApiClient.get('/users/me');
    return User.fromJson(body);
  }

  Future<User> updateProfile({
    String? fullName,
    int? age,
    String? university,
    IncomeType? incomeType,
    double? averageMonthlyIncome,
    FinancialLiteracyLevel? financialLiteracyLevel,
    bool? profileCompleted,
    String? currency,
  }) async {
    final data = <String, dynamic>{};

    if (fullName != null) data['fullName'] = fullName;
    if (age != null) data['age'] = age;
    if (university != null) data['university'] = university;
    if (incomeType != null) data['incomeType'] = incomeTypeToString(incomeType);
    if (averageMonthlyIncome != null) {
      data['averageMonthlyIncome'] = averageMonthlyIncome;
    }
    if (financialLiteracyLevel != null) {
      data['financialLiteracyLevel'] =
          literacyLevelToString(financialLiteracyLevel);
    }
    if (profileCompleted != null) data['profileCompleted'] = profileCompleted;
    if (currency != null) data['currency'] = currency;

    final body = await ApiClient.put('/users/me', data);
    return User.fromJson(body);
  }
}
