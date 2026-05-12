import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/user_api_service.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/repositories_providers.dart';

final _preferencesProvider =
    FutureProvider.autoDispose<List<NotificationPreference>>((ref) {
  return ref.read(notificationsServiceProvider).getPreferences();
});

class NotificationPreferencesScreen extends ConsumerWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefsAsync = ref.watch(_preferencesProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(title: l10n.notificationsTitle),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) {
          // Hardcoded demo fallback when API is unavailable
          const demoPrefs = [
            NotificationPreference(type: 'BUDGET_ALERT', enabled: true),
            NotificationPreference(type: 'BADGE_EARNED', enabled: true),
            NotificationPreference(type: 'ANOMALY_ALERT', enabled: false),
            NotificationPreference(type: 'PREDICTION_READY', enabled: false),
            NotificationPreference(type: 'CHALLENGE_REMINDER', enabled: false),
            NotificationPreference(type: 'DAILY_REMINDER', enabled: false),
          ];
          return _PrefsBody(prefs: demoPrefs, ref: ref, l10n: l10n, readonly: true);
        },
        data: (prefs) =>
            _PrefsBody(prefs: prefs, ref: ref, l10n: l10n, readonly: false),
      ),
    );
  }
}

class _PrefsBody extends StatelessWidget {
  const _PrefsBody({
    required this.prefs,
    required this.ref,
    required this.l10n,
    required this.readonly,
  });

  final List<NotificationPreference> prefs;
  final WidgetRef ref;
  final dynamic l10n;
  final bool readonly;

  @override
  Widget build(BuildContext context) {
    final masterEnabled = prefs.any((p) => p.enabled);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Master toggle card
        Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          child: SwitchListTile(
            title: Text(
              l10n.notificationsMasterTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              l10n.notificationsMasterSubtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6B7280),
              ),
            ),
            value: masterEnabled,
            activeTrackColor: const Color(0xFF34D399),
            onChanged: readonly
                ? null
                : (enabled) async {
                    for (final pref in prefs) {
                      await ref
                          .read(notificationsServiceProvider)
                          .updatePreference(pref.type, enabled: enabled);
                    }
                    ref.invalidate(_preferencesProvider);
                  },
          ),
        ),
        const SizedBox(height: 20),
        // Categories section label
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            l10n.notificationsCategoriesLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9CA3AF),
              letterSpacing: 0.5,
            ),
          ),
        ),
        // Individual preference tiles
        ...prefs.map((pref) => _PreferenceTile(
              pref: pref,
              onToggle: readonly
                  ? (_) async {}
                  : (enabled) async {
                      await ref
                          .read(notificationsServiceProvider)
                          .updatePreference(pref.type, enabled: enabled);
                      ref.invalidate(_preferencesProvider);
                    },
            )),
      ],
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

  String _subtitleForType(BuildContext context, String type) {
    final l10n = context.l10n;
    switch (type) {
      case 'BUDGET_ALERT':
        return l10n.notificationSubtypeBudgetAlert;
      case 'ANOMALY_ALERT':
        return l10n.notificationSubtypeAnomalyAlert;
      case 'PREDICTION_READY':
        return l10n.notificationSubtypePredictionReady;
      case 'CHALLENGE_REMINDER':
        return l10n.notificationSubtypeChallengeReminder;
      case 'DAILY_REMINDER':
        return l10n.notificationSubtypeDailyReminder;
      case 'BADGE_EARNED':
        return l10n.notificationSubtypeBadgeEarned;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(
        _iconForType(pref.type),
        color: const Color(0xFF9CA3AF),
        size: 22,
      ),
      title: Text(
        _labelForType(context, pref.type),
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        _subtitleForType(context, pref.type),
        style: const TextStyle(
          fontSize: 12,
          color: Color(0xFF6B7280),
        ),
      ),
      value: pref.enabled,
      activeTrackColor: const Color(0xFF34D399),
      onChanged: (v) => onToggle(v),
    );
  }
}
