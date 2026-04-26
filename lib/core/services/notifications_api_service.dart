import 'api_client.dart';

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
}
