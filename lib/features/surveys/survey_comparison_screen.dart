import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/surveys_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _comparisonProvider = FutureProvider.autoDispose<SurveyComparison>((ref) {
  return SurveysApiService().getComparison();
});

class SurveyComparisonScreen extends ConsumerWidget {
  const SurveyComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(_comparisonProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.surveyComparisonNavTitle)),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(l10n.surveyErrorLoad),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(_comparisonProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (data) => _ComparisonBody(data: data),
      ),
    );
  }
}

class _ComparisonBody extends StatelessWidget {
  const _ComparisonBody({required this.data});
  final SurveyComparison data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bothComplete = data.preScore != null && data.postScore != null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        _ScoreCard(
          label: l10n.surveyComparisonPreLabel,
          score: data.preScore,
          pendingLabel: l10n.surveyComparisonPrePending,
          color: const Color(0xFF1E88E5),
          icon: Icons.assignment_outlined,
        ),
        const SizedBox(height: 16),
        _ScoreCard(
          label: l10n.surveyComparisonPostLabel,
          score: data.postScore,
          pendingLabel: l10n.surveyComparisonPostPending,
          color: const Color(0xFF43A047),
          icon: Icons.assignment_turned_in_outlined,
        ),
        const SizedBox(height: 24),
        if (bothComplete) ...[
          _ImprovementCard(improvement: data.improvementPercentage),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.grey),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.surveyComparisonPending,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.label,
    required this.score,
    required this.pendingLabel,
    required this.color,
    required this.icon,
  });

  final String label;
  final double? score;
  final String pendingLabel;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                score != null
                    ? Text(
                        '${score!.toStringAsFixed(0)} / 100',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      )
                    : Text(
                        pendingLabel,
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ImprovementCard extends StatelessWidget {
  const _ImprovementCard({required this.improvement});
  final double? improvement;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pts = improvement ?? 0.0;
    final goalMet = pts >= 20;
    final positive = pts > 0;

    final color = goalMet
        ? const Color(0xFF43A047)
        : positive
            ? const Color(0xFFFB8C00)
            : const Color(0xFFE53935);

    final icon = goalMet
        ? Icons.emoji_events_outlined
        : positive
            ? Icons.trending_up
            : Icons.trending_down;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 12),
              Text(
                l10n.surveyComparisonImprovementLabel,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${pts >= 0 ? '+' : ''}${pts.toStringAsFixed(1)} pts',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          _GoalIndicator(goalMet: goalMet, color: color),
          const SizedBox(height: 8),
          Text(
            goalMet ? l10n.surveyComparisonGoalMet : l10n.surveyComparisonGoalNotMet,
            style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _GoalIndicator extends StatelessWidget {
  const _GoalIndicator({required this.goalMet, required this.color});
  final bool goalMet;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: goalMet ? 1.0 : 0.5,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              color: color,
              minHeight: 8,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          l10n.surveyComparisonGoalLabel,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
