import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/education_api_service.dart';
import '../core/services/pending_survey_queue.dart';
import '../features/auth/auth_controller.dart';

// Survey completion state comes from `/surveys/comparison`.
// If the API is temporarily unavailable, providers return true so routing never
// traps the user in a survey screen during connectivity issues.

class _SurveySkipStore {
  static String _key(String userId, String surveyType) =>
      'zenda.survey.$surveyType.skipped.$userId';

  static Future<bool> isSkipped(String userId, String surveyType) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId, surveyType)) ?? false;
  }

  static Future<void> markSkipped(String userId, String surveyType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId, surveyType), true);
  }
}

class PreSurveyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final userId = ref.watch(
      authNotifierProvider.select((state) => state.user?.id),
    );
    if (userId == null) return true;
    if (await _SurveySkipStore.isSkipped(userId, 'pre')) return true;

    try {
      await PendingSurveyQueue.flushForUser(userId: userId);
      final comparison = await SurveysApiService().getComparison();
      return comparison.preScore != null;
    } catch (_) {
      return true;
    }
  }

  Future<void> markCompleted() async {
    state = const AsyncData(true);
  }

  Future<void> skipForNow() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId != null) {
      await _SurveySkipStore.markSkipped(userId, 'pre');
    }
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
    final userId = ref.watch(
      authNotifierProvider.select((state) => state.user?.id),
    );
    if (userId == null) return true;
    if (await _SurveySkipStore.isSkipped(userId, 'post')) return true;

    try {
      await PendingSurveyQueue.flushForUser(userId: userId);
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

  Future<void> skipForNow() async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (userId != null) {
      await _SurveySkipStore.markSkipped(userId, 'post');
    }
    state = const AsyncData(true);
  }
}

final postSurveyProvider = AsyncNotifierProvider<PostSurveyNotifier, bool>(
  PostSurveyNotifier.new,
);
