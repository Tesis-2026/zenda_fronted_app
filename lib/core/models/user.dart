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

FinancialLiteracyLevel? _literacyLevelFromString(String? value) =>
    switch (value) {
      'LOW' => FinancialLiteracyLevel.beginner,
      'MEDIUM' => FinancialLiteracyLevel.intermediate,
      'HIGH' => FinancialLiteracyLevel.advanced,
      _ => null,
    };

class User {
  final String id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final int? age;
  final String? university;
  final IncomeType? incomeType;
  final double? averageMonthlyIncome;
  final FinancialLiteracyLevel? financialLiteracyLevel;
  final bool profileCompleted;
  final String currency;
  final String? createdAt;
  final bool consentGiven;
  final String? consentAt;
  final String? privacyPolicyVersion;
  final String? termsVersion;
  final String? dataAnonymizedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.age,
    this.university,
    this.incomeType,
    this.averageMonthlyIncome,
    this.financialLiteracyLevel,
    this.profileCompleted = false,
    this.currency = 'PEN',
    this.createdAt,
    this.consentGiven = false,
    this.consentAt,
    this.privacyPolicyVersion,
    this.termsVersion,
    this.dataAnonymizedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      if (emailVerifiedAt != null) 'emailVerifiedAt': emailVerifiedAt,
      if (age != null) 'age': age,
      if (university != null) 'university': university,
      if (incomeType != null) 'incomeType': incomeTypeToString(incomeType!),
      if (averageMonthlyIncome != null)
        'averageMonthlyIncome': averageMonthlyIncome,
      if (financialLiteracyLevel != null)
        'financialLiteracyLevel': financialLiteracyLevel!.name.toUpperCase(),
      'profileCompleted': profileCompleted,
      'currency': currency,
      'consentGiven': consentGiven,
      if (consentAt != null) 'consentAt': consentAt,
      if (privacyPolicyVersion != null)
        'privacyPolicyVersion': privacyPolicyVersion,
      if (termsVersion != null) 'termsVersion': termsVersion,
      if (dataAnonymizedAt != null) 'dataAnonymizedAt': dataAnonymizedAt,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      // Backend returns 'fullName'; local storage may use 'name'
      name: (json['fullName'] ?? json['name']) as String,
      email: json['email'] as String,
      emailVerifiedAt: json['emailVerifiedAt'] as String?,
      age: json['age'] as int?,
      university: json['university'] as String?,
      incomeType: _incomeTypeFromString(json['incomeType'] as String?),
      averageMonthlyIncome: (json['averageMonthlyIncome'] as num?)?.toDouble(),
      financialLiteracyLevel: _literacyLevelFromString(
        json['financialLiteracyLevel'] as String?,
      ),
      profileCompleted: (json['profileCompleted'] as bool?) ?? false,
      currency: (json['currency'] as String?) ?? 'PEN',
      createdAt: json['createdAt'] as String?,
      consentGiven: (json['consentGiven'] as bool?) ?? false,
      consentAt: json['consentAt'] as String?,
      privacyPolicyVersion: json['privacyPolicyVersion'] as String?,
      termsVersion: json['termsVersion'] as String?,
      dataAnonymizedAt: json['dataAnonymizedAt'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? emailVerifiedAt,
    int? age,
    String? university,
    IncomeType? incomeType,
    double? averageMonthlyIncome,
    FinancialLiteracyLevel? financialLiteracyLevel,
    bool? profileCompleted,
    String? currency,
    String? createdAt,
    bool? consentGiven,
    String? consentAt,
    String? privacyPolicyVersion,
    String? termsVersion,
    String? dataAnonymizedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      age: age ?? this.age,
      university: university ?? this.university,
      incomeType: incomeType ?? this.incomeType,
      averageMonthlyIncome: averageMonthlyIncome ?? this.averageMonthlyIncome,
      financialLiteracyLevel:
          financialLiteracyLevel ?? this.financialLiteracyLevel,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      consentGiven: consentGiven ?? this.consentGiven,
      consentAt: consentAt ?? this.consentAt,
      privacyPolicyVersion: privacyPolicyVersion ?? this.privacyPolicyVersion,
      termsVersion: termsVersion ?? this.termsVersion,
      dataAnonymizedAt: dataAnonymizedAt ?? this.dataAnonymizedAt,
    );
  }
}
