import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import 'api_client.dart';
import 'education_api_service.dart';

class PendingSurveyQueue {
  PendingSurveyQueue._();

  static String _key(String userId, String type) =>
      'zenda.pending_survey.${type.toLowerCase()}.$userId';

  static Future<void> save({
    required String userId,
    required String type,
    required Map<String, String> answers,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key(userId, type),
      jsonEncode({
        'type': type,
        'answers': answers,
        'createdAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  static Future<void> remove({
    required String userId,
    required String type,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(userId, type));
  }

  static Future<void> flushForUser({
    required String userId,
    SurveysApiService? service,
  }) async {
    final api = service ?? SurveysApiService();
    await Future.wait([
      _flushOne(userId: userId, type: 'PRE', service: api),
      _flushOne(userId: userId, type: 'POST', service: api),
    ]);
  }

  static Future<void> _flushOne({
    required String userId,
    required String type,
    required SurveysApiService service,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(userId, type));
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final answers = (decoded['answers'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value.toString()),
      );
      if (type == 'PRE') {
        await service.submitPre(answers);
      } else if (type == 'POST') {
        await service.submitPost(answers);
      }
      await prefs.remove(_key(userId, type));
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        await prefs.remove(_key(userId, type));
        return;
      }
      developer.log(
        'Pending survey retry skipped: $e',
        name: 'PendingSurveyQueue',
        level: 800,
      );
    }
  }
}
