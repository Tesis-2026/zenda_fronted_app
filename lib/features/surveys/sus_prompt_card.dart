import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/services/study_analytics_service.dart';
import '../../core/services/study_telemetry_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';

final susPromptServiceProvider = Provider<SurveysApiService>(
  (_) => SurveysApiService(),
);

final susPromptStatusProvider = FutureProvider.autoDispose<SusPromptStatus>((
  ref,
) {
  return ref.read(susPromptServiceProvider).getSusStatus();
});

class SusPromptCard extends ConsumerStatefulWidget {
  const SusPromptCard({super.key});

  @override
  ConsumerState<SusPromptCard> createState() => _SusPromptCardState();
}

class _SusPromptCardState extends ConsumerState<SusPromptCard> {
  bool _dismissedInSession = false;
  bool _loggedShown = false;

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(susPromptStatusProvider);

    return statusAsync.maybeWhen(
      data: (status) {
        final shouldShow = _shouldShow(status);
        if (!shouldShow) return const SizedBox.shrink();

        if (!_loggedShown) {
          _loggedShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            StudyTelemetryService.track(
              'sus_prompt_shown',
              metadata: {
                'reason': status.reason,
                'sessions': status.metrics.sessionsCount,
                'transactions': status.metrics.transactionsCount,
                'chat_messages': status.metrics.chatMessagesCount,
              },
            );
          });
        }

        return _PromptContent(
          status: status,
          onDismiss: () {
            setState(() => _dismissedInSession = true);
            StudyTelemetryService.track(
              'sus_prompt_dismissed',
              metadata: {'reason': status.reason, 'screen': 'dashboard'},
            );
          },
          onStart: () {
            StudyTelemetryService.track(
              'sus_prompt_accepted',
              metadata: {'reason': status.reason, 'screen': 'dashboard'},
            );
            context.push('/surveys/sus');
          },
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  bool _shouldShow(SusPromptStatus status) {
    if (_dismissedInSession || status.completed) return false;
    if (!StudyAnalyticsService.studyEnabled ||
        !StudyAnalyticsService.susPromptEnabled) {
      return false;
    }
    if (StudyAnalyticsService.susForcePrompt) return true;

    final meetsRemoteUsage =
        status.metrics.sessionsCount >= StudyAnalyticsService.susMinSessions ||
        status.metrics.transactionsCount >=
            StudyAnalyticsService.susMinTransactions ||
        status.metrics.chatMessagesCount >=
            StudyAnalyticsService.susMinChatMessages;

    return status.shouldPrompt && meetsRemoteUsage;
  }
}

class _PromptContent extends StatelessWidget {
  const _PromptContent({
    required this.status,
    required this.onDismiss,
    required this.onStart,
  });

  final SusPromptStatus status;
  final VoidCallback onDismiss;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final metrics = status.metrics;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_turned_in_outlined,
                  color: Color(0xFF2563EB),
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ayudanos a mejorar Zenda',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Responde el cuestionario SUS. Toma 1 minuto y nos ayuda a validar la tesis con datos reales de uso.',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.login_rounded,
                label: '${metrics.sessionsCount} sesiones',
              ),
              _MetricChip(
                icon: Icons.receipt_long_rounded,
                label: '${metrics.transactionsCount} registros',
              ),
              if (metrics.chatMessagesCount > 0)
                _MetricChip(
                  icon: Icons.psychology_rounded,
                  label: '${metrics.chatMessagesCount} chats',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              TextButton(
                onPressed: onDismiss,
                style: TextButton.styleFrom(
                  foregroundColor: colors.textMuted,
                  minimumSize: const Size(72, 44),
                ),
                child: const Text('Luego'),
              ),
              const Spacer(),
              FilledButton(
                onPressed: onStart,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(132, 44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Responder SUS'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF2563EB)),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF1F2937),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
