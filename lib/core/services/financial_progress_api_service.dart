import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';

/// Persisted monthly KPI snapshot returned by the backend
/// `financial-progress` module (US-014). One row per user × period
/// (YYYY-MM); the snapshot job that writes them is currently out of
/// scope, so an empty list is the expected state for new users.
class FinancialProgressSnapshot {
  /// UUID of the snapshot row.
  final String id;
  final String userId;

  /// `YYYY-MM`, the period the snapshot covers.
  final String period;

  /// Composite score 0–100 derived from budget adherence.
  final double? budgetComplianceScore;

  /// `(income − expenses) / income * 100`. Null on months with zero income.
  final double? savingsRatePct;

  /// Number of categories that ended the period above their budget cap.
  final int overspendCategoriesCount;

  /// Recommendations the user saw vs. accepted that month — feeds the
  /// `Acceptance Rate >= 60%` KPI.
  final int recommendationsShown;
  final int recommendationsAccepted;
  final double? recommendationAcceptanceRate;

  /// Education engagement during the period.
  final int quizzesCompleted;
  final double? avgQuizScore;

  final DateTime createdAt;

  const FinancialProgressSnapshot({
    required this.id,
    required this.userId,
    required this.period,
    required this.budgetComplianceScore,
    required this.savingsRatePct,
    required this.overspendCategoriesCount,
    required this.recommendationsShown,
    required this.recommendationsAccepted,
    required this.recommendationAcceptanceRate,
    required this.quizzesCompleted,
    required this.avgQuizScore,
    required this.createdAt,
  });

  factory FinancialProgressSnapshot.fromJson(Map<String, dynamic> json) {
    return FinancialProgressSnapshot(
      id: json['id'] as String,
      userId: json['userId'] as String,
      period: json['period'] as String,
      budgetComplianceScore:
          (json['budgetComplianceScore'] as num?)?.toDouble(),
      savingsRatePct: (json['savingsRatePct'] as num?)?.toDouble(),
      overspendCategoriesCount:
          (json['overspendCategoriesCount'] as num?)?.toInt() ?? 0,
      recommendationsShown:
          (json['recommendationsShown'] as num?)?.toInt() ?? 0,
      recommendationsAccepted:
          (json['recommendationsAccepted'] as num?)?.toInt() ?? 0,
      recommendationAcceptanceRate:
          (json['recommendationAcceptanceRate'] as num?)?.toDouble(),
      quizzesCompleted: (json['quizzesCompleted'] as num?)?.toInt() ?? 0,
      avgQuizScore: (json['avgQuizScore'] as num?)?.toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class FinancialProgressApiService {
  /// Lists all snapshots for the authenticated user. Optional from/to
  /// filters use `YYYY-MM` format. Returns empty list when no
  /// snapshots have been generated yet.
  Future<List<FinancialProgressSnapshot>> list({
    String? from,
    String? to,
  }) async {
    final params = <String>[];
    if (from != null) params.add('from=$from');
    if (to != null) params.add('to=$to');
    final query = params.isEmpty ? '' : '?${params.join('&')}';
    final list = await ApiClient.getList('/financial-progress$query');
    return list
        .cast<Map<String, dynamic>>()
        .map(FinancialProgressSnapshot.fromJson)
        .toList();
  }

  /// Returns the snapshot for the current month, or null when none has
  /// been generated yet (backend returns 404).
  Future<FinancialProgressSnapshot?> current() async {
    try {
      final body = await ApiClient.get('/financial-progress/current');
      return FinancialProgressSnapshot.fromJson(body);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}

final financialProgressApiServiceProvider =
    Provider<FinancialProgressApiService>(
        (_) => FinancialProgressApiService());
