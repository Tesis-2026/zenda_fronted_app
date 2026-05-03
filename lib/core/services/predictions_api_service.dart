import 'package:flutter/material.dart';

import 'api_client.dart';

class PredictionCategory {
  final String name;
  final double amount;
  final Color? color;

  const PredictionCategory({
    required this.name,
    required this.amount,
    this.color,
  });

  factory PredictionCategory.fromJson(Map<String, dynamic> json) {
    return PredictionCategory(
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

class PredictionResult {
  final String period;
  final double predictedAmount;
  final double confidenceLevel;
  final String? narrative;
  final String? modelVersion;
  // Extended fields for richer UI
  final double? projectedBalance;
  final double? budgetUsageFraction;
  final String? vsLastMonthLabel;
  final List<PredictionCategory>? topCategories;

  const PredictionResult({
    required this.period,
    required this.predictedAmount,
    required this.confidenceLevel,
    this.narrative,
    this.modelVersion,
    this.projectedBalance,
    this.budgetUsageFraction,
    this.vsLastMonthLabel,
    this.topCategories,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['topCategories'];
    List<PredictionCategory>? categories;
    if (rawCategories is List) {
      categories = rawCategories
          .whereType<Map<String, dynamic>>()
          .map(PredictionCategory.fromJson)
          .toList();
    }

    return PredictionResult(
      period: json['period'] as String,
      predictedAmount: (json['predictedAmount'] as num).toDouble(),
      confidenceLevel: (json['confidenceLevel'] as num? ?? 0.5).toDouble(),
      narrative: json['narrative'] as String?,
      modelVersion: json['modelVersion'] as String?,
      projectedBalance: (json['projectedBalance'] as num?)?.toDouble(),
      budgetUsageFraction: (json['budgetUsageFraction'] as num?)?.toDouble(),
      vsLastMonthLabel: json['vsLastMonthLabel'] as String?,
      topCategories: categories,
    );
  }
}

class PredictionsApiService {
  Future<PredictionResult> getExpensePrediction() async {
    final data = await ApiClient.get('/predictions/expenses');
    return PredictionResult.fromJson(data);
  }
}
