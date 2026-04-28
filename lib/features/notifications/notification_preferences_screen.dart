import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/notifications_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _notificationsServiceProvider = Provider<NotificationsApiService>(
  (_) => NotificationsApiService(),
);

final _preferencesProvider =
    FutureProvider.autoDispose<List<NotificationPreference>>((ref) {
  return ref.read(_notificationsServiceProvider).getPreferences();
});

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefsAsync = ref.watch(_preferencesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.notificationsErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_preferencesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (prefs) => ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: prefs.length,
          itemBuilder: (context, index) {
            final pref = prefs[index];
            return _PreferenceTile(
              pref: pref,
              onToggle: (enabled) async {
                await ref
                    .read(_notificationsServiceProvider)
                    .updatePreference(pref.type, enabled: enabled);
                ref.invalidate(_preferencesProvider);
              },
            );
          },
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({required this.pref, required this.onToggle});
  final NotificationPreference pref;
  final Future<void> Function(bool) onToggle;

  IconData _iconForType(String type) {
    switch (type) {
      case 'BUDGET_ALERT':
        return Icons.pie_chart_outline;
      case 'ANOMALY_ALERT':
        return Icons.warning_amber_outlined;
      case 'PREDICTION_READY':
        return Icons.analytics_outlined;
      case 'CHALLENGE_REMINDER':
        return Icons.flag_outlined;
      case 'DAILY_REMINDER':
        return Icons.notifications_outlined;
      case 'BADGE_EARNED':
        return Icons.military_tech_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _labelForType(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'BUDGET_ALERT':
        return l10n.notificationTypeBudgetAlert;
      case 'ANOMALY_ALERT':
        return l10n.notificationTypeAnomalyAlert;
      case 'PREDICTION_READY':
        return l10n.notificationTypePredictionReady;
      case 'CHALLENGE_REMINDER':
        return l10n.notificationTypeChallengeReminder;
      case 'DAILY_REMINDER':
        return l10n.notificationTypeDailyReminder;
      case 'BADGE_EARNED':
        return l10n.notificationTypeBadgeEarned;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(_iconForType(pref.type)),
      title: Text(_labelForType(context, pref.type)),
      value: pref.enabled,
      onChanged: (v) => onToggle(v),
    );
  }
}
