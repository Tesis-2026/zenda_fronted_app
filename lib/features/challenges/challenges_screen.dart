import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/challenges_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _challengesServiceProvider = Provider<ChallengesApiService>(
  (_) => ChallengesApiService(),
);

final _challengesProvider =
    FutureProvider.autoDispose<List<Challenge>>((ref) {
  return ref.read(_challengesServiceProvider).getAll();
});

const _statusOrder = ['ACTIVE', 'AVAILABLE', 'COMPLETED', 'EXPIRED'];

class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final challengesAsync = ref.watch(_challengesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.challengesTitle)),
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
                        .read(_challengesServiceProvider)
                        .accept(challenge.id);
                    ref.invalidate(_challengesProvider);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(l10n.challengesAccepted)),
                      );
                    }
                  },
                  onComplete: () async {
                    await ref
                        .read(_challengesServiceProvider)
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

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return const Color(0xFF43A047);
      case 'ACTIVE':
        return const Color(0xFF1E88E5);
      default:
        return const Color(0xFF757575);
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'COMPLETED':
        return Icons.check_circle;
      case 'ACTIVE':
        return Icons.flag;
      default:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _statusColor(challenge.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_statusIcon(challenge.status), color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Chip(
                  avatar: const Icon(Icons.star, size: 14),
                  label: Text('${challenge.pointsReward}'),
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (challenge.status == 'AVAILABLE') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton(
                  onPressed: onAccept,
                  child: Text(l10n.challengesAcceptButton),
                ),
              ),
            ],
            if (challenge.status == 'ACTIVE') ...[
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
