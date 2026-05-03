enum IncomeType { scholarship, partTime, family, mixed }

enum FinancialLiteracyLevel { beginner, intermediate, advanced }

String incomeTypeToString(IncomeType type) => switch (type) {
      IncomeType.scholarship => 'SCHOLARSHIP',
      IncomeType.partTime => 'PART_TIME',
      IncomeType.family => 'FAMILY',
      IncomeType.mixed => 'MIXED',
    };

String literacyLevelToString(FinancialLiteracyLevel level) => switch (level) {
      FinancialLiteracyLevel.beginner => 'LOW',
      FinancialLiteracyLevel.intermediate => 'MEDIUM',
      FinancialLiteracyLevel.advanced => 'HIGH',
    };

IncomeType? _incomeTypeFromString(String? value) => switch (value) {
      'SCHOLARSHIP' => IncomeType.scholarship,
      'PART_TIME' => IncomeType.partTime,
      'FAMILY' => IncomeType.family,
      'MIXED' => IncomeType.mixed,
      _ => null,
    };

FinancialLiteracyLevel? _literacyLevelFromString(String? value) => switch (value) {
      'LOW' => FinancialLiteracyLevel.beginner,
      'MEDIUM' => FinancialLiteracyLevel.intermediate,
      'HIGH' => FinancialLiteracyLevel.advanced,
      _ => null,
    };

class User {
  final String id;
  final String name;
  final String email;
  final int? age;
  final String? university;
  final IncomeType? incomeType;
  final double? averageMonthlyIncome;
  final FinancialLiteracyLevel? financialLiteracyLevel;
  final bool profileCompleted;
  final String currency;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.age,
    this.university,
    this.incomeType,
    this.averageMonthlyIncome,
    this.financialLiteracyLevel,
    this.profileCompleted = false,
    this.currency = 'PEN',
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (age != null) 'age': age,
      if (university != null) 'university': university,
      if (incomeType != null) 'incomeType': incomeTypeToString(incomeType!),
      if (averageMonthlyIncome != null) 'averageMonthlyIncome': averageMonthlyIncome,
      if (financialLiteracyLevel != null) 'financialLiteracyLevel': financialLiteracyLevel!.name.toUpperCase(),
      'profileCompleted': profileCompleted,
      'currency': currency,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      // Backend returns 'fullName'; local storage may use 'name'
      name: (json['fullName'] ?? json['name']) as String,
      email: json['email'] as String,
      age: json['age'] as int?,
      university: json['university'] as String?,
      incomeType: _incomeTypeFromString(json['incomeType'] as String?),
      averageMonthlyIncome: (json['averageMonthlyIncome'] as num?)?.toDouble(),
      financialLiteracyLevel: _literacyLevelFromString(json['financialLiteracyLevel'] as String?),
      profileCompleted: (json['profileCompleted'] as bool?) ?? false,
      currency: (json['currency'] as String?) ?? 'PEN',
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? university,
    IncomeType? incomeType,
    double? averageMonthlyIncome,
    FinancialLiteracyLevel? financialLiteracyLevel,
    bool? profileCompleted,
    String? currency,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      university: university ?? this.university,
      incomeType: incomeType ?? this.incomeType,
      averageMonthlyIncome: averageMonthlyIncome ?? this.averageMonthlyIncome,
      financialLiteracyLevel: financialLiteracyLevel ?? this.financialLiteracyLevel,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      currency: currency ?? this.currency,
    );
  }
}
