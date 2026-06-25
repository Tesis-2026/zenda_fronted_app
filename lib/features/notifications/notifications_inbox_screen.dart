import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/models/notification.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/zenda_app_bar.dart';
import 'notifications_inbox_providers.dart';

class NotificationsInboxScreen extends ConsumerWidget {
  const NotificationsInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inboxAsync = ref.watch(notificationsInboxProvider);
    final notifier = ref.read(notificationsInboxProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: ZendaAppBar(
        title: 'Notificaciones',
        actions: [
          IconButton(
            tooltip: 'Marcar todas como leídas',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () => notifier.markAllRead(),
          ),
        ],
      ),
      body: inboxAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(error: e, onRetry: notifier.refresh),
        data: (page) => page.items.isEmpty
            ? const _EmptyState()
            : RefreshIndicator(
                onRefresh: notifier.refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: page.items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final n = page.items[i];
                    return _NotificationCard(
                      notification: n,
                      onTap: () {
                        if (!n.isRead) notifier.markRead(n.id);
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification, required this.onTap});

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const cardColor = Colors.white;
    final iconColor = _accentForType(notification.type);
    const textColor = AppColors.textDark;
    const subColor = Color(0xFF6B7280);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(
              color: notification.isRead
                  ? AppColors.border
                  : iconColor.withAlpha(80),
              width: notification.isRead ? 1 : 1.5,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  size: 20,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: notification.isRead
                                  ? FontWeight.w600
                                  : FontWeight.w700,
                              color: textColor,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 6, top: 4),
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: 13,
                        color: subColor,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatRelative(notification.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: subColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    const subColor = Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: subColor),
            const SizedBox(height: 12),
            Text(
              'No tienes notificaciones',
              style: TextStyle(
                fontSize: 15,
                color: subColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Te avisaremos sobre tus presupuestos, retos y logros.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: subColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 40, color: Color(0xFFEF4444)),
            const SizedBox(height: 12),
            Text(
              'No pudimos cargar las notificaciones',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
          ],
        ),
      ),
    );
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'TRANSACTION_RECORDED':
      return Icons.receipt_long_outlined;
    case 'BUDGET_ALERT':
      return Icons.pie_chart_outline;
    case 'ANOMALY_ALERT':
      return Icons.warning_amber_outlined;
    case 'PREDICTION_READY':
      return Icons.analytics_outlined;
    case 'CHALLENGE_REMINDER':
      return Icons.flag_outlined;
    case 'DAILY_REMINDER':
      return Icons.notifications_active_outlined;
    case 'BADGE_EARNED':
      return Icons.military_tech_outlined;
    default:
      return Icons.notifications_outlined;
  }
}

Color _accentForType(String type) {
  switch (type) {
    case 'TRANSACTION_RECORDED':
      return const Color(0xFF10B981);
    case 'BUDGET_ALERT':
      return const Color(0xFFF59E0B);
    case 'ANOMALY_ALERT':
      return const Color(0xFFEF4444);
    case 'PREDICTION_READY':
      return const Color(0xFF6366F1);
    case 'CHALLENGE_REMINDER':
      return const Color(0xFF8B5CF6);
    case 'DAILY_REMINDER':
      return const Color(0xFF0EA5E9);
    case 'BADGE_EARNED':
      return const Color(0xFF10B981);
    default:
      return const Color(0xFF6B7280);
  }
}

String _formatRelative(DateTime when) {
  final now = DateTime.now();
  final diff = now.difference(when);
  if (diff.inMinutes < 1) return 'Justo ahora';
  if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
  if (diff.inDays < 7) return 'Hace ${diff.inDays} d';
  return DateFormat('d MMM', 'es').format(when);
}
