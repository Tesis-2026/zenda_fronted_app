import 'package:flutter/material.dart';

enum AccountType { cash, bankAccount, digitalWallet, creditCard }

AccountType accountTypeFromApi(String? value) {
  return switch ((value ?? '').toUpperCase()) {
    'BANK_ACCOUNT' => AccountType.bankAccount,
    'DIGITAL_WALLET' => AccountType.digitalWallet,
    'CREDIT_CARD' => AccountType.creditCard,
    _ => AccountType.cash,
  };
}

String accountTypeToApi(AccountType type) {
  return switch (type) {
    AccountType.cash => 'CASH',
    AccountType.bankAccount => 'BANK_ACCOUNT',
    AccountType.digitalWallet => 'DIGITAL_WALLET',
    AccountType.creditCard => 'CREDIT_CARD',
  };
}

String accountTypeLabel(AccountType type) {
  return switch (type) {
    AccountType.cash => 'Efectivo',
    AccountType.bankAccount => 'Banco',
    AccountType.digitalWallet => 'Billetera digital',
    AccountType.creditCard => 'Tarjeta de credito',
  };
}

IconData accountTypeIcon(AccountType type) {
  return switch (type) {
    AccountType.cash => Icons.payments_rounded,
    AccountType.bankAccount => Icons.account_balance_rounded,
    AccountType.digitalWallet => Icons.phone_iphone_rounded,
    AccountType.creditCard => Icons.credit_card_rounded,
  };
}

class FinancialAccount {
  final String id;
  final String name;
  final AccountType type;
  final String currency;
  final double openingBalance;
  final double currentBalance;
  final double debt;
  final double? creditLimit;
  final String? institution;
  final bool isDefault;

  const FinancialAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    required this.openingBalance,
    required this.currentBalance,
    required this.debt,
    required this.creditLimit,
    required this.institution,
    required this.isDefault,
  });

  factory FinancialAccount.fromJson(Map<String, dynamic> json) {
    return FinancialAccount(
      id: json['id'] as String,
      name:
          (json['name'] as String?) ??
          accountTypeLabel(accountTypeFromApi(json['type'] as String?)),
      type: accountTypeFromApi(json['type'] as String?),
      currency: (json['currency'] as String?) ?? 'PEN',
      openingBalance: _doubleOrZero(json['openingBalance']),
      currentBalance: _doubleOrZero(json['currentBalance']),
      debt: _doubleOrZero(json['debt']),
      creditLimit: _doubleOrNull(json['creditLimit']),
      institution: json['institution'] as String?,
      isDefault: (json['isDefault'] as bool?) ?? false,
    );
  }
}

class AccountReportItem extends FinancialAccount {
  final double income;
  final double expenses;
  final double transferIn;
  final double transferOut;
  final double netChange;

  const AccountReportItem({
    required super.id,
    required super.name,
    required super.type,
    required super.currency,
    required super.openingBalance,
    required super.currentBalance,
    required super.debt,
    required super.creditLimit,
    required super.institution,
    required super.isDefault,
    required this.income,
    required this.expenses,
    required this.transferIn,
    required this.transferOut,
    required this.netChange,
  });

  factory AccountReportItem.fromJson(Map<String, dynamic> json) {
    final base = FinancialAccount.fromJson(json);
    return AccountReportItem(
      id: base.id,
      name: base.name,
      type: base.type,
      currency: base.currency,
      openingBalance: base.openingBalance,
      currentBalance: base.currentBalance,
      debt: base.debt,
      creditLimit: base.creditLimit,
      institution: base.institution,
      isDefault: base.isDefault,
      income: _doubleOrZero(json['income']),
      expenses: _doubleOrZero(json['expenses']),
      transferIn: _doubleOrZero(json['transferIn']),
      transferOut: _doubleOrZero(json['transferOut']),
      netChange: _doubleOrZero(json['netChange']),
    );
  }
}

class AccountReport {
  final double totalAssets;
  final double totalCreditDebt;
  final List<AccountReportItem> accounts;
  final List<String> insights;

  const AccountReport({
    required this.totalAssets,
    required this.totalCreditDebt,
    required this.accounts,
    required this.insights,
  });

  factory AccountReport.fromJson(Map<String, dynamic> json) {
    final rawAccounts = json['accounts'];
    return AccountReport(
      totalAssets: _doubleOrZero(json['totalAssets']),
      totalCreditDebt: _doubleOrZero(json['totalCreditDebt']),
      accounts: rawAccounts is List
          ? rawAccounts
                .whereType<Map<String, dynamic>>()
                .map(AccountReportItem.fromJson)
                .toList()
          : const [],
      insights: json['insights'] is List
          ? (json['insights'] as List).whereType<String>().toList()
          : const [],
    );
  }
}

double _doubleOrZero(Object? value) => _doubleOrNull(value) ?? 0;

double? _doubleOrNull(Object? value) {
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.replaceAll(',', '.'));
  return null;
}
