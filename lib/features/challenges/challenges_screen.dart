import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/challenges_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../../l10n/l10n_extension.dart';

final challengesServiceProvider = Provider<ChallengesApiService>(
  (_) => ChallengesApiService(),
);

final _challengesProvider =
    FutureProvider.autoDispose<List<Challenge>>((ref) {
  return ref.read(challengesServiceProvider).getAll();
});

const _statusOrder = ['ACTIVE', 'AVAILABLE', 'COMPLETED', 'EXPIRED'];

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final challengesAsync = ref.watch(_challengesProvider);
    final streakDays = ref.watch(streakProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.challengesTitle),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFD97706)),
                  const SizedBox(width: 4),
                  Text(
                    l10n.streakLabel(streakDays),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: challengesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.challengesErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_challengesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (challenges) {
          if (challenges.isEmpty) {
            return Center(child: Text(l10n.challengesEmpty));
          }

          final grouped = <String, List<Challenge>>{};
          for (final c in challenges) {
            grouped.putIfAbsent(c.status, () => []).add(c);
          }

          final sections = _statusOrder
              .where((s) => grouped.containsKey(s))
              .toList();

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_challengesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _itemCount(sections, grouped),
              itemBuilder: (context, index) {
                final (section, itemIndex) =
                    _resolveIndex(index, sections, grouped);
                if (itemIndex < 0) {
                  return _SectionHeader(
                    label: _sectionLabel(l10n, section),
                  );
                }
                final challenge = grouped[section]![itemIndex];
                return _ChallengeCard(
                  challenge: challenge,
                  onAccept: () async {
                    await ref
                        .read(challengesServiceProvider)
                        .accept(challenge.id);
                    ref.invalidate(_challengesProvider);
                    if (context.mounted) {
                      showAppToast(
                        context,
                        l10n.challengesAccepted,
                        type: ToastType.success,
                      );
                    }
                  },
                  onComplete: () async {
                    await ref
                        .read(challengesServiceProvider)
                        .complete(challenge.id);
                    ref.invalidate(_challengesProvider);
                    if (context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => _ChallengeCelebrationDialog(
                          title: challenge.title,
                        ),
                      );
                    }
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  int _itemCount(
      List<String> sections, Map<String, List<Challenge>> grouped) {
    return sections.fold(
        0, (sum, s) => sum + 1 + (grouped[s]?.length ?? 0));
  }

  (String, int) _resolveIndex(
      int index, List<String> sections, Map<String, List<Challenge>> grouped) {
    int cursor = 0;
    for (final section in sections) {
      if (index == cursor) return (section, -1);
      cursor++;
      final count = grouped[section]?.length ?? 0;
      if (index < cursor + count) return (section, index - cursor);
      cursor += count;
    }
    return (sections.last, 0);
  }

  String _sectionLabel(dynamic l10n, String status) {
    switch (status) {
      case 'ACTIVE':
        return l10n.challengesSectionActive;
      case 'AVAILABLE':
        return l10n.challengesSectionAvailable;
      case 'COMPLETED':
        return l10n.challengesSectionCompleted;
      case 'EXPIRED':
        return l10n.challengesSectionExpired;
      default:
        return status;
    }
  }
}

class _ChallengeCelebrationDialog extends StatefulWidget {
  final String title;
  const _ChallengeCelebrationDialog({required this.title});

  @override
  State<_ChallengeCelebrationDialog> createState() =>
      _ChallengeCelebrationDialogState();
}

class _ChallengeCelebrationDialogState
    extends State<_ChallengeCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      icon: ScaleTransition(
        scale: _scale,
        child: const Icon(
          Icons.military_tech_rounded,
          color: Color(0xFFF59E0B),
          size: 56,
        ),
      ),
      title: Text(l10n.challengesCompleted, textAlign: TextAlign.center),
      content: Text(widget.title, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(context),
          style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF10B981)),
          child: Text(l10n.commonOk),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.challenge,
    required this.onAccept,
    required this.onComplete,
  });
  final Challenge challenge;
  final Future<void> Function() onAccept;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isCompleted = challenge.status == 'COMPLETED';
    final isActive = challenge.status == 'ACTIVE';

    // Progress values: use challenge fields if available, fall back to 0/1.
    final int current = challenge.progressCurrent ?? 0;
    final int total = challenge.progressTotal ?? 1;
    final double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
    final String? daysLeft = challenge.daysLeft;
    final String? badgeReward = challenge.badgeReward;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row: icon + title + progress count or status chip
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category icon circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : Icons.emoji_events_outlined,
                    size: 20,
                    color: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        challenge.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF6B7280),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isActive && total > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$current/$total',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  )
                else if (isCompleted)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 16),
                  ),
              ],
            ),
            // Progress bar (active challenges only)
            if (isActive && total > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                ),
              ),
            ],
            // Reward row
            if (badgeReward != null || daysLeft != null) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (badgeReward != null) ...[
                    const Icon(Icons.military_tech_rounded,
                        size: 14, color: Color(0xFF6B7280)),
                    const SizedBox(width: 4),
                    Text(
                      l10n.challengeRewardBadge(badgeReward),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (daysLeft != null && !isCompleted)
                    Text(
                      l10n.challengeDaysLeft(daysLeft),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF59E0B),
                      ),
                    ),
                ],
              ),
            ],
            // Action buttons
            if (challenge.status == 'AVAILABLE') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onAccept,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF34D399),
                  ),
                  child: Text(l10n.challengesAcceptButton),
                ),
              ),
            ],
            if (isActive) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(l10n.challengesCompleteButton),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
