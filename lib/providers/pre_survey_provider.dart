import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/services/education_api_service.dart';
import '../core/services/pending_survey_queue.dart';
import '../features/auth/auth_controller.dart';

// Survey completion state comes from `/surveys/comparison`.
// If the API is temporarily unavailable, providers return true so routing never
// traps the user in a survey screen during connectivity issues.

class PreSurveyCompletionStore {
  static String _key(String userId) =>
      'zenda.survey.pre.server_completed.$userId';

  static Future<bool> isConfirmed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  static Future<void> markConfirmed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}

class PostSurveyCompletionStore {
  static String _key(String userId) =>
      'zenda.survey.post.server_completed.$userId';

  static Future<bool> isConfirmed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key(userId)) ?? false;
  }

  static Future<void> markConfirmed(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key(userId), true);
  }
}

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

    final locallyConfirmed = await PreSurveyCompletionStore.isConfirmed(userId);
    try {
      await PendingSurveyQueue.flushForUser(userId: userId);
      final status = await SurveysApiService().getPreStatus();
      if (status.isCompleted) {
        await PreSurveyCompletionStore.markConfirmed(userId);
        return true;
      }
      if (locallyConfirmed ||
          await PendingSurveyQueue.hasPending(userId: userId, type: 'PRE')) {
        return true;
      }
      return false;
    } catch (_) {
      try {
        final comparison = await SurveysApiService().getComparison();
        if (comparison.preScore != null) {
          await PreSurveyCompletionStore.markConfirmed(userId);
          return true;
        }
      } catch (_) {
        // Fall through to the durable, user-scoped completion state.
      }
      return locallyConfirmed ||
          await PendingSurveyQueue.hasPending(userId: userId, type: 'PRE');
    }
  }

  Future<void> markCompleted({bool confirmedByServer = true}) async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (confirmedByServer && userId != null) {
      await PreSurveyCompletionStore.markConfirmed(userId);
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

    final locallyConfirmed = await PostSurveyCompletionStore.isConfirmed(userId);
    try {
      await PendingSurveyQueue.flushForUser(userId: userId);
      final status = await SurveysApiService().getPostStatus();
      if (status.isCompleted) {
        await PostSurveyCompletionStore.markConfirmed(userId);
        return true;
      }
      if (locallyConfirmed ||
          await PendingSurveyQueue.hasPending(userId: userId, type: 'POST')) {
        return true;
      }
      return false;
    } catch (_) {
      try {
        final comparison = await SurveysApiService().getComparison();
        if (comparison.postScore != null) {
          await PostSurveyCompletionStore.markConfirmed(userId);
          return true;
        }
      } catch (_) {
        // Fall through to local state
      }
      return locallyConfirmed ||
          await PendingSurveyQueue.hasPending(userId: userId, type: 'POST');
    }
  }

  Future<void> markCompleted({bool confirmedByServer = true}) async {
    final userId = ref.read(authNotifierProvider).user?.id;
    if (confirmedByServer && userId != null) {
      await PostSurveyCompletionStore.markConfirmed(userId);
    }
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
