import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import 'api_client.dart';
import 'study_analytics_service.dart';
import 'telemetry_policy.dart';

const _kPendingKey = 'zenda.pending_analytics_events';
const _kMaxPending = 200;

class StudyTelemetryService {
  StudyTelemetryService._();

  static bool _flushing = false;

  static void track(
    String eventType, {
    Map<String, Object?> metadata = const {},
    bool backend = true,
  }) {
    if (!StudyAnalyticsService.consentGiven) return;
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
    final payload = <String, Object>{
      'eventType': eventType,
      'metadata': safeTelemetryParameters(_jsonMetadata(metadata)),
    };
    try {
      await _post(payload);
      // Connectivity is back: drain whatever failed earlier.
      unawaited(flushPending());
    } catch (e) {
      // Never block the UX; keep the event for the next sync (CP074).
      developer.log(
        'Backend analytics event queued for retry: ${e.runtimeType}',
        name: 'study',
      );
      await _enqueue(payload);
    }
  }

  static Future<void> _post(Map<String, Object> payload) =>
      ApiClient.post('/analytics/events', payload, authenticated: true);

  static Future<void> _enqueue(Map<String, Object> payload) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_kPendingKey) ?? <String>[];
      queue.add(jsonEncode(payload));
      // Oldest events are dropped first once the cap is hit.
      final capped = queue.length > _kMaxPending
          ? queue.sublist(queue.length - _kMaxPending)
          : queue;
      await prefs.setStringList(_kPendingKey, capped);
    } catch (e) {
      developer.log('Could not queue analytics event: $e', name: 'study');
    }
  }

  /// Re-sends queued events in order; stops at the first failure so the
  /// rest wait for the next sync.
  static Future<void> flushPending() async {
    if (_flushing) return;
    _flushing = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final queue = prefs.getStringList(_kPendingKey) ?? <String>[];
      var sent = 0;
      for (final raw in queue) {
        final decoded = jsonDecode(raw);
        if (decoded is! Map<String, dynamic>) {
          sent++;
          continue;
        }
        try {
          await _post(decoded.cast<String, Object>());
          sent++;
        } catch (_) {
          break;
        }
      }
      if (sent > 0) {
        // Re-read: events queued while this flush was sending were appended
        // after the snapshot and must not be overwritten.
        final current = prefs.getStringList(_kPendingKey) ?? <String>[];
        final drop = sent < current.length ? sent : current.length;
        await prefs.setStringList(_kPendingKey, current.sublist(drop));
      }
    } catch (e) {
      developer.log('Analytics flush failed: $e', name: 'study');
    } finally {
      _flushing = false;
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
