class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, String>? data;
  final DateTime? readAt;
  final DateTime? sentAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.readAt,
    required this.sentAt,
    required this.createdAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    Map<String, String>? data;
    final raw = json['data'];
    if (raw is Map) {
      data = raw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? ''));
    }
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: data,
      readAt: _parseDate(json['readAt']),
      sentAt: _parseDate(json['sentAt']),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class NotificationInboxPage {
  final List<AppNotification> items;
  final int unreadCount;

  const NotificationInboxPage({required this.items, required this.unreadCount});

  factory NotificationInboxPage.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>;
    return NotificationInboxPage(
      items: rawItems
          .cast<Map<String, dynamic>>()
          .map(AppNotification.fromJson)
          .toList(),
      unreadCount: (json['unreadCount'] as num).toInt(),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  return null;
}
