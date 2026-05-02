import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/quiz_models.dart';
import '../../core/services/education_api_service.dart';
import '../../l10n/l10n_extension.dart';

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

final _personalizedQuizProvider = FutureProvider.autoDispose<PersonalizedQuizResult>((ref) {
  return EducationApiService().getPersonalizedQuiz();
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
      appBar: AppBar(title: Text(l10n.quizPersonalizedTitle)),
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

enum _Phase { answering, reviewing, results }

class _PersonalizedQuizBody extends StatefulWidget {
  const _PersonalizedQuizBody({required this.result});

  final PersonalizedQuizResult result;

  @override
  State<_PersonalizedQuizBody> createState() => _PersonalizedQuizBodyState();
}

class _PersonalizedQuizBodyState extends State<_PersonalizedQuizBody> {
  int _index = 0;
  String? _selected;
  final Map<String, String> _answers = {};
  _Phase _phase = _Phase.answering;
  bool _submitting = false;
  Map<String, dynamic>? _submitResult;

  PersonalizedQuizQuestion get _current => widget.result.questions[_index];
  bool get _isLast => _index >= widget.result.questions.length - 1;

  void _selectOption(String option) {
    if (_phase != _Phase.answering) return;
    setState(() => _selected = option);
  }

  void _confirmAnswer() {
    final sel = _selected;
    if (sel == null) return;
    _answers[_current.id] = sel;
    setState(() => _phase = _Phase.reviewing);
  }

  Future<void> _next() async {
    if (_isLast) {
      await _submit();
    } else {
      setState(() {
        _index++;
        _selected = null;
        _phase = _Phase.answering;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _submitting = true;
      _phase = _Phase.results;
    });
    try {
      final res = await EducationApiService().submitPersonalizedQuiz(_answers);
      setState(() {
        _submitResult = res;
        _submitting = false;
      });
    } catch (_) {
      setState(() {
        _submitting = false;
        _phase = _Phase.reviewing;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (_phase == _Phase.results) {
      if (_submitting || _submitResult == null) {
        return const Center(child: CircularProgressIndicator());
      }
      final score = _submitResult!['score'] as int? ?? 0;
      final correct = _submitResult!['correctCount'] as int? ?? 0;
      final total = _submitResult!['totalCount'] as int? ?? widget.result.questions.length;
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
            if (widget.result.attemptsRemainingToday > 0)
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.quizPersonalizedAttemptsLeft(widget.result.attemptsRemainingToday),
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

    final q = _current;
    final reviewing = _phase == _Phase.reviewing;

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
                    '${_index + 1} / ${widget.result.questions.length}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const Spacer(),
                  if (widget.result.attemptsRemainingToday > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF818CF8).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        context.l10n.quizPersonalizedAttemptsLeft(widget.result.attemptsRemainingToday),
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
              LinearProgressIndicator(
                value: (_index + 1) / widget.result.questions.length,
                borderRadius: BorderRadius.circular(4),
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
                ...q.options.map(
                  (option) => _OptionTile(
                    option: option,
                    isSelected: _selected == option,
                    isReviewing: reviewing,
                    onTap: reviewing ? null : () => _selectOption(option),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: reviewing
                      ? FilledButton(
                          onPressed: _next,
                          child: Text(_isLast ? l10n.quizFinish : l10n.quizNext),
                        )
                      : FilledButton(
                          onPressed: _selected != null ? _confirmAnswer : null,
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
  final String option;
  final bool isSelected;
  final bool isReviewing;
  final VoidCallback? onTap;

  const _OptionTile({
    required this.option,
    required this.isSelected,
    required this.isReviewing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color? tileColor;
    Color? borderColor;

    if (isSelected && !isReviewing) {
      tileColor = colorScheme.primaryContainer;
      borderColor = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: tileColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: borderColor ?? colorScheme.outline.withValues(alpha: 0.4),
              width: borderColor != null ? 1.5 : 1,
            ),
          ),
          child: Text(
            option,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
          ),
        ),
      ),
    );
  }
}
