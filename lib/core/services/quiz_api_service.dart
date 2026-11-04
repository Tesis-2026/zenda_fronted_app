import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/quiz_models.dart';
import 'api_client.dart';

abstract class QuizApiService {
  Future<List<QuizQuestion>> getQuiz(String topicId, String language);
  Future<QuizResult> submitQuiz(String topicId, Map<String, String> answers);

  /// Grades one answer for immediate feedback; nothing is persisted.
  Future<QuizFeedback> checkAnswer(String questionId, String answer);
}

class LiveQuizApiService extends QuizApiService {
  @override
  Future<List<QuizQuestion>> getQuiz(String topicId, String language) async {
    final data = await ApiClient.get(
        '/education/topics/$topicId/quiz?language=$language');
    return (data['questions'] as List<dynamic>)
        .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<QuizResult> submitQuiz(
    String topicId,
    Map<String, String> answers,
  ) async {
    final data = await ApiClient.post(
      '/education/topics/$topicId/quiz/submit',
      {'answers': answers},
      authenticated: true,
    );
    return QuizResult.fromJson(data);
  }

  @override
  Future<QuizFeedback> checkAnswer(String questionId, String answer) async {
    final data = await ApiClient.post(
      '/education/quiz/check',
      {'questionId': questionId, 'answer': answer},
      authenticated: true,
    );
    return QuizFeedback.fromJson(data);
  }
}

final quizServiceProvider =
    Provider<QuizApiService>((ref) => LiveQuizApiService());
