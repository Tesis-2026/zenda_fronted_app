import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/quiz_models.dart';
import '../../core/services/quiz_api_service.dart';

/// Family key for a quiz: the topic being quizzed and the device language.
typedef QuizArgs = ({String topicId, String language});

const _quizDurationSeconds = 120;

/// Loads the questions for a quiz topic. Shared by the screen (to gate the
/// loading/error UI) and by [QuizGameController] (to seed its state).
final quizQuestionsProvider =
    FutureProvider.autoDispose.family<List<QuizQuestion>, QuizArgs>(
  (ref, args) =>
      ref.read(quizServiceProvider).getQuiz(args.topicId, args.language),
);

enum QuizPhase { answering, reviewing, results }

class QuizGameState {
  final List<QuizQuestion> questions;
  final int currentIndex;
  final Map<String, String> answers;
  final String? selectedOption;
  final QuizPhase phase;
  final QuizResult? result;
  final bool submitting;
  final int secondsRemaining;

  const QuizGameState({
    required this.questions,
    this.currentIndex = 0,
    this.answers = const {},
    this.selectedOption,
    this.phase = QuizPhase.answering,
    this.result,
    this.submitting = false,
    this.secondsRemaining = _quizDurationSeconds,
  });

  QuizQuestion get current => questions[currentIndex];
  bool get isLast => currentIndex >= questions.length - 1;

  QuizGameState copyWith({
    int? currentIndex,
    Map<String, String>? answers,
    String? selectedOption,
    QuizPhase? phase,
    QuizResult? result,
    bool? submitting,
    int? secondsRemaining,
    bool clearSelection = false,
  }) {
    return QuizGameState(
      questions: questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      selectedOption:
          clearSelection ? null : (selectedOption ?? this.selectedOption),
      phase: phase ?? this.phase,
      result: result ?? this.result,
      submitting: submitting ?? this.submitting,
      secondsRemaining: secondsRemaining ?? this.secondsRemaining,
    );
  }
}

class QuizGameController extends Notifier<QuizGameState> {
  QuizGameController(this._args);

  final QuizArgs _args;
  Timer? _timer;

  @override
  QuizGameState build() {
    ref.onDispose(() => _timer?.cancel());
    final questions = ref.watch(quizQuestionsProvider(_args)).requireValue;
    _scheduleTimer();
    return QuizGameState(questions: questions);
  }

  void _scheduleTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.secondsRemaining > 0) {
        state = state.copyWith(secondsRemaining: state.secondsRemaining - 1);
      }
    });
  }

  void selectOption(String option) {
    if (state.phase != QuizPhase.answering) return;
    state = state.copyWith(selectedOption: option);
  }

  void confirmAnswer() {
    final selected = state.selectedOption;
    if (selected == null) return;
    _timer?.cancel();

    final answers = Map<String, String>.from(state.answers)
      ..[state.current.id] = selected;
    state = state.copyWith(answers: answers, phase: QuizPhase.reviewing);
  }

  Future<void> next() async {
    if (state.isLast) {
      await _submit();
      return;
    }
    state = state.copyWith(
      currentIndex: state.currentIndex + 1,
      phase: QuizPhase.answering,
      clearSelection: true,
      secondsRemaining: _quizDurationSeconds,
    );
    _scheduleTimer();
  }

  Future<void> _submit() async {
    _timer?.cancel();
    state = state.copyWith(submitting: true, phase: QuizPhase.results);
    try {
      final result =
          await ref.read(quizServiceProvider).submitQuiz(_args.topicId, state.answers);
      state = state.copyWith(result: result, submitting: false);
    } catch (_) {
      state = state.copyWith(submitting: false, phase: QuizPhase.reviewing);
    }
  }
}

final quizGameProvider = NotifierProvider.autoDispose
    .family<QuizGameController, QuizGameState, QuizArgs>(QuizGameController.new);
