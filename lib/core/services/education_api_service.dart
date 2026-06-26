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
  final bool isRead;
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
    this.isRead = false,
    this.completedAt,
    this.questionCount = 0,
    this.isLocked = false,
  });

  int get readingTimeMinutes =>
      (content.split(' ').length / 200).ceil().clamp(1, 30);

  factory EducationTopic.fromJson(Map<String, dynamic> json) {
    return EducationTopic(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      difficulty: json['difficulty'] as String,
      category: json['category'] as String? ?? 'budgeting',
      order: json['order'] as int,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      questionCount: json['questionCount'] as int? ?? 0,
      isLocked: json['isLocked'] as bool? ?? false,
    );
  }
}

class LearningPathStep {
  final String id;
  final String kind;
  final String? topicId;
  final String title;
  final String reason;
  final String focus;
  final String difficulty;
  final String status;
  final int order;
  final int estimatedMinutes;
  final String quizMode;

  const LearningPathStep({
    required this.id,
    required this.kind,
    this.topicId,
    required this.title,
    required this.reason,
    required this.focus,
    required this.difficulty,
    required this.status,
    required this.order,
    required this.estimatedMinutes,
    required this.quizMode,
  });

  bool get isTopic => kind == 'topic';
  bool get isPersonalizedQuiz => kind == 'personalized_quiz';
  bool get isCompleted => status == 'completed';
  bool get isRead => status == 'read';

  factory LearningPathStep.fromJson(Map<String, dynamic> json) {
    return LearningPathStep(
      id: json['id'] as String,
      kind: json['kind'] as String,
      topicId: json['topicId'] as String?,
      title: json['title'] as String,
      reason: json['reason'] as String? ?? '',
      focus: json['focus'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'BEGINNER',
      status: json['status'] as String? ?? 'pending',
      order: (json['order'] as num?)?.toInt() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 6,
      quizMode: json['quizMode'] as String? ?? 'app_topic_quiz',
    );
  }
}

class PersonalizedLearningPath {
  final DateTime? generatedAt;
  final String source;
  final String summary;
  final List<LearningPathStep> steps;

  const PersonalizedLearningPath({
    this.generatedAt,
    required this.source,
    required this.summary,
    required this.steps,
  });

  bool get usedAgent => source == 'agent';

  factory PersonalizedLearningPath.fromJson(Map<String, dynamic> json) {
    return PersonalizedLearningPath(
      generatedAt: json['generatedAt'] != null
          ? DateTime.tryParse(json['generatedAt'] as String)
          : null,
      source: json['source'] as String? ?? 'fallback',
      summary: json['summary'] as String? ?? '',
      steps: (json['steps'] as List<dynamic>? ?? const [])
          .cast<Map<String, dynamic>>()
          .map(LearningPathStep.fromJson)
          .toList(),
    );
  }
}

class EducationApiService {
  Future<List<EducationTopic>> listTopics() async {
    final list = await ApiClient.getList('/education/topics');
    return list
        .cast<Map<String, dynamic>>()
        .map(EducationTopic.fromJson)
        .toList();
  }

  Future<EducationTopic> getTopic(String id) async {
    final data = await ApiClient.get('/education/topics/$id');
    return EducationTopic.fromJson(data);
  }

  Future<void> completeTopic(String id) async {
    await ApiClient.patch('/education/topics/$id/complete', {});
  }

  Future<void> markRead(String id) async {
    await ApiClient.patch('/education/topics/$id/read', {});
  }

  Future<PersonalizedQuizResult> getPersonalizedQuiz({
    String language = 'es',
  }) async {
    final data = await ApiClient.get(
      '/education/quiz/personalized?language=$language',
    );
    return PersonalizedQuizResult.fromJson(data);
  }

  Future<PersonalizedLearningPath> getPersonalizedLearningPath({
    String language = 'es',
  }) async {
    final data = await ApiClient.get(
      '/education/learning-path/personalized?language=$language',
    );
    return PersonalizedLearningPath.fromJson(data);
  }

  Future<Map<String, dynamic>> submitPersonalizedQuiz(
    Map<String, String> answers,
  ) async {
    return ApiClient.post('/education/quiz/personalized/submit', {
      'answers': answers,
    }, authenticated: true);
  }
}

// ── Feedback ──────────────────────────────────────────────────────────────────

class FeedbackApiService {
  Future<void> submit({
    required String type,
    required String message,
    String? screenName,
    int? rating,
  }) async {
    await ApiClient.post('/feedback', {
      'type': type,
      'message': message,
      'screenName': ?screenName,
      'rating': ?rating,
    }, authenticated: true);
  }
}

// ── Surveys ───────────────────────────────────────────────────────────────────

class SurveyQuestion {
  final String id;
  final int order;
  final String text;
  final List<String> options;

  const SurveyQuestion({
    required this.id,
    required this.order,
    required this.text,
    required this.options,
  });

  factory SurveyQuestion.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    List<String> options;
    if (rawOptions is List) {
      options = rawOptions.cast<String>();
    } else if (rawOptions is Map) {
      options = rawOptions.values.cast<String>().toList();
    } else {
      options = [];
    }
    return SurveyQuestion(
      id: json['id'] as String,
      order: json['order'] as int,
      text: json['text'] as String,
      options: options,
    );
  }
}

class Survey {
  final String id;
  final String type;
  final List<SurveyQuestion> questions;

  const Survey({required this.id, required this.type, required this.questions});

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      id: json['id'] as String,
      type: json['type'] as String,
      questions: (json['questions'] as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(SurveyQuestion.fromJson)
          .toList(),
    );
  }
}

class SurveyResult {
  final double score;
  final String? level;
  final double? improvement;
  final int? xpEarned;
  final String? badgeUnlocked;

  const SurveyResult({
    required this.score,
    this.level,
    this.improvement,
    this.xpEarned,
    this.badgeUnlocked,
  });

  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String?,
      improvement: (json['improvement'] as num?)?.toDouble(),
      xpEarned: (json['xpEarned'] as num?)?.toInt(),
      badgeUnlocked: json['badgeUnlocked'] as String?,
    );
  }
}

class SusResult {
  final int susScore;
  final String grade;

  const SusResult({required this.susScore, required this.grade});

  factory SusResult.fromJson(Map<String, dynamic> json) {
    return SusResult(
      susScore: (json['susScore'] as num).toInt(),
      grade: json['grade'] as String,
    );
  }
}

class SurveyComparison {
  final double? preScore;
  final double? postScore;
  final double? improvementPercentage;

  const SurveyComparison({
    required this.preScore,
    required this.postScore,
    required this.improvementPercentage,
  });

  factory SurveyComparison.fromJson(Map<String, dynamic> json) {
    return SurveyComparison(
      preScore: (json['preScore'] as num?)?.toDouble(),
      postScore: (json['postScore'] as num?)?.toDouble(),
      improvementPercentage: (json['improvementPercentage'] as num?)
          ?.toDouble(),
    );
  }
}

class SurveysApiService {
  Future<Survey> getPreSurvey() async {
    final data = await ApiClient.get('/surveys/pre');
    return Survey.fromJson(data);
  }

  Future<Survey> getPostSurvey() async {
    final data = await ApiClient.get('/surveys/post');
    return Survey.fromJson(data);
  }

  Future<SurveyResult> submitPre(Map<String, String> answers) async {
    final data = await ApiClient.post('/surveys/pre/response', {
      'answers': answers,
    }, authenticated: true);
    return SurveyResult.fromJson(data);
  }

  Future<SurveyResult> submitPost(Map<String, String> answers) async {
    final data = await ApiClient.post('/surveys/post/response', {
      'answers': answers,
    }, authenticated: true);
    return SurveyResult.fromJson(data);
  }

  Future<SurveyComparison> getComparison() async {
    final data = await ApiClient.get('/surveys/comparison');
    return SurveyComparison.fromJson(data);
  }

  Future<Survey> getSusSurvey() async {
    final data = await ApiClient.get('/surveys/sus');
    return Survey.fromJson(data);
  }

  Future<SusResult> submitSus(Map<String, String> answers) async {
    final data = await ApiClient.post('/surveys/sus/response', {
      'answers': answers,
    }, authenticated: true);
    return SusResult.fromJson(data);
  }
}

// ── Challenges ────────────────────────────────────────────────────────────────

class Challenge {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final String status;
  final int? progressCurrent;
  final int? progressTotal;
  final String? daysLeft;
  final String? badgeReward;

  /// Backend-computed deadline for an accepted challenge (AC.6 / EXPIRED state).
  /// Null when the challenge is open-ended or not yet accepted.
  final DateTime? expiresAt;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsReward,
    required this.status,
    this.progressCurrent,
    this.progressTotal,
    this.daysLeft,
    this.badgeReward,
    this.expiresAt,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final expiresAtRaw = json['expiresAt'] as String?;
    final expiresAt = expiresAtRaw != null && expiresAtRaw.isNotEmpty
        ? DateTime.tryParse(expiresAtRaw)
        : null;

    // Prefer backend-provided daysLeft (legacy field). Fall back to
    // computing it from expiresAt so the chip works without extra payload.
    String? daysLeft = json['daysLeft']?.toString();
    if (daysLeft == null && expiresAt != null) {
      final diff = expiresAt.difference(DateTime.now()).inDays;
      if (diff > 0) daysLeft = diff.toString();
    }

    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      pointsReward: json['pointsReward'] as int? ?? 0,
      status: json['status'] as String? ?? 'AVAILABLE',
      progressCurrent: json['progressCurrent'] as int?,
      progressTotal: json['progressTotal'] as int?,
      daysLeft: daysLeft,
      badgeReward: json['badgeReward'] as String?,
      expiresAt: expiresAt,
    );
  }
}

class ChallengesApiService {
  Future<List<Challenge>> getAll() async {
    final list = await ApiClient.getList('/challenges');
    return list.cast<Map<String, dynamic>>().map(Challenge.fromJson).toList();
  }

  Future<void> accept(String id) async {
    await ApiClient.post('/challenges/$id/accept', {}, authenticated: true);
  }

  Future<void> complete(String id) async {
    await ApiClient.post('/challenges/$id/complete', {}, authenticated: true);
  }
}

// ── Badges ────────────────────────────────────────────────────────────────────

class ZendaBadge {
  final String id;
  final String name;
  final String description;
  final String? iconUrl;
  final bool isEarned;
  final DateTime? earnedAt;

  const ZendaBadge({
    required this.id,
    required this.name,
    required this.description,
    this.iconUrl,
    required this.isEarned,
    this.earnedAt,
  });

  factory ZendaBadge.fromJson(Map<String, dynamic> json) {
    return ZendaBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String?,
      isEarned: json['isEarned'] as bool? ?? false,
      earnedAt: json['earnedAt'] != null
          ? DateTime.tryParse(json['earnedAt'] as String)
          : null,
    );
  }
}

class BadgesApiService {
  Future<List<ZendaBadge>> getAll() async {
    final list = await ApiClient.getList('/badges');
    return list.cast<Map<String, dynamic>>().map(ZendaBadge.fromJson).toList();
  }
}
