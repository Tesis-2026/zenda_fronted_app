import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/notification.dart';
import '../../providers/repositories_providers.dart';

final notificationsInboxProvider =
    AsyncNotifierProvider<NotificationsInboxNotifier, NotificationInboxPage>(
        NotificationsInboxNotifier.new);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final inbox = ref.watch(notificationsInboxProvider);
  return inbox.asData?.value.unreadCount ?? 0;
});

class NotificationsInboxNotifier extends AsyncNotifier<NotificationInboxPage> {
  @override
  Future<NotificationInboxPage> build() async {
    final api = ref.read(notificationsServiceProvider);
    return api.getInbox();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final api = ref.read(notificationsServiceProvider);
      return api.getInbox();
    });
  }

  Future<void> markRead(String id) async {
    final api = ref.read(notificationsServiceProvider);
    try {
      await api.markRead(id);
    } finally {
      await refresh();
    }
  }

  Future<void> markAllRead() async {
    final api = ref.read(notificationsServiceProvider);
    try {
      await api.markAllRead();
    } finally {
      await refresh();
    }
  }
}
