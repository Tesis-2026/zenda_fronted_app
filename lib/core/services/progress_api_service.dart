import 'api_client.dart';

class MonthFinancials {
  final double income;
  final double expenses;
  final double balance;
  final double savings;

  const MonthFinancials({
    required this.income,
    required this.expenses,
    required this.balance,
    required this.savings,
  });

  factory MonthFinancials.fromJson(Map<String, dynamic> json) {
    return MonthFinancials(
      income: (json['income'] as num).toDouble(),
      expenses: (json['expenses'] as num).toDouble(),
      balance: (json['balance'] as num).toDouble(),
      savings: (json['savings'] as num).toDouble(),
    );
  }
}

class FinancialProgress {
  final MonthFinancials currentMonth;
  final MonthFinancials previousMonth;
  final double? expensesChangePercent;
  final double? savingsChangePercent;
  final double? balanceChangePercent;

  const FinancialProgress({
    required this.currentMonth,
    required this.previousMonth,
    this.expensesChangePercent,
    this.savingsChangePercent,
    this.balanceChangePercent,
  });

  factory FinancialProgress.fromJson(Map<String, dynamic> json) {
    final changes = json['changes'] as Map<String, dynamic>? ?? {};
    return FinancialProgress(
      currentMonth: MonthFinancials.fromJson(
          json['currentMonth'] as Map<String, dynamic>),
      previousMonth: MonthFinancials.fromJson(
          json['previousMonth'] as Map<String, dynamic>),
      expensesChangePercent:
          (changes['expensesChangePercent'] as num?)?.toDouble(),
      savingsChangePercent:
          (changes['savingsChangePercent'] as num?)?.toDouble(),
      balanceChangePercent:
          (changes['balanceChangePercent'] as num?)?.toDouble(),
    );
  }
}

class ProgressApiService {
  Future<FinancialProgress> getProgress() async {
    final data = await ApiClient.get('/summary/progress');
    return FinancialProgress.fromJson(data);
  }
}
