import 'dart:async';
import 'dart:developer' as developer;

import '../config/app_config.dart';
import 'api_client.dart';
import 'study_analytics_service.dart';

class StudyTelemetryService {
  StudyTelemetryService._();

  static void track(
    String eventType, {
    Map<String, Object?> metadata = const {},
    bool backend = true,
  }) {
    unawaited(StudyAnalyticsService.logEvent(eventType, parameters: metadata));
    if (!backend) return;
    unawaited(_sendToBackend(eventType, metadata));
  }

  static void screen(String screenName) {
    track('screen_view', metadata: {'screen': screenName}, backend: true);
  }

  static Future<void> _sendToBackend(
    String eventType,
    Map<String, Object?> metadata,
  ) async {
    try {
      await ApiClient.post('/analytics/events', {
        'eventType': eventType,
        'metadata': _jsonMetadata(metadata),
      }, authenticated: true);
    } catch (e) {
      // Offline / unauthenticated sessions should never block the UX.
      developer.log('Backend analytics event skipped: $e', name: 'study');
    }
  }

  static Map<String, Object> _jsonMetadata(Map<String, Object?> metadata) {
    final sanitized = <String, Object>{
      'app_env': AppConfig.env.name,
      'beta_distribution_id': AppConfig.betaDistributionId,
    };
    for (final entry in metadata.entries) {
      final value = entry.value;
      if (value == null) continue;
      if (value is String || value is num || value is bool) {
        sanitized[entry.key] = value;
      } else if (value is DateTime) {
        sanitized[entry.key] = value.toIso8601String();
      } else {
        sanitized[entry.key] = value.toString();
      }
    }
    return sanitized;
  }
}
