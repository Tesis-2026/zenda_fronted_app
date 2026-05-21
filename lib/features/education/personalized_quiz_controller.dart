import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'education_screen.dart' show educationServiceProvider;

enum PersonalizedQuizPhase { answering, reviewing, results }

class PersonalizedQuizState {
  final int index;
  final String? selected;
  final Map<String, String> answers;
  final PersonalizedQuizPhase phase;
  final bool submitting;
  final Map<String, dynamic>? submitResult;

  const PersonalizedQuizState({
    this.index = 0,
    this.selected,
    this.answers = const {},
    this.phase = PersonalizedQuizPhase.answering,
    this.submitting = false,
    this.submitResult,
  });

  PersonalizedQuizState copyWith({
    int? index,
    String? selected,
    Map<String, String>? answers,
    PersonalizedQuizPhase? phase,
    bool? submitting,
    Map<String, dynamic>? submitResult,
    bool clearSelected = false,
  }) {
    return PersonalizedQuizState(
      index: index ?? this.index,
      selected: clearSelected ? null : (selected ?? this.selected),
      answers: answers ?? this.answers,
      phase: phase ?? this.phase,
      submitting: submitting ?? this.submitting,
      submitResult: submitResult ?? this.submitResult,
    );
  }
}

class PersonalizedQuizController extends Notifier<PersonalizedQuizState> {
  @override
  PersonalizedQuizState build() => const PersonalizedQuizState();

  void selectOption(String option) {
    if (state.phase != PersonalizedQuizPhase.answering) return;
    state = state.copyWith(selected: option);
  }

  void confirmAnswer(String questionId) {
    final selected = state.selected;
    if (selected == null) return;
    final answers = Map<String, String>.from(state.answers)
      ..[questionId] = selected;
    state = state.copyWith(
      answers: answers,
      phase: PersonalizedQuizPhase.reviewing,
    );
  }

  /// Advances to the next question, or submits when [isLast].
  /// Returns `true` when submission failed so the UI can surface a toast.
  Future<bool> next({required bool isLast}) async {
    if (isLast) {
      return _submit();
    }
    state = state.copyWith(
      index: state.index + 1,
      clearSelected: true,
      phase: PersonalizedQuizPhase.answering,
    );
    return false;
  }

  Future<bool> _submit() async {
    state = state.copyWith(submitting: true, phase: PersonalizedQuizPhase.results);
    try {
      final result = await ref
          .read(educationServiceProvider)
          .submitPersonalizedQuiz(state.answers);
      state = state.copyWith(submitResult: result, submitting: false);
      return false;
    } catch (_) {
      state = state.copyWith(
        submitting: false,
        phase: PersonalizedQuizPhase.reviewing,
      );
      return true;
    }
  }
}

final personalizedQuizControllerProvider = NotifierProvider.autoDispose<
    PersonalizedQuizController, PersonalizedQuizState>(
  PersonalizedQuizController.new,
);
