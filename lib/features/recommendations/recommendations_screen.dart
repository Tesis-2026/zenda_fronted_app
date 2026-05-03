import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/recommendations_api_service.dart';
import '../../l10n/l10n_extension.dart';
import '../feedback/feedback_modal.dart';

final _recsServiceProvider = Provider<RecommendationsApiService>(
  (_) => RecommendationsApiService(),
);

final _recsProvider =
    FutureProvider.autoDispose<List<Recommendation>>((ref) {
  return ref.read(_recsServiceProvider).getAll();
});

class RecommendationsScreen extends ConsumerWidget {
  const RecommendationsScreen({super.key});

  VoidCallback? _actionRouteFor(BuildContext context, String type) {
    switch (type.toUpperCase()) {
      case 'BUDGET':
        return () => context.push('/budgets');
      case 'GOAL':
        return () => context.push('/goals');
      case 'SAVING':
        return () => context.push('/reports');
      case 'SPENDING':
        return () => context.push('/transactions');
      default:
        return null;
    }
  }

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
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  itemCount: recs.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Subtitle row
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                l10n.recommendationsSubtitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                        color: const Color(0xFF6B7280)),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => FeedbackModal.show(context,
                                  screenName: 'recommendations'),
                              child: Text(
                                l10n.recommendationsRateExperience,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final recIndex = index - 1;
                    return _RecommendationCard(
                      rec: recs[recIndex],
                      onFeedback: (accepted) async {
                        await ref
                            .read(_recsServiceProvider)
                            .submitFeedback(recs[recIndex].id, accepted: accepted);
                        ref.invalidate(_recsProvider);
                      },
                      onAction: _actionRouteFor(context, recs[recIndex].type),
                    );
                  },
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
    required this.onAction,
  });

  final Recommendation rec;
  final Future<void> Function(bool accepted) onFeedback;
  final VoidCallback? onAction;

  // Design shows colored category chip labels
  String _labelForType(String type) {
    switch (type.toUpperCase()) {
      case 'SAVING':
        return 'SAVINGS';
      case 'BUDGET':
        return 'BUDGET';
      case 'GOAL':
        return 'GOAL';
      case 'SPENDING':
        return 'SPENDING';
      default:
        return type.toUpperCase();
    }
  }

  Color _colorForType(String type) {
    switch (type.toUpperCase()) {
      case 'SAVING':
        return const Color(0xFF10B981);
      case 'BUDGET':
        return const Color(0xFFF59E0B);
      case 'GOAL':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _iconForType(String type) {
    switch (type.toUpperCase()) {
      case 'SPENDING':
        return Icons.shopping_cart_outlined;
      case 'SAVING':
        return Icons.savings_outlined;
      case 'INCOME':
        return Icons.trending_up;
      case 'BUDGET':
        return Icons.bar_chart_rounded;
      case 'GOAL':
        return Icons.flag_outlined;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typeColor = _colorForType(rec.type);
    final actionLink = rec.actionLabel;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category chip + icon row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _labelForType(rec.type),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(_iconForType(rec.type),
                    size: 20, color: const Color(0xFF9CA3AF)),
              ],
            ),
            const SizedBox(height: 10),
            // Body text
            Text(
              rec.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF1F2937),
                    height: 1.5,
                  ),
            ),
            // Action link (green arrow text)
            if (actionLink != null && actionLink.isNotEmpty && onAction != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  '→ $actionLink',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            // Feedback buttons: outlined style matching design
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.thumb_up_outlined, size: 16),
                    label: Text(l10n.recommendationsAccept),
                    onPressed: () => onFeedback(true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      textStyle: const TextStyle(fontSize: 13),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.thumb_down_outlined, size: 16),
                    label: Text(l10n.recommendationsReject),
                    onPressed: () => onFeedback(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B7280),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      textStyle: const TextStyle(fontSize: 13),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
