class TopCategoryItem {
  final String name;
  final double amount;

  const TopCategoryItem({required this.name, required this.amount});

  factory TopCategoryItem.fromJson(Map<String, dynamic> json) => TopCategoryItem(
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
      );
}

class PeriodSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final List<TopCategoryItem> topCategories;

  const PeriodSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.topCategories,
  });

  factory PeriodSummary.fromJson(Map<String, dynamic> json) => PeriodSummary(
        totalIncome: (json['totalIncome'] as num).toDouble(),
        totalExpense: (json['totalExpense'] as num).toDouble(),
        netBalance: (json['netBalance'] as num).toDouble(),
        topCategories: (json['topCategories'] as List<dynamic>)
            .cast<Map<String, dynamic>>()
            .map(TopCategoryItem.fromJson)
            .toList(),
      );
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
