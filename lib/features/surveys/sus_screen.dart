import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/services/study_telemetry_service.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';

final susSurveyServiceProvider = Provider<SurveysApiService>(
  (_) => SurveysApiService(),
);

final _susSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref.read(susSurveyServiceProvider).getSusSurvey();
});

class SusScreen extends ConsumerStatefulWidget {
  const SusScreen({super.key});

  @override
  ConsumerState<SusScreen> createState() => _SusScreenState();
}

class _SusScreenState extends ConsumerState<SusScreen> {
  final Map<String, int> _ratings = {};
  bool _submitting = false;
  SusResult? _result;

  Future<void> _submit(List<SurveyQuestion> questions) async {
    if (_ratings.length < questions.length) {
      showAppToast(
        context,
        context.l10n.surveyAnswerAll,
        type: ToastType.warning,
      );
      return;
    }
    setState(() => _submitting = true);
    StudyTelemetryService.track(
      'sus_submit_started',
      metadata: {'answers_count': _ratings.length},
    );
    try {
      final answers = {
        for (final q in questions) q.id: _ratings[q.id]!.toString(),
      };
      final result = await ref
          .read(susSurveyServiceProvider)
          .submitSus(answers);
      StudyTelemetryService.track(
        'sus_submit_success',
        metadata: {'sus_score': result.susScore, 'grade': result.grade},
      );
      if (mounted) setState(() => _result = result);
    } catch (e) {
      StudyTelemetryService.track(
        'sus_submit_failed',
        metadata: {'error': e.toString()},
      );
      if (mounted) {
        final l10n = context.l10n;
        final message = e.toString().contains('409')
            ? l10n.susSurveyAlreadyDone
            : l10n.susSurveyErrorSubmit;
        showAppToast(context, message, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final surveyAsync = ref.watch(_susSurveyProvider);

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(title: l10n.susSurveyTitle),
      body: surveyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) {
          // Hardcoded fallback with the 10 standard SUS questions
          const fallbackSurvey = Survey(
            id: 'sus-fallback',
            type: 'SUS',
            questions: [
              SurveyQuestion(
                id: 'sus-1',
                order: 1,
                text: 'Creo que me gustaría usar este sistema con frecuencia.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-2',
                order: 2,
                text: 'Encontré el sistema innecesariamente complejo.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-3',
                order: 3,
                text: 'Me pareció que el sistema era fácil de usar.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-4',
                order: 4,
                text:
                    'Creo que necesitaría el apoyo de una persona técnica para poder usar este sistema.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-5',
                order: 5,
                text:
                    'Encontré que las distintas funciones de este sistema estaban bien integradas.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-6',
                order: 6,
                text:
                    'Pensé que había demasiada inconsistencia en este sistema.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-7',
                order: 7,
                text:
                    'Imagino que la mayoría de las personas aprenderían a usar este sistema muy rápidamente.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-8',
                order: 8,
                text: 'Encontré el sistema muy engorroso de usar.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-9',
                order: 9,
                text: 'Me sentí muy seguro usando el sistema.',
                options: [],
              ),
              SurveyQuestion(
                id: 'sus-10',
                order: 10,
                text:
                    'Necesité aprender muchas cosas antes de poder empezar a usar este sistema.',
                options: [],
              ),
            ],
          );
          if (_result != null) return _ResultView(result: _result!);
          return _SurveyForm(
            survey: fallbackSurvey,
            ratings: _ratings,
            submitting: _submitting,
            onRatingChanged: (questionId, value) =>
                setState(() => _ratings[questionId] = value),
            onSubmit: () => _submit(fallbackSurvey.questions),
          );
        },
        data: (survey) {
          if (_result != null) return _ResultView(result: _result!);
          return _SurveyForm(
            survey: survey,
            ratings: _ratings,
            submitting: _submitting,
            onRatingChanged: (questionId, value) =>
                setState(() => _ratings[questionId] = value),
            onSubmit: () => _submit(survey.questions),
          );
        },
      ),
    );
  }
}

class _SurveyForm extends StatelessWidget {
  const _SurveyForm({
    required this.survey,
    required this.ratings,
    required this.submitting,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  final Survey survey;
  final Map<String, int> ratings;
  final bool submitting;
  final void Function(String questionId, int value) onRatingChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          l10n.susSurveyDescription,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('1', style: Theme.of(context).textTheme.labelSmall),
            Text(
              l10n.susSurveyStronglyDisagree,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const Spacer(),
            Text(
              l10n.susSurveyStronglyAgree,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            Text('5', style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
        const Divider(height: 24),
        ...survey.questions.map(
          (q) => _QuestionRow(
            question: q,
            selectedValue: ratings[q.id],
            onChanged: (v) => onRatingChanged(q.id, v),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: submitting ? null : onSubmit,
            child: submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(l10n.susSurveySubmit),
          ),
        ),
      ],
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({
    required this.question,
    required this.selectedValue,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final int? selectedValue;
  final void Function(int) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${question.order}. ${question.text}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (i) {
                  final value = i + 1;
                  final isSelected = selectedValue == value;
                  return GestureDetector(
                    onTap: () => onChanged(value),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});
  final SusResult result;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = result.susScore >= 70
        ? Colors.green
        : result.susScore >= 50
        ? Colors.orange
        : Colors.red;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Text(
                '${result.susScore}',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.susSurveyResultTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.susSurveyResultScore(result.susScore),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.susSurveyResultGrade(result.grade),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: Text(l10n.susSurveyResultContinue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
