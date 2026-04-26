import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/recommendations_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _recsServiceProvider = Provider<RecommendationsApiService>(
  (_) => RecommendationsApiService(),
);

final _recsProvider =
    FutureProvider.autoDispose<List<Recommendation>>((ref) {
  return ref.read(_recsServiceProvider).getAll();
});

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final recsAsync = ref.watch(_recsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recommendationsTitle)),
      body: recsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.recommendationsErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_recsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (recs) => recs.isEmpty
            ? Center(child: Text(l10n.recommendationsEmpty))
            : RefreshIndicator(
                onRefresh: () async => ref.invalidate(_recsProvider),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recs.length,
                  itemBuilder: (context, index) => _RecommendationCard(
                    rec: recs[index],
                    onFeedback: (accepted) async {
                      await ref
                          .read(_recsServiceProvider)
                          .submitFeedback(recs[index].id, accepted: accepted);
                      ref.invalidate(_recsProvider);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.rec,
    required this.onFeedback,
  });

  final Recommendation rec;
  final Future<void> Function(bool accepted) onFeedback;

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'SPENDING':
        return Icons.shopping_cart_outlined;
      case 'SAVING':
        return Icons.savings_outlined;
      case 'INCOME':
        return Icons.trending_up;
      case 'BUDGET':
        return Icons.pie_chart_outline;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colorScheme.primaryContainer,
                  child: Icon(
                    _iconForType(rec.type),
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (rec.impactScore != null)
                  _ImpactChip(score: rec.impactScore!),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              rec.body,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.thumb_down_outlined, size: 18),
                  label: Text(l10n.recommendationsReject),
                  onPressed: () => onFeedback(false),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  icon: const Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text(l10n.recommendationsAccept),
                  onPressed: () => onFeedback(true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactChip extends StatelessWidget {
  const _ImpactChip({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    final pct = (score * 100).toStringAsFixed(0);
    return Chip(
      label: Text('$pct%'),
      avatar: const Icon(Icons.bolt, size: 14),
      padding: EdgeInsets.zero,
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
    );
  }
}
