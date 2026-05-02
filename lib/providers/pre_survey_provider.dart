import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreSurveyNotifier extends AsyncNotifier<bool> {
  static const _key = 'pre_survey_completed';
  static const _completedAtKey = 'pre_survey_completed_at_ms';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    await prefs.setInt(
        _completedAtKey, DateTime.now().millisecondsSinceEpoch);
    state = const AsyncData(true);
  }

  static Future<DateTime?> completedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final ms = prefs.getInt(_completedAtKey);
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }
}

final preSurveyProvider = AsyncNotifierProvider<PreSurveyNotifier, bool>(
  PreSurveyNotifier.new,
);

class PostSurveyNotifier extends AsyncNotifier<bool> {
  static const _key = 'post_survey_completed';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = const AsyncData(true);
  }
}

final postSurveyProvider = AsyncNotifierProvider<PostSurveyNotifier, bool>(
  PostSurveyNotifier.new,
);
