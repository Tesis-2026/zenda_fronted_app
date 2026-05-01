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
