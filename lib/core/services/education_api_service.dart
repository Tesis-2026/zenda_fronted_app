import '../models/quiz_models.dart';
import 'api_client.dart';

class EducationTopic {
  final String id;
  final String title;
  final String content;
  final String difficulty;
  final String category;
  final int order;
  final bool isCompleted;
  final DateTime? completedAt;
  final int questionCount;
  final bool isLocked;

  const EducationTopic({
    required this.id,
    required this.title,
    required this.content,
    required this.difficulty,
    this.category = 'budgeting',
    required this.order,
    required this.isCompleted,
    this.completedAt,
    this.questionCount = 0,
    this.isLocked = false,
  });

  int get readingTimeMinutes => (content.split(' ').length / 200).ceil().clamp(1, 30);

  factory EducationTopic.fromJson(Map<String, dynamic> json) {
    return EducationTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String? ?? 'budgeting',
      order: json['order'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      questionCount: json['questionCount'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

class EducationApiService {
  Future<List<EducationTopic>> listTopics() async {
    final list = await ApiClient.getList('/education/topics');
    return list.cast<Map<String, dynamic>>().map(EducationTopic.fromJson).toList();
  }

  Future<EducationTopic> getTopic(String id) async {
    final data = await ApiClient.get('/education/topics/$id');
    return EducationTopic.fromJson(data);
  }

  Future<void> completeTopic(String id) async {
    await ApiClient.patch('/education/topics/$id/complete', {});
  }

  Future<PersonalizedQuizResult> getPersonalizedQuiz({String language = 'es'}) async {
    final data = await ApiClient.get('/education/quiz/personalized?language=$language');
    return PersonalizedQuizResult.fromJson(data);
  }

  Future<Map<String, dynamic>> submitPersonalizedQuiz(Map<String, String> answers) async {
    return ApiClient.post(
      '/education/quiz/personalized/submit',
      {'answers': answers},
      authenticated: true,
    );
  }
}
