import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/quiz_models.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';
import 'personalized_quiz_controller.dart';

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

final _personalizedQuizProvider = FutureProvider.autoDispose<PersonalizedQuizResult>((ref) {
  return ref.read(educationServiceProvider).getPersonalizedQuiz();
});

// ─────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────

class PersonalizedQuizScreen extends ConsumerWidget {
  const PersonalizedQuizScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quizAsync = ref.watch(_personalizedQuizProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(title: l10n.quizPersonalizedTitle),
      body: quizAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                l10n.quizPersonalizedAnalyzing,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        error: (e, _) {
          final isLimit = e.toString().contains('429') || e.toString().contains('TOO_MANY');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLimit ? Icons.hourglass_empty : Icons.error_outline,
                    size: 56,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isLimit ? l10n.quizPersonalizedLimitReached : l10n.quizPersonalizedError,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(context.l10n.commonCancel),
                  ),
                ],
              ),
            ),
          );
        },
        data: (result) {
          if (result.questions.isEmpty) {
            return Center(child: Text(l10n.quizPersonalizedError));
          }
          return _PersonalizedQuizBody(result: result);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Quiz body
// ─────────────────────────────────────────────────────────────────

class _PersonalizedQuizBody extends ConsumerWidget {
  const _PersonalizedQuizBody({required this.result});

  final PersonalizedQuizResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final state = ref.watch(personalizedQuizControllerProvider);
    final controller = ref.read(personalizedQuizControllerProvider.notifier);

    if (state.phase == PersonalizedQuizPhase.results) {
      if (state.submitting || state.submitResult == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final score = state.submitResult!['score'] as int? ?? 0;
      final correct = state.submitResult!['correctCount'] as int? ?? 0;
      final total =
          state.submitResult!['totalCount'] as int? ?? result.questions.length;
      final scoreColor = score >= 80
          ? Colors.green
          : score >= 50
              ? const Color(0xFFFB8C00)
              : Colors.red;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 24),
            if (result.attemptsRemainingToday > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.quizPersonalizedAttemptsLeft(result.attemptsRemainingToday),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF818CF8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scoreColor.withValues(alpha: 0.12),
                border: Border.all(color: scoreColor, width: 3),
              ),
              child: Center(
                child: Text(
                  '$score%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.quizResult(score),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '$correct / $total correct',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.commonDone),
              ),
            ),
          ],
        ),
      );
    }

    final q = result.questions[state.index];
    final isLast = state.index >= result.questions.length - 1;
    final reviewing = state.phase == PersonalizedQuizPhase.reviewing;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${state.index + 1} / ${result.questions.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  if (result.attemptsRemainingToday > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.l10n.quizPersonalizedAttemptsLeft(result.attemptsRemainingToday),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF818CF8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              AppProgressBar(
                value: (state.index + 1) / result.questions.length,
                color: const Color(0xFF34D399),
                height: 4,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _DifficultyChip(difficulty: q.difficulty),
                const SizedBox(height: 16),
                Text(
                  q.text,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                ...q.options.asMap().entries.map(
                  (entry) => _OptionTile(
                    option: entry.value,
                    index: entry.key,
                    isSelected: state.selected == entry.value,
                    isReviewing: reviewing,
                    onTap: reviewing ? null : () => controller.selectOption(entry.value),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: reviewing
                      ? FilledButton(
                          onPressed: () async {
                            final failed =
                                await controller.next(isLast: isLast);
                            if (failed && context.mounted) {
                              showAppToast(
                                context,
                                context.l10n.quizPersonalizedError,
                                type: ToastType.error,
                              );
                            }
                          },
                          child: Text(isLast ? l10n.quizFinish : l10n.quizNext),
                        )
                      : FilledButton(
                          onPressed: state.selected != null
                              ? () => controller.confirmAnswer(q.id)
                              : null,
                          child: Text(l10n.quizSubmit),
                        ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DifficultyChip extends StatelessWidget {
  final String difficulty;
  const _DifficultyChip({required this.difficulty});

  Color get _color {
    switch (difficulty.toUpperCase()) {
      case 'BEGINNER':
        return const Color(0xFF43A047);
      case 'INTERMEDIATE':
        return const Color(0xFFFB8C00);
      case 'ADVANCED':
        return const Color(0xFFE53935);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: _color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          difficulty,
          style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w600),
        ),
      );
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.option,
    required this.index,
    required this.isSelected,
    required this.isReviewing,
    required this.onTap,
  });

  final String option;
  final int index;
  final bool isSelected;
  final bool isReviewing;
  final VoidCallback? onTap;

  static const _labels = ['A', 'B', 'C', 'D', 'E'];

  @override
  Widget build(BuildContext context) {
    final label = index < _labels.length ? _labels[index] : '${index + 1}';
    final Color bgColor =
        isSelected ? const Color(0xFFECFDF5) : Colors.white;
    final Color borderColor =
        isSelected ? const Color(0xFF34D399) : const Color(0xFFE5E7EB);
    final double borderWidth = isSelected ? 1.5 : 1.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
