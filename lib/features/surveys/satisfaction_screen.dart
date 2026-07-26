import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/services/study_telemetry_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';

class SatisfactionScreen extends StatefulWidget {
  const SatisfactionScreen({super.key});

  @override
  State<SatisfactionScreen> createState() => _SatisfactionScreenState();
}

class _SatisfactionScreenState extends State<SatisfactionScreen> {
  final _service = SurveysApiService();
  final _answers = <String, String>{};
  final _controllers = <String, TextEditingController>{};
  late Future<Survey> _surveyFuture;
  bool _submitting = false;
  SatisfactionResult? _result;

  @override
  void initState() {
    super.initState();
    _surveyFuture = _loadSurvey();
    StudyTelemetryService.screen('satisfaction_survey');
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit(Survey survey) async {
    if (_submitting || !_allAnswered(survey)) return;
    setState(() => _submitting = true);
    StudyTelemetryService.track(
      'satisfaction_submit_started',
      metadata: {'questions_count': survey.questions.length},
    );

    try {
      final result = await _service.submitSatisfaction(_answers);
      if (!mounted) return;
      StudyTelemetryService.track(
        'satisfaction_submit_success',
        metadata: {
          'score': result.score,
          'average_likert': result.averageLikert,
        },
      );
      setState(() => _result = result);
    } catch (e) {
      if (!mounted) return;
      StudyTelemetryService.track(
        'satisfaction_submit_failed',
        metadata: {'error': e.toString()},
      );
      showAppToast(
        context,
        'No se pudo enviar la encuesta final.',
        type: ToastType.error,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<Survey> _loadSurvey() {
    return _service.getSatisfactionSurvey().timeout(
      const Duration(seconds: 12),
    );
  }

  bool _allAnswered(Survey survey) {
    return survey.questions.every((question) {
      final answer = _answers[question.id]?.trim();
      return answer != null && answer.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: const ZendaAppBar(title: 'Encuesta final'),
      body: FutureBuilder<Survey>(
        future: _surveyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              onRetry: () => setState(() {
                _surveyFuture = _loadSurvey();
              }),
            );
          }

          final survey = snapshot.data!;
          final result = _result;
          if (result != null) return _ResultView(result: result);

          final canSubmit = _allAnswered(survey) && !_submitting;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              Text(
                'Cierre del piloto',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tus respuestas ayudan a medir utilidad, claridad del asistente e intención de uso.',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 20),
              ...survey.questions.map((question) {
                if (question.options.isEmpty) {
                  return _OpenQuestionTile(
                    question: question,
                    controller: _controllers.putIfAbsent(
                      question.id,
                      () => TextEditingController(),
                    ),
                    onChanged: (value) =>
                        setState(() => _answers[question.id] = value),
                  );
                }
                return _LikertQuestionTile(
                  question: question,
                  selectedValue: _answers[question.id],
                  onChanged: (value) =>
                      setState(() => _answers[question.id] = value),
                );
              }),
              const SizedBox(height: 8),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: canSubmit ? () => _submit(survey) : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enviar encuesta final'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LikertQuestionTile extends StatelessWidget {
  const _LikertQuestionTile({
    required this.question,
    required this.selectedValue,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String? selectedValue;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '1 = Totalmente en desacuerdo · 5 = Totalmente de acuerdo',
            style: TextStyle(color: colors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: question.options.map((option) {
              final selected = option == selectedValue;
              return SizedBox(
                width: 46,
                height: 46,
                child: ChoiceChip(
                  label: Center(child: Text(option)),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => onChanged(option),
                  selectedColor: AppColors.primary,
                  backgroundColor: colors.fill,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : colors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.primary : colors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _OpenQuestionTile extends StatelessWidget {
  const _OpenQuestionTile({
    required this.question,
    required this.controller,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        minLines: 2,
        maxLines: 4,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          labelText: question.text,
          alignLabelWithHint: true,
          filled: true,
          fillColor: colors.card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});

  final SatisfactionResult result;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Encuesta enviada',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Promedio de satisfacción: ${result.averageLikert.toStringAsFixed(1)}/5',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textMuted, height: 1.45),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () => context.go('/dashboard'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 42, color: colors.textMuted),
            const SizedBox(height: 12),
            Text(
              'No se pudo cargar la encuesta final.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
