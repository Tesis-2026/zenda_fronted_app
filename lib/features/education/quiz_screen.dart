import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/api_client.dart';
import '../../l10n/l10n_extension.dart';

// ─────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────

class QuizQuestion {
  final String id;
  final String difficulty;
  final String text;
  final List<String> options;

  const QuizQuestion({
    required this.id,
    required this.difficulty,
    required this.text,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      difficulty: json['difficulty'] as String,
      text: json['text'] as String,
      options: (json['options'] as List<dynamic>).cast<String>(),
    );
  }
}

class QuizFeedback {
  final String questionId;
  final bool correct;
  final String correctAnswer;

  const QuizFeedback({
    required this.questionId,
    required this.correct,
    required this.correctAnswer,
  });

  factory QuizFeedback.fromJson(Map<String, dynamic> json) {
    return QuizFeedback(
      questionId: json['questionId'] as String,
      correct: json['correct'] as bool,
      correctAnswer: json['correctAnswer'] as String,
    );
  }
}

class QuizResult {
  final int score;
  final int correctCount;
  final int totalCount;
  final String level;
  final List<QuizFeedback> feedback;

  const QuizResult({
    required this.score,
    required this.correctCount,
    required this.totalCount,
    required this.level,
    required this.feedback,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      score: json['score'] as int,
      correctCount: json['correctCount'] as int,
      totalCount: json['totalCount'] as int,
      level: json['level'] as String,
      feedback: (json['feedback'] as List<dynamic>)
          .map((e) => QuizFeedback.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// API service methods (inline, consistent with project pattern)
// ─────────────────────────────────────────────────────────────────

Future<List<QuizQuestion>> fetchQuiz(String topicId, String language) async {
  final data = await ApiClient.get('/education/topics/$topicId/quiz?language=$language');
  final map = data;
  return (map['questions'] as List<dynamic>)
      .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
      .toList();
}

Future<QuizResult> submitQuiz(
  String topicId,
  Map<String, String> answers,
) async {
  final data = await ApiClient.post(
    '/education/topics/$topicId/quiz/submit',
    {'answers': answers},
    authenticated: true,
  );
  return QuizResult.fromJson(data);
}

// ─────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────

final _quizProvider = FutureProvider.autoDispose
    .family<List<QuizQuestion>, ({String topicId, String language})>(
  (ref, args) => fetchQuiz(args.topicId, args.language),
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
      selectedOption: clearSelection ? null : (selectedOption ?? this.selectedOption),
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
  const QuizScreen({super.key, required this.topicId});

  final String topicId;

  String _deviceLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'es' ? 'es' : 'en';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final language = _deviceLanguage(context);
    final quizAsync = ref.watch(_quizProvider((topicId: topicId, language: language)));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
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
                  child: const Text('Go back'),
                ),
              ],
            ),
          ),
        ),
        data: (questions) => _QuizBody(
          topicId: topicId,
          questions: questions,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Quiz body (stateful — manages state machine)
// ─────────────────────────────────────────────────────────────────

class _QuizBody extends StatefulWidget {
  const _QuizBody({required this.topicId, required this.questions});

  final String topicId;
  final List<QuizQuestion> questions;

  @override
  State<_QuizBody> createState() => _QuizBodyState();
}

class _QuizBodyState extends State<_QuizBody> {
  late _QuizState _state;

  @override
  void initState() {
    super.initState();
    _state = _QuizState(questions: widget.questions);
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
    }
  }

  Future<void> _submit() async {
    setState(() => _state = _state.copyWith(submitting: true, phase: _QuizPhase.results));
    try {
      final result = await submitQuiz(widget.topicId, _state.answers);
      setState(() => _state = _state.copyWith(result: result, submitting: false));
    } catch (_) {
      setState(() => _state = _state.copyWith(submitting: false, phase: _QuizPhase.reviewing));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_state.phase == _QuizPhase.results) {
      return _ResultsView(state: _state);
    }

    return Column(
      children: [
        _ProgressBar(current: _state.currentIndex, total: _state.questions.length),
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
  const _ProgressBar({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${current + 1} / $total',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: (current + 1) / total,
            borderRadius: BorderRadius.circular(4),
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
    final selectedAnswer = state.answers[q.id];
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
            style: TextStyle(color: diffColor, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          q.text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(height: 1.5),
        ),
        const SizedBox(height: 24),
        ...q.options.map(
          (option) => _OptionTile(
            option: option,
            isSelected: state.selectedOption == option,
            isReviewing: reviewing,
            isCorrect: reviewing && state.selectedOption == option,
            showCorrect: reviewing && option == selectedAnswer && selectedAnswer != null,
            correctAnswer: reviewing ? selectedAnswer : null,
            actualCorrect: null,
            onTap: reviewing ? null : () => onSelectOption(option),
          ),
        ),
        const SizedBox(height: 28),
        if (!reviewing)
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.selectedOption != null ? onConfirm : null,
              child: Text(l10n.quizSubmit),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: state.isLast ? () => onNext() : () => onNext(),
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
    required this.isSelected,
    required this.isReviewing,
    required this.isCorrect,
    required this.showCorrect,
    required this.correctAnswer,
    required this.actualCorrect,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final bool isReviewing;
  final bool isCorrect;
  final bool showCorrect;
  final String? correctAnswer;
  final String? actualCorrect;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color? tileColor;
    Color? borderColor;
    Widget? trailingIcon;

    if (isReviewing) {
      if (actualCorrect != null && option == actualCorrect) {
        tileColor = Colors.green.withValues(alpha: 0.12);
        borderColor = Colors.green;
        trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
      } else if (actualCorrect != null && isSelected) {
        tileColor = Colors.red.withValues(alpha: 0.10);
        borderColor = Colors.red;
        trailingIcon = const Icon(Icons.cancel, color: Colors.red);
      } else if (isSelected) {
        tileColor = colorScheme.primaryContainer;
        borderColor = colorScheme.primary;
      }
    } else if (isSelected) {
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
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected || (isReviewing && option == actualCorrect)
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 8),
                trailingIcon,
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
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
              child: const Text('Done'),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
