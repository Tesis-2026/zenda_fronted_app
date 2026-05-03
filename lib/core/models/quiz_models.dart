// ── Topic quiz models ─────────────────────────────────────────────────────────

class QuizQuestion {
  final String id;
  final String difficulty;
  final String text;
  final List<String> options;
  final String? explanation;

  const QuizQuestion({
    required this.id,
    required this.difficulty,
    required this.text,
    required this.options,
    this.explanation,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) => QuizQuestion(
        id: json['id'] as String,
        difficulty: json['difficulty'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
        explanation: json['explanation'] as String?,
      );
}

class QuizFeedback {
  final String questionId;
  final bool correct;
  final String correctAnswer;

  const QuizFeedback({
    required this.questionId,
    required this.correct,
    required this.correctAnswer,
  });

  factory QuizFeedback.fromJson(Map<String, dynamic> json) => QuizFeedback(
        questionId: json['questionId'] as String,
        correct: json['correct'] as bool,
        correctAnswer: json['correctAnswer'] as String,
      );
}

class QuizResult {
  final int score;
  final int correctCount;
  final int totalCount;
  final String level;
  final List<QuizFeedback> feedback;

  const QuizResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.level,
    required this.feedback,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        score: json['score'] as int,
        correctCount: json['correctCount'] as int,
        totalCount: json['totalCount'] as int,
        level: json['level'] as String,
        feedback: (json['feedback'] as List<dynamic>)
            .map((e) => QuizFeedback.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// ── Personalized quiz models ──────────────────────────────────────────────────

class PersonalizedQuizQuestion {
  final String id;
  final String difficulty;
  final String text;
  final List<String> options;

  const PersonalizedQuizQuestion({
    required this.id,
    required this.difficulty,
    required this.text,
    required this.options,
  });

  factory PersonalizedQuizQuestion.fromJson(Map<String, dynamic> json) =>
      PersonalizedQuizQuestion(
        id: json['id'] as String,
        difficulty: json['difficulty'] as String,
        text: json['text'] as String,
        options: (json['options'] as List<dynamic>).cast<String>(),
      );
}

class PersonalizedQuizResult {
  final List<PersonalizedQuizQuestion> questions;
  final int attemptsRemainingToday;

  const PersonalizedQuizResult({
    required this.questions,
    required this.attemptsRemainingToday,
  });

  factory PersonalizedQuizResult.fromJson(Map<String, dynamic> json) =>
      PersonalizedQuizResult(
        questions: (json['questions'] as List<dynamic>)
            .map((e) => PersonalizedQuizQuestion.fromJson(e as Map<String, dynamic>))
            .toList(),
        attemptsRemainingToday: json['attemptsRemainingToday'] as int? ?? 0,
      );
}
