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
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_challengesProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: challenges.length,
              itemBuilder: (context, index) => _ChallengeCard(
                challenge: challenges[index],
                onAccept: () async {
                  await ref
                      .read(_challengesServiceProvider)
                      .accept(challenges[index].id);
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
                      .complete(challenges[index].id);
                  ref.invalidate(_challengesProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.challengesCompleted)),
                    );
                  }
                },
              ),
            ),
          );
        },
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
