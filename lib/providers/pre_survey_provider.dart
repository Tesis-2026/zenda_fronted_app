import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/education_api_service.dart';

// Survey completion state comes from `/surveys/comparison`.
// If the API is temporarily unavailable, providers return true so routing never
// traps the user in a survey screen during connectivity issues.

class PreSurveyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      final comparison = await SurveysApiService().getComparison();
      return comparison.preScore != null;
    } catch (_) {
      return true;
    }
  }

  Future<void> markCompleted() async {
    state = const AsyncData(true);
  }

  static Future<DateTime?> completedAt() async => null;
}

final preSurveyProvider = AsyncNotifierProvider<PreSurveyNotifier, bool>(
  PreSurveyNotifier.new,
);

class PostSurveyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    try {
      final comparison = await SurveysApiService().getComparison();
      return comparison.postScore != null;
    } catch (_) {
      // Avoid showing a survey prompt during transient network/API failures.
      return true;
    }
  }

  Future<void> markCompleted() async {
    state = const AsyncData(true);
  }
}

final postSurveyProvider = AsyncNotifierProvider<PostSurveyNotifier, bool>(
  PostSurveyNotifier.new,
);
