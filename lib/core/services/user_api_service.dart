import '../models/notification.dart';
import '../models/user.dart';
import 'api_client.dart';

class UserApiService {
  Future<User> getProfile() async {
    final body = await ApiClient.get('/users/me');
    return User.fromJson(body);
  }

  Future<User> updateProfile({
    String? fullName,
    int? age,
    String? university,
    IncomeType? incomeType,
    double? averageMonthlyIncome,
    FinancialLiteracyLevel? financialLiteracyLevel,
    bool? profileCompleted,
    String? currency,
  }) async {
    final data = <String, dynamic>{};

    if (fullName != null) data['fullName'] = fullName;
    if (age != null) data['age'] = age;
    if (university != null) data['university'] = university;
    if (incomeType != null) data['incomeType'] = incomeTypeToString(incomeType);
    if (averageMonthlyIncome != null) {
      data['averageMonthlyIncome'] = averageMonthlyIncome;
    }
    if (financialLiteracyLevel != null) {
      data['financialLiteracyLevel'] =
          literacyLevelToString(financialLiteracyLevel);
    }
    if (profileCompleted != null) data['profileCompleted'] = profileCompleted;
    if (currency != null) data['currency'] = currency;

    final body = await ApiClient.put('/users/me', data);
    return User.fromJson(body);
  }
}

// ── Notification Preferences ──────────────────────────────────────────────────

class NotificationPreference {
  final String type;
  final bool enabled;

  const NotificationPreference({required this.type, required this.enabled});

  factory NotificationPreference.fromJson(Map<String, dynamic> json) {
    return NotificationPreference(
      type: json['type'] as String,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}

class NotificationsApiService {
  Future<List<NotificationPreference>> getPreferences() async {
    final list = await ApiClient.getList('/notifications/preferences');
    return list
        .cast<Map<String, dynamic>>()
        .map(NotificationPreference.fromJson)
        .toList();
  }

  Future<void> updatePreference(String type, {required bool enabled}) async {
    await ApiClient.patch(
      '/notifications/preferences/$type',
      {'enabled': enabled},
    );
  }

  // ── Inbox ──────────────────────────────────────────────────────────────────

  Future<NotificationInboxPage> getInbox({int limit = 50, bool unreadOnly = false}) async {
    final query = 'limit=$limit&unreadOnly=$unreadOnly';
    final body = await ApiClient.get('/notifications/inbox?$query');
    return NotificationInboxPage.fromJson(body);
  }

  Future<AppNotification> markRead(String id) async {
    final body = await ApiClient.patch('/notifications/$id/read', const {});
    return AppNotification.fromJson(body);
  }

  Future<int> markAllRead() async {
    final body = await ApiClient.patch('/notifications/read-all', const {});
    final updated = body['updated'];
    return updated is num ? updated.toInt() : 0;
  }

  // ── FCM token registration ────────────────────────────────────────────────

  Future<void> registerFcmToken(String token) async {
    await ApiClient.post(
      '/notifications/fcm-token',
      {'token': token},
      authenticated: true,
    );
  }

  Future<void> unregisterFcmToken() async {
    await ApiClient.delete('/notifications/fcm-token');
  }

  Future<void> setDailyReminderTime(String? hhmm) async {
    await ApiClient.patch('/notifications/daily-reminder-time', {'time': hhmm});
  }
}
