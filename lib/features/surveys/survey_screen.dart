import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/surveys_api_service.dart';
import '../../l10n/l10n_extension.dart';

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
            return _ResultView(
              result: _result!,
              isPre: widget.isPre,
            );
          }
          return _SurveyForm(
            survey: survey,
            answers: _answers,
            submitting: _submitting,
            onAnswerChanged: (questionId, answer) {
              setState(() => _answers[questionId] = answer);
            },
            onSubmit: () => _submit(survey),
          );
        },
      ),
    );
  }

  Future<void> _submit(Survey survey) async {
    if (_answers.length < survey.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.surveyAnswerAll)),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final service = ref.read(_surveysServiceProvider);
      final result = widget.isPre
          ? await service.submitPre(_answers)
          : await service.submitPost(_answers);
      setState(() => _result = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.surveySubmitError)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class _SurveyForm extends StatelessWidget {
  const _SurveyForm({
    required this.survey,
    required this.answers,
    required this.submitting,
    required this.onAnswerChanged,
    required this.onSubmit,
  });

  final Survey survey;
  final Map<String, String> answers;
  final bool submitting;
  final void Function(String questionId, String answer) onAnswerChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: survey.questions.length,
            itemBuilder: (context, index) {
              final q = survey.questions[index];
              return _QuestionCard(
                question: q,
                selectedAnswer: answers[q.id],
                onChanged: (answer) => onAnswerChanged(q.id, answer),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.surveySubmitButton),
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
              '${question.order}. ${question.text}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...question.options.map(
              (option) => RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: selectedAnswer,
                onChanged: (v) {
                  if (v != null) onChanged(v);
                },
                dense: true,
                contentPadding: EdgeInsets.zero,
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
          ],
        ),
      ),
    );
  }
}
