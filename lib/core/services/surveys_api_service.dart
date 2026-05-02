import 'api_client.dart';

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

  const SurveyResult({required this.score, this.level, this.improvement});

  factory SurveyResult.fromJson(Map<String, dynamic> json) {
    return SurveyResult(
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String?,
      improvement: (json['improvement'] as num?)?.toDouble(),
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
      improvementPercentage: (json['improvementPercentage'] as num?)?.toDouble(),
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
    final data = await ApiClient.post('/surveys/pre/response', {'answers': answers});
    return SurveyResult.fromJson(data);
  }

  Future<SurveyResult> submitPost(Map<String, String> answers) async {
    final data = await ApiClient.post('/surveys/post/response', {'answers': answers});
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
    final data = await ApiClient.post('/surveys/sus/response', {'answers': answers});
    return SusResult.fromJson(data);
  }
}
