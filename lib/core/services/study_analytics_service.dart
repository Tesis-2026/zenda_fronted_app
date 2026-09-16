import 'dart:developer' as developer;
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'telemetry_policy.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class StudyAnalyticsService {
  StudyAnalyticsService._();

  static bool _firebaseReady = false;
  static bool consentGiven = false;
  static FirebaseRemoteConfig? _remoteConfig;

  static bool get firebaseReady => _firebaseReady;

  static Future<void> initialize({
    required String appEnv,
    required String betaDistributionId,
  }) async {
    try {
      await Firebase.initializeApp();
      _firebaseReady = true;

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        recordError(
          details.exception,
          details.stack ?? StackTrace.empty,
          fatal: true,
        );
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        recordError(error, stack, fatal: true);
        return true;
      };

      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
      await FirebaseAnalytics.instance.setDefaultEventParameters({
        'app_env': appEnv,
        'beta_distribution_id': betaDistributionId,
      });
      try {
        await _initRemoteConfig();
      } catch (e) {
        developer.log('Remote Config defaults only: $e', name: 'study');
      }
    } catch (e, stack) {
      _firebaseReady = false;
      developer.log(
        'Firebase study tooling disabled: $e',
        name: 'study',
        error: e,
        stackTrace: stack,
      );
    }
  }

  static Future<void> _initRemoteConfig() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    _remoteConfig = remoteConfig;
    await remoteConfig.setDefaults({
      'zenda_study_enabled': true,
      'zenda_sus_prompt_enabled': true,
      'zenda_sus_force_prompt': false,
      'zenda_sus_min_sessions': 3,
      'zenda_sus_min_transactions': 5,
      'zenda_sus_min_chat_messages': 3,
    });
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 8),
        minimumFetchInterval: kDebugMode
            ? const Duration(minutes: 5)
            : const Duration(hours: 1),
      ),
    );
    await remoteConfig.fetchAndActivate().timeout(
      const Duration(seconds: 10),
      onTimeout: () => false,
    );
  }

  static bool get studyEnabled =>
      _remoteConfig?.getBool('zenda_study_enabled') ?? true;

  static bool get susPromptEnabled =>
      _remoteConfig?.getBool('zenda_sus_prompt_enabled') ?? true;

  static bool get susForcePrompt =>
      _remoteConfig?.getBool('zenda_sus_force_prompt') ?? false;

  static int get susMinSessions =>
      _remoteConfig?.getInt('zenda_sus_min_sessions') ?? 3;

  static int get susMinTransactions =>
      _remoteConfig?.getInt('zenda_sus_min_transactions') ?? 5;

  static int get susMinChatMessages =>
      _remoteConfig?.getInt('zenda_sus_min_chat_messages') ?? 3;

  static Future<void> setUserId(String? userId, {bool consent = false}) async {
    consentGiven = consent && userId != null;
    if (!_firebaseReady) return;
    try {
      final participantId = consentGiven
          ? sha256.convert(utf8.encode('zenda-pilot-v1:$userId')).toString()
          : null;
      await FirebaseAnalytics.instance.setUserId(id: participantId);
      await FirebaseCrashlytics.instance.setUserIdentifier(participantId ?? '');
      await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
        consentGiven,
      );
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(
        consentGiven,
      );
    } catch (e) {
      developer.log('Study user id failed: $e', name: 'study');
    }
  }

  static Future<void> logEvent(
    String name, {
    Map<String, Object?> parameters = const {},
  }) async {
    if (!_firebaseReady || !studyEnabled || !consentGiven) return;
    try {
      await FirebaseAnalytics.instance.logEvent(
        name: name,
        parameters: safeTelemetryParameters(parameters).map(
          (key, value) =>
              MapEntry(key, value is bool ? (value ? 1 : 0) : value),
        ),
      );
    } catch (e) {
      developer.log('Firebase analytics event failed: $e', name: 'study');
    }
  }

  static Future<void> logScreen(String screenName) {
    return logEvent('screen_view', parameters: {'screen': screenName});
  }

  static void recordError(
    Object error,
    StackTrace stack, {
    bool fatal = false,
  }) {
    if (!_firebaseReady || !consentGiven) return;
    FirebaseCrashlytics.instance
        .recordError(
          error.runtimeType.toString(),
          StackTrace.empty,
          fatal: fatal,
        )
        .catchError((_) {});
  }
}
