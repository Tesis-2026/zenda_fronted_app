import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/surveys_api_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/pre_survey_provider.dart';

final _surveysServiceProvider = Provider<SurveysApiService>(
  (_) => SurveysApiService(),
);

final _preSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref.read(_surveysServiceProvider).getPreSurvey();
});

final _postSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref.read(_surveysServiceProvider).getPostSurvey();
});

/// [isPre] determines which survey (pre vs post) to load and submit.
class SurveyScreen extends ConsumerStatefulWidget {
  const SurveyScreen({super.key, required this.isPre});
  final bool isPre;

  @override
  ConsumerState<SurveyScreen> createState() => _SurveyScreenState();
}

class _SurveyScreenState extends ConsumerState<SurveyScreen> {
  final Map<String, String> _answers = {};
  int _currentIndex = 0;
  bool _submitting = false;
  SurveyResult? _result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final surveyAsync = widget.isPre
        ? ref.watch(_preSurveyProvider)
        : ref.watch(_postSurveyProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isPre ? l10n.surveyPreTitle : l10n.surveyPostTitle,
        ),
      ),
      body: surveyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.surveyErrorLoad)),
        data: (survey) {
          if (_result != null) {
            return _ResultView(result: _result!, isPre: widget.isPre);
          }
          return _SurveyForm(
            survey: survey,
            currentIndex: _currentIndex,
            answers: _answers,
            submitting: _submitting,
            onAnswerChanged: (questionId, answer) {
              setState(() => _answers[questionId] = answer);
            },
            onNext: () {
              setState(() => _currentIndex++);
            },
            onSubmit: () => _submit(survey),
          );
        },
      ),
    );
  }

  Future<void> _submit(Survey survey) async {
    setState(() => _submitting = true);
    try {
      final service = ref.read(_surveysServiceProvider);
      final result = widget.isPre
          ? await service.submitPre(_answers)
          : await service.submitPost(_answers);
      if (widget.isPre) {
        await ref.read(preSurveyProvider.notifier).markCompleted();
      } else {
        await ref.read(postSurveyProvider.notifier).markCompleted();
      }

      if (mounted) {
        await _showResultSummaryDialog(result);
      }

      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        showAppToast(context, context.l10n.surveySubmitError, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _showResultSummaryDialog(SurveyResult result) async {
    final l10n = context.l10n;
    final level = result.level ?? '—';
    final score = result.score.toStringAsFixed(0);

    final bool isPostWithImprovement =
        !widget.isPre && result.improvement != null;

    String title;
    String body;

    if (isPostWithImprovement) {
      // For post-survey with improvement data we need a pre-score proxy.
      // improvement = postScore - preScore → preScore = postScore - improvement
      final improvement = result.improvement!;
      final preScore = (result.score - improvement).toStringAsFixed(0);
      title = l10n.surveyImprovementDialogTitle;
      body = l10n.surveyImprovementDialogBody(
        score,
        preScore,
        improvement.toStringAsFixed(1),
      );
    } else {
      title = l10n.surveyResultDialogTitle;
      body = l10n.surveyResultDialogBody(level, score);
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonOk),
          ),
        ],
      ),
    );
  }
}

class _SurveyForm extends StatelessWidget {
  const _SurveyForm({
    required this.survey,
    required this.currentIndex,
    required this.answers,
    required this.submitting,
    required this.onAnswerChanged,
    required this.onNext,
    required this.onSubmit,
  });

  final Survey survey;
  final int currentIndex;
  final Map<String, String> answers;
  final bool submitting;
  final void Function(String questionId, String answer) onAnswerChanged;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final total = survey.questions.length;
    final question = survey.questions[currentIndex];
    final isLast = currentIndex == total - 1;
    final hasAnswer = answers.containsKey(question.id);

    return Column(
      children: [
        LinearProgressIndicator(
          value: (currentIndex + 1) / total,
          minHeight: 4,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${currentIndex + 1} / $total',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _QuestionCard(
              question: question,
              selectedAnswer: answers[question.id],
              onChanged: (answer) => onAnswerChanged(question.id, answer),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: isLast
                ? FilledButton(
                    onPressed: (hasAnswer && !submitting) ? onSubmit : null,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.surveySubmitButton),
                  )
                : FilledButton(
                    onPressed: hasAnswer ? onNext : null,
                    child: Text(l10n.surveyNextButton),
                  ),
          ),
        ),
      ],
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.selectedAnswer,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String? selectedAnswer;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question.text,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            RadioGroup<String>(
              groupValue: selectedAnswer,
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
              child: Column(
                children: question.options
                    .map(
                      (option) => RadioListTile<String>(
                        title: Text(option),
                        value: option,
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.isPre});
  final SurveyResult result;
  final bool isPre;

  Color _levelColor(String? level) {
    switch (level) {
      case 'HIGH':
        return const Color(0xFF43A047);
      case 'MEDIUM':
        return const Color(0xFFFB8C00);
      default:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Color(0xFF43A047)),
            const SizedBox(height: 24),
            Text(
              l10n.surveyResultTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '${result.score.toStringAsFixed(0)} / 100',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (result.level != null) ...[
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: _levelColor(result.level).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  result.level!,
                  style: TextStyle(
                    color: _levelColor(result.level),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (!isPre && result.improvement != null) ...[
              const SizedBox(height: 16),
              Text(
                l10n.surveyImprovement(result.improvement!.toStringAsFixed(1)),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/dashboard'),
                child: Text(l10n.surveyResultContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
