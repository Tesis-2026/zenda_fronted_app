class TopCategoryItem {
  final String name;
  final double amount;

  const TopCategoryItem({required this.name, required this.amount});

  factory TopCategoryItem.fromJson(Map<String, dynamic> json) => TopCategoryItem(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

class DailyBreakdownItem {
  final String date;
  final double totalIncome;
  final double totalExpense;

  const DailyBreakdownItem({
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
  });

  factory DailyBreakdownItem.fromJson(Map<String, dynamic> json) => DailyBreakdownItem(
        date: json['date'] as String,
        totalIncome: (json['totalIncome'] as num).toDouble(),
        totalExpense: (json['totalExpense'] as num).toDouble(),
      );

  String get dayLabel {
    final parts = date.split('-');
    if (parts.length < 3) return date;
    final weekday = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2])).weekday;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

class GoalProgressItem {
  final String name;
  final double currentAmount;
  final double targetAmount;
  final double progressPercent;

  const GoalProgressItem({
    required this.name,
    required this.currentAmount,
    required this.targetAmount,
    required this.progressPercent,
  });

  factory GoalProgressItem.fromJson(Map<String, dynamic> json) => GoalProgressItem(
        name: json['name'] as String,
        currentAmount: (json['currentAmount'] as num).toDouble(),
        targetAmount: (json['targetAmount'] as num).toDouble(),
        progressPercent: (json['progressPercent'] as num).toDouble(),
      );
}

class PeriodSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<TopCategoryItem> topCategories;
  final List<DailyBreakdownItem> dailyBreakdown;
  final List<GoalProgressItem> goalsProgress;

  const PeriodSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.topCategories,
    this.dailyBreakdown = const [],
    this.goalsProgress = const [],
  });

  factory PeriodSummary.fromJson(Map<String, dynamic> json) => PeriodSummary(
        totalIncome: (json['totalIncome'] as num).toDouble(),
        totalExpense: (json['totalExpense'] as num).toDouble(),
        netBalance: (json['netBalance'] as num).toDouble(),
        topCategories: (json['topCategories'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(TopCategoryItem.fromJson)
            .toList(),
        dailyBreakdown: json['dailyBreakdown'] == null
            ? []
            : (json['dailyBreakdown'] as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(DailyBreakdownItem.fromJson)
                .toList(),
        goalsProgress: json['goalsProgress'] == null
            ? []
            : (json['goalsProgress'] as List<dynamic>)
                .cast<Map<String, dynamic>>()
                .map(GoalProgressItem.fromJson)
                .toList(),
      );
}

class ProgressSummary {
  final double currentIncome;
  final double currentExpenses;
  final double currentBalance;
  final double previousIncome;
  final double previousExpenses;
  final double previousBalance;
  final double? expensesChangePercent;
  final double? savingsChangePercent;
  final double? balanceChangePercent;

  const ProgressSummary({
    required this.currentIncome,
    required this.currentExpenses,
    required this.currentBalance,
    required this.previousIncome,
    required this.previousExpenses,
    required this.previousBalance,
    this.expensesChangePercent,
    this.savingsChangePercent,
    this.balanceChangePercent,
  });

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    final cur = json['currentMonth'] as Map<String, dynamic>;
    final prev = json['previousMonth'] as Map<String, dynamic>;
    final changes = json['changes'] as Map<String, dynamic>;
    return ProgressSummary(
      currentIncome: (cur['income'] as num).toDouble(),
      currentExpenses: (cur['expenses'] as num).toDouble(),
      currentBalance: (cur['balance'] as num).toDouble(),
      previousIncome: (prev['income'] as num).toDouble(),
      previousExpenses: (prev['expenses'] as num).toDouble(),
      previousBalance: (prev['balance'] as num).toDouble(),
      expensesChangePercent: changes['expensesChangePercent'] == null
          ? null
          : (changes['expensesChangePercent'] as num).toDouble(),
      savingsChangePercent: changes['savingsChangePercent'] == null
          ? null
          : (changes['savingsChangePercent'] as num).toDouble(),
      balanceChangePercent: changes['balanceChangePercent'] == null
          ? null
          : (changes['balanceChangePercent'] as num).toDouble(),
    );
  }
}

class MonthComparisonEntry {
  final int year;
  final int month;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const MonthComparisonEntry({
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });

  factory MonthComparisonEntry.fromJson(Map<String, dynamic> json) => MonthComparisonEntry(
        year: json['year'] as int,
        month: json['month'] as int,
        totalIncome: (json['totalIncome'] as num).toDouble(),
        totalExpense: (json['totalExpense'] as num).toDouble(),
        netBalance: (json['netBalance'] as num).toDouble(),
      );

  String get label {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return names[month - 1];
  }
}
