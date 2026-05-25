import 'package:flutter/material.dart';

import 'api_client.dart';

/// One row of the per-category breakdown that the AI returns alongside
/// the headline prediction. Mirrors the backend `CategoryPredictionDto`.
class PredictionCategory {
  /// UUID of the backend Category. Null when the AI couldn't tie the
  /// bucket to a known category (e.g. open-ended "Other").
  final String? categoryId;
  final String name;
  final double amount;
  final Color? color;

  const PredictionCategory({
    this.categoryId,
    required this.name,
    required this.amount,
    this.color,
  });

  /// Parses the backend's `{categoryId, categoryName, amount}` shape.
  /// Falls back to legacy `{name, amount}` so older mocks keep working.
  factory PredictionCategory.fromJson(Map<String, dynamic> json) {
    return PredictionCategory(
      categoryId: json['categoryId'] as String?,
      name: (json['categoryName'] as String?) ??
          (json['name'] as String?) ??
          '—',
      amount: (json['amount'] as num).toDouble(),
    );
  }
}

/// Confidence level returned by the AI provider. The numeric percentage
/// used in the UI is derived from this — see [confidenceFraction] —
/// because the backend reports categorical confidence, not raw probability.
enum PredictionConfidence { high, medium, low }

PredictionConfidence _confidenceFromApi(String? raw) {
  return switch (raw?.toLowerCase()) {
    'high' => PredictionConfidence.high,
    'medium' => PredictionConfidence.medium,
    _ => PredictionConfidence.low,
  };
}

/// Lower/upper bound of the prediction. Backend derives this from
/// `confidenceLevel + predictedTotal` (B17). Frontend just renders it
/// when present.
class PredictionInterval {
  final double lower;
  final double upper;

  const PredictionInterval({required this.lower, required this.upper});

  factory PredictionInterval.fromJson(Map<String, dynamic> json) =>
      PredictionInterval(
        lower: (json['lower'] as num).toDouble(),
        upper: (json['upper'] as num).toDouble(),
      );
}

class PredictionResult {
  /// Format `YYYY-MM`, the period the prediction covers.
  final String period;

  /// Headline prediction in PEN. Renamed from `predictedAmount` so the
  /// FE field matches the backend `predictedTotal` shape.
  final double predictedTotal;

  /// Categorical confidence from the AI provider. UI converts to a
  /// percentage label via [confidenceFraction].
  final PredictionConfidence confidence;

  /// Numerical band around `predictedTotal`, derived by the backend
  /// from `confidence + predictedTotal` (B17). Null on older payloads.
  final PredictionInterval? confidenceInterval;

  final String? narrative;
  final String? modelVersion;

  /// Per-category breakdown the AI emits. Empty list when not provided.
  final List<PredictionCategory> categories;

  // Optional client-side derived fields the screen renders when present.
  // Not part of the backend payload today — kept for forward compat with
  // dashboards that might enrich the API response later.
  final double? projectedBalance;
  final double? budgetUsageFraction;
  final String? vsLastMonthLabel;

  const PredictionResult({
    required this.period,
    required this.predictedTotal,
    required this.confidence,
    this.confidenceInterval,
    this.narrative,
    this.modelVersion,
    this.categories = const [],
    this.projectedBalance,
    this.budgetUsageFraction,
    this.vsLastMonthLabel,
  });

  /// Display percentage (0–1) for the categorical confidence.
  /// Picked to match the band widths the backend uses to derive
  /// `confidenceInterval` (high ±5%, medium ±15%, low ±30%): high
  /// reads as ~85%, medium ~65%, low ~40%.
  double get confidenceFraction => switch (confidence) {
        PredictionConfidence.high => 0.85,
        PredictionConfidence.medium => 0.65,
        PredictionConfidence.low => 0.40,
      };

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final rawCategories = json['predictedByCategory'] ?? json['topCategories'];
    final categories = rawCategories is List
        ? rawCategories
            .whereType<Map<String, dynamic>>()
            .map(PredictionCategory.fromJson)
            .toList()
        : <PredictionCategory>[];

    final rawInterval = json['confidenceInterval'];
    final interval = rawInterval is Map<String, dynamic>
        ? PredictionInterval.fromJson(rawInterval)
        : null;

    // Tolerate legacy `predictedAmount` so mocks predating B17 still parse.
    final totalRaw = json['predictedTotal'] ?? json['predictedAmount'];

    return PredictionResult(
      period: json['period'] as String,
      predictedTotal: (totalRaw as num).toDouble(),
      confidence: _confidenceFromApi(json['confidenceLevel'] as String?),
      confidenceInterval: interval,
      narrative: json['narrative'] as String?,
      modelVersion: json['modelVersion'] as String?,
      categories: categories,
      projectedBalance: (json['projectedBalance'] as num?)?.toDouble(),
      budgetUsageFraction: (json['budgetUsageFraction'] as num?)?.toDouble(),
      vsLastMonthLabel: json['vsLastMonthLabel'] as String?,
    );
  }
}

class PredictionsApiService {
  Future<PredictionResult> getExpensePrediction() async {
    final data = await ApiClient.get('/predictions/expenses');
    return PredictionResult.fromJson(data);
  }
}
