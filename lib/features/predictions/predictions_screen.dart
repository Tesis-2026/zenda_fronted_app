import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/predictions_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _predictionsServiceProvider = Provider<PredictionsApiService>(
  (_) => PredictionsApiService(),
);

final _expensePredictionProvider =
    FutureProvider.autoDispose<PredictionResult>((ref) {
  return ref.read(_predictionsServiceProvider).getExpensePrediction();
});

class PredictionsScreen extends ConsumerWidget {
  const PredictionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final expenseAsync = ref.watch(_expensePredictionProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.predictionsTitle)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(_expensePredictionProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            expenseAsync.when(
              loading: () => const _PredictionCardSkeleton(),
              error: (e, _) => _ErrorCard(
                message: l10n.predictionsErrorLoad,
                onRetry: () => ref.invalidate(_expensePredictionProvider),
              ),
              data: (p) => p.confidenceLevel >= 0.60
                  ? _ExpenseForecastCard(result: p)
                  : _LowConfidenceCard(message: l10n.predictionsLowConfidence),
            ),
            const SizedBox(height: 24),
            _DisclaimerCard(text: l10n.predictionsDisclaimer),
          ],
        ),
      ),
    );
  }
}

class _ExpenseForecastCard extends StatelessWidget {
  const _ExpenseForecastCard({required this.result});
  final PredictionResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final confidencePct = (result.confidenceLevel * 100).toStringAsFixed(0);
    const red = Color(0xFFEF4444);

    return Column(
      children: [
        // Projected amount card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.predictionsExpenseTitle,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34D399).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$confidencePct% ${l10n.predictionsConfidence}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'S/ ${result.predictedAmount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.period,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: result.confidenceLevel,
                    minHeight: 8,
                    backgroundColor: red.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(red),
                  ),
                ),
              ],
            ),
          ),
        ),
        // AI narrative card
        if (result.narrative != null && result.narrative!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.psychology_rounded,
                    color: Color(0xFF10B981), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Zenda AI',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF10B981),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        result.narrative!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color(0xFF065F46),
                              height: 1.5,
                            ),
                      ),
                    ],
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

class _LowConfidenceCard extends StatelessWidget {
  const _LowConfidenceCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.hourglass_empty_rounded,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionCardSkeleton extends StatelessWidget {
  const _PredictionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(message),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onRetry,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  const _DisclaimerCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
