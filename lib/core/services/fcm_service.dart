import 'dart:async';
import 'dart:developer' as developer;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'user_api_service.dart';

// Background handler must be a top-level function. Foreground messages are
// handled in FcmService._onForegroundMessage.
@pragma('vm:entry-point')
Future<void> _firebaseBackgroundHandler(RemoteMessage message) async {
  developer.log('FCM background message: ${message.messageId}', name: 'fcm');
}

class FcmService {
  FcmService(this._api);

  final NotificationsApiService _api;

  static const _androidChannel = AndroidNotificationChannel(
    'zenda_default',
    'Zenda notifications',
    description: 'Recordatorios, alertas y logros de Zenda',
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _cachedToken;
  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;
  StreamSubscription<RemoteMessage>? _openedAppSub;

  /// Stream of newly tapped notification messages — Apps can listen to navigate
  /// to the inbox screen. Emits when the user opens a notification while the
  /// app is in background or terminated.
  final StreamController<RemoteMessage> _onTap = StreamController.broadcast();
  Stream<RemoteMessage> get onMessageTap => _onTap.stream;

  /// Sets up Firebase + local notifications + listeners. Idempotent.
  /// Backend registration is done separately via [registerWithBackend].
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    try {
      await Firebase.initializeApp();
    } catch (e) {
      developer.log('Firebase.initializeApp failed: $e — push disabled', name: 'fcm');
      _initialized = false;
      return;
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundHandler);

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();

    // Configure foreground presentation on iOS.
    if (!kIsWeb) {
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Local notifications channel + initialization (used for foreground messages
    // because FCM does not render system notifications when the app is open).
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _localNotifications.initialize(initSettings);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    _foregroundSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    _openedAppSub = FirebaseMessaging.onMessageOpenedApp.listen(_onTap.add);

    // Notification that launched the app from terminated state.
    final initial = await messaging.getInitialMessage();
    if (initial != null) _onTap.add(initial);

    _tokenRefreshSub = messaging.onTokenRefresh.listen((newToken) async {
      _cachedToken = newToken;
      await _safeRegister(newToken);
    });
  }

  /// Reads the current FCM token and POSTs it to the backend. Requires the
  /// user to be authenticated (the ApiClient injects the JWT).
  Future<void> registerWithBackend() async {
    if (!_initialized) return;
    try {
      final token = _cachedToken ?? await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _cachedToken = token;
      await _safeRegister(token);
    } catch (e) {
      developer.log('FCM token fetch failed: $e', name: 'fcm');
    }
  }

  /// Clears the token from the backend (called on logout).
  Future<void> unregisterFromBackend() async {
    try {
      await _api.unregisterFcmToken();
    } catch (e) {
      developer.log('FCM unregister failed: $e', name: 'fcm');
    }
  }

  Future<void> _safeRegister(String token) async {
    try {
      await _api.registerFcmToken(token);
    } catch (e) {
      developer.log('FCM register failed: $e', name: 'fcm');
    }
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedAppSub?.cancel();
    await _onTap.close();
  }
}
