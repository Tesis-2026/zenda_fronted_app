import 'package:flutter_riverpod/flutter_riverpod.dart';

// Surveys are disabled — both providers always report completed so the router
// never redirects to /surveys/pre or shows the post-survey banner.

class PreSurveyNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async => true;

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
  Future<bool> build() async => true;

  Future<void> markCompleted() async {
    state = const AsyncData(true);
  }
}

final postSurveyProvider = AsyncNotifierProvider<PostSurveyNotifier, bool>(
  PostSurveyNotifier.new,
);
