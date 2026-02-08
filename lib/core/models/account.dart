import 'package:flutter/material.dart';

enum AccountType { cash, debit, credit }

class Account {
  final String id;
  final String name;
  final AccountType type;
  final String currency;
  final double balance; // for cash/debit
  final double creditAvailable; // for credit
  final double creditLimit; // for credit
  final int colorValue;
  final String? iconName;

  double get currentBalance {
    if (type == AccountType.credit) {
      return -creditDebt; // Deuda negativa
    }
    return balance;
  }

  double get creditDebt {
    if (type == AccountType.credit) {
      return creditLimit - creditAvailable;
    }
    return 0.0;
  }

  const Account({
    required this.id,
    required this.name,
    required this.type,
    this.currency = 'PEN',
    this.balance = 0.0,
    this.creditAvailable = 0.0,
    this.creditLimit = 0.0,
    this.colorValue = 0xFF34D399,
    this.iconName,
  });

  Account copyWith({
    String? id,
    String? name,
    AccountType? type,
    String? currency,
    double? balance,
    double? creditAvailable,
    double? creditLimit,
    int? colorValue,
    String? iconName,
  }) {
    return Account(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      currency: currency ?? this.currency,
      balance: balance ?? this.balance,
      creditAvailable: creditAvailable ?? this.creditAvailable,
      creditLimit: creditLimit ?? this.creditLimit,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
    );
  }

  Account applyBalanceDelta(double delta) {
    return copyWith(balance: balance + delta);
  }

  Account applyCreditDebtDelta(double deltaDebt) {
    if (type != AccountType.credit) return this;
    final nextDebt = (creditDebt + deltaDebt).clamp(0.0, creditLimit);
    final nextAvailable = (creditLimit - nextDebt).clamp(0.0, creditLimit);
    return copyWith(creditAvailable: nextAvailable);
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      type: AccountType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AccountType.cash,
      ),
      currency: json['currency'] ?? 'PEN',
      balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      creditAvailable: (json['creditAvailable'] as num?)?.toDouble() ?? 0.0,
      creditLimit: (json['creditLimit'] as num?)?.toDouble() ?? 0.0,
      colorValue: json['colorValue'] ?? 0xFF34D399,
      iconName: json['iconName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.toString(),
      'currency': currency,
      'balance': balance,
      'creditAvailable': creditAvailable,
      'creditLimit': creditLimit,
      'colorValue': colorValue,
      'iconName': iconName,
    };
  }

  // Helper properties for UI
  IconData get iconData {
    switch (type) {
      case AccountType.cash:
        return Icons.attach_money_rounded;
      case AccountType.debit:
        return Icons.credit_card_rounded;
      case AccountType.credit:
        return Icons.credit_score_rounded;
    }
  }

  String get typeLabel {
    switch (type) {
      case AccountType.cash:
        return 'Efectivo';
      case AccountType.debit:
        return 'Débito';
      case AccountType.credit:
        return 'Crédito';
    }
  }
}
