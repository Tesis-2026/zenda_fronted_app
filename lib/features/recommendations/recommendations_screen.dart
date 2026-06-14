import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/recommendations_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';
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
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(title: l10n.recommendationsTitle),
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
                      // Persist only — the card reflects the verdict optimistically
                      // via local state, so we don't refetch (which would flicker
                      // the list and, in demo, drop the optimistic mark).
                      onFeedback: (accepted) => ref
                          .read(_recsServiceProvider)
                          .submitFeedback(recs[recIndex].id, accepted: accepted),
                      onAction: _actionRouteFor(context, recs[recIndex].type),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

class _RecommendationCard extends StatefulWidget {
  const _RecommendationCard({
    required this.rec,
    required this.onFeedback,
    required this.onAction,
  });

  final Recommendation rec;
  final Future<void> Function(bool accepted) onFeedback;
  final VoidCallback? onAction;

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  /// Optimistic verdict: null = no feedback, true = helpful, false = not relevant.
  /// Seeded from the server value so a previously rated rec shows its mark.
  bool? _verdict;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _verdict = widget.rec.feedbackAccepted;
  }

  Future<void> _handleFeedback(bool accepted) async {
    // Feedback is final: once a verdict exists it can't be changed.
    if (_submitting || _verdict != null) return;
    final previous = _verdict;
    setState(() {
      _verdict = accepted;
      _submitting = true;
    });
    try {
      await widget.onFeedback(accepted);
    } catch (_) {
      if (!mounted) return;
      setState(() => _verdict = previous); // revert on failure
      showAppToast(context, context.l10n.commonUnknownError,
          type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // Design shows colored category chip labels
  String _labelForType(String type) {
    switch (type.toUpperCase()) {
      case 'SAVING':
        return 'AHORRO';
      case 'BUDGET':
        return 'PRESUPUESTO';
      case 'GOAL':
        return 'META';
      case 'SPENDING':
        return 'GASTO';
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
    final rec = widget.rec;
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
            if (actionLink != null &&
                actionLink.isNotEmpty &&
                widget.onAction != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: widget.onAction,
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
            // Feedback buttons — the chosen verdict is filled with its color,
            // the other stays outlined and dimmed. Feedback is final, so once a
            // verdict exists the whole row is locked (no editing).
            IgnorePointer(
              ignoring: _verdict != null,
              child: Row(
                children: [
                  Expanded(child: _feedbackButton(isLike: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _feedbackButton(isLike: false)),
                ],
              ),
            ),
            if (_verdict != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.check_circle_rounded,
                      size: 14, color: Color(0xFF10B981)),
                  const SizedBox(width: 6),
                  Text(
                    l10n.recommendationsFeedbackThanks,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feedbackButton({required bool isLike}) {
    final l10n = context.l10n;
    final selected = _verdict == isLike;
    final color =
        isLike ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final label =
        isLike ? l10n.recommendationsAccept : l10n.recommendationsReject;
    final icon = isLike
        ? (selected ? Icons.thumb_up_rounded : Icons.thumb_up_outlined)
        : (selected ? Icons.thumb_down_rounded : Icons.thumb_down_outlined);
    final onPressed = _submitting ? null : () => _handleFeedback(isLike);

    if (selected) {
      return FilledButton.icon(
        icon: Icon(icon, size: 16),
        label: Text(label),
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 13),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
      );
    }

    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        // Dim the unchosen option once a verdict exists.
        foregroundColor: _verdict == null
            ? const Color(0xFF6B7280)
            : const Color(0xFF9CA3AF),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        textStyle: const TextStyle(fontSize: 13),
        padding: const EdgeInsets.symmetric(vertical: 10),
      ),
    );
  }
}
