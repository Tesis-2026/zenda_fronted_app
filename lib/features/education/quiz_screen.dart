import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/quiz_models.dart';
import '../../core/services/quiz_api_service.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';

// ─────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────

final _quizProvider = FutureProvider.autoDispose
    .family<List<QuizQuestion>, ({String topicId, String language})>(
  (ref, args) =>
      ref.read(quizServiceProvider).getQuiz(args.topicId, args.language),
);

// ─────────────────────────────────────────────────────────────────
// Screen state machine
// ─────────────────────────────────────────────────────────────────

enum _QuizPhase { answering, reviewing, results }

class _QuizState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final String? selectedOption;
  final _QuizPhase phase;
  final QuizResult? result;
  final bool submitting;

  const _QuizState({
    required this.questions,
    this.currentIndex = 0,
    this.answers = const {},
    this.selectedOption,
    this.phase = _QuizPhase.answering,
    this.result,
    this.submitting = false,
  });

  QuizQuestion get current => questions[currentIndex];
  bool get isLast => currentIndex >= questions.length - 1;

  _QuizState copyWith({
    int? currentIndex,
    Map<String, String>? answers,
    String? selectedOption,
    _QuizPhase? phase,
    QuizResult? result,
    bool? submitting,
    bool clearSelection = false,
  }) {
    return _QuizState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedOption:
          clearSelection ? null : (selectedOption ?? this.selectedOption),
      phase: phase ?? this.phase,
      result: result ?? this.result,
      submitting: submitting ?? this.submitting,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// QuizScreen
// ─────────────────────────────────────────────────────────────────

class QuizScreen extends ConsumerWidget {
  const QuizScreen({super.key, required this.topicId, this.topicTitle});

  final String topicId;
  final String? topicTitle;

  String _deviceLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'es' ? 'es' : 'en';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = _deviceLanguage(context);
    final quizAsync =
        ref.watch(_quizProvider((topicId: topicId, language: language)));

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: ZendaAppBar(
        title: topicTitle != null
            ? '${l10n.quizTitle}: $topicTitle'
            : l10n.quizTitle,
      ),
      body: quizAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(l10n.quizEmpty, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.commonCancel),
                ),
              ],
            ),
          ),
        ),
        data: (questions) => _QuizBody(
          topicId: topicId,
          questions: questions,
          service: ref.read(quizServiceProvider),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Quiz body (stateful — manages state machine)
// ─────────────────────────────────────────────────────────────────

class _QuizBody extends StatefulWidget {
  const _QuizBody({
    required this.topicId,
    required this.questions,
    required this.service,
  });

  final String topicId;
  final List<QuizQuestion> questions;
  final QuizApiService service;

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  late _QuizState _state;
  int _timerSeconds = 120;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _state = _QuizState(questions: widget.questions);
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timerSeconds = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_timerSeconds > 0) setState(() => _timerSeconds--);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _selectOption(String option) {
    if (_state.phase != _QuizPhase.answering) return;
    setState(() {
      _state = _state.copyWith(selectedOption: option);
    });
  }

  void _confirmAnswer() {
    final selected = _state.selectedOption;
    if (selected == null) return;
    _timer?.cancel();

    final newAnswers = Map<String, String>.from(_state.answers)
      ..[_state.current.id] = selected;

    setState(() {
      _state = _state.copyWith(
        answers: newAnswers,
        phase: _QuizPhase.reviewing,
      );
    });
  }

  Future<void> _next() async {
    if (_state.isLast) {
      await _submit();
    } else {
      setState(() {
        _state = _state.copyWith(
          currentIndex: _state.currentIndex + 1,
          phase: _QuizPhase.answering,
          clearSelection: true,
        );
      });
      _startTimer();
    }
  }

  Future<void> _submit() async {
    setState(() =>
        _state = _state.copyWith(submitting: true, phase: _QuizPhase.results));
    try {
      final result =
          await widget.service.submitQuiz(widget.topicId, _state.answers);
      setState(
          () => _state = _state.copyWith(result: result, submitting: false));
    } catch (_) {
      setState(() => _state =
          _state.copyWith(submitting: false, phase: _QuizPhase.reviewing));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.phase == _QuizPhase.results) {
      return _ResultsView(state: _state);
    }

    return Column(
      children: [
        _ProgressBar(
          current: _state.currentIndex,
          total: _state.questions.length,
          timerSeconds: _timerSeconds,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: _QuestionView(
              state: _state,
              onSelectOption: _selectOption,
              onConfirm: _confirmAnswer,
              onNext: _next,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Progress bar
// ─────────────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.current,
    required this.total,
    required this.timerSeconds,
  });

  final int current;
  final int total;
  final int timerSeconds;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final m = timerSeconds ~/ 60;
    final s = (timerSeconds % 60).toString().padLeft(2, '0');
    final isLow = timerSeconds < 30;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.quizQuestionOf(current + 1, total),
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isLow
                      ? Colors.red.withValues(alpha: 0.08)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isLow
                        ? Colors.red.withValues(alpha: 0.3)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 13,
                      color: isLow ? Colors.red : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$m:$s',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isLow ? Colors.red : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          AppProgressBar(
            value: (current + 1) / total,
            color: const Color(0xFF34D399),
            height: 3,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Question view (answering + reviewing phases)
// ─────────────────────────────────────────────────────────────────

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.state,
    required this.onSelectOption,
    required this.onConfirm,
    required this.onNext,
  });

  final _QuizState state;
  final void Function(String) onSelectOption;
  final VoidCallback onConfirm;
  final Future<void> Function() onNext;

  Color _difficultyColor(String diff) {
    switch (diff.toUpperCase()) {
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
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final q = state.current;
    final reviewing = state.phase == _QuizPhase.reviewing;
    final diffColor = _difficultyColor(q.difficulty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            q.difficulty,
            style: TextStyle(
                color: diffColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
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
                isSelected: state.selectedOption == entry.value,
                isReviewing: reviewing,
                onTap: reviewing ? null : () => onSelectOption(entry.value),
              ),
            ),
        if (reviewing) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: const Color(0xFF34D399).withValues(alpha: 0.3)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF34D399), size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    q.explanation ?? l10n.quizAnswerRecorded,
                    style: const TextStyle(
                      color: Color(0xFF065F46),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        if (!reviewing)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.selectedOption != null ? onConfirm : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(l10n.quizSubmit),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => onNext(),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(state.isLast ? l10n.quizFinish : l10n.quizNext),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Option tile
// ─────────────────────────────────────────────────────────────────

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
                      color:
                          isSelected ? Colors.white : const Color(0xFF6B7280),
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
              if (isSelected) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF34D399),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Results view
// ─────────────────────────────────────────────────────────────────

class _ResultsView extends StatelessWidget {
  const _ResultsView({required this.state});

  final _QuizState state;

  Color _scoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return const Color(0xFFFB8C00);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (state.submitting || state.result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final result = state.result!;
    final scoreColor = _scoreColor(result.score);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 24),
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
                '${result.score}%',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.quizResult(result.score),
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '${result.correctCount} / ${result.totalCount} correct',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 32),
          _ReviewList(questions: state.questions, feedback: result.feedback),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.commonDone),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  const _ReviewList({required this.questions, required this.feedback});

  final List<QuizQuestion> questions;
  final List<QuizFeedback> feedback;

  @override
  Widget build(BuildContext context) {
    final feedbackMap = {for (final f in feedback) f.questionId: f};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...questions.map((q) {
          final fb = feedbackMap[q.id];
          if (fb == null) return const SizedBox.shrink();
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: fb.correct
                    ? Colors.green.withValues(alpha: 0.08)
                    : Colors.red.withValues(alpha: 0.08),
                border: Border.all(
                  color: fb.correct
                      ? Colors.green.withValues(alpha: 0.4)
                      : Colors.red.withValues(alpha: 0.4),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        fb.correct ? Icons.check_circle : Icons.cancel,
                        color: fb.correct ? Colors.green : Colors.red,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          q.text,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                  if (!fb.correct) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Correct: ${fb.correctAnswer}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green.shade700,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
