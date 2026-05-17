import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/quiz_models.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';

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
                    onPressed: () => context.pop(),
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

class _PersonalizedQuizBody extends ConsumerStatefulWidget {
  const _PersonalizedQuizBody({required this.result});

  final PersonalizedQuizResult result;

  @override
  ConsumerState<_PersonalizedQuizBody> createState() =>
      _PersonalizedQuizBodyState();
}

class _PersonalizedQuizBodyState extends ConsumerState<_PersonalizedQuizBody> {
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
      final res = await ref
          .read(educationServiceProvider)
          .submitPersonalizedQuiz(_answers);
      setState(() {
        _submitResult = res;
        _submitting = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _phase = _Phase.reviewing;
        });
        showAppToast(context, context.l10n.quizPersonalizedError,
            type: ToastType.error);
      }
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
                onPressed: () => context.pop(),
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
              AppProgressBar(
                value: (_index + 1) / widget.result.questions.length,
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
                    isSelected: _selected == entry.value,
                    isReviewing: reviewing,
                    onTap: reviewing ? null : () => _selectOption(entry.value),
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
