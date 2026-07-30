import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/api_client.dart';
import '../../core/services/education_api_service.dart';
import '../../core/services/pending_survey_queue.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/delete_confirm_sheet.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import '../auth/auth_controller.dart';
import '../../providers/pre_survey_provider.dart';

const _surveyLoadTimeout = Duration(seconds: 12);

final surveysServiceProvider = Provider<SurveysApiService>(
  (_) => SurveysApiService(),
);

final _preSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref
      .read(surveysServiceProvider)
      .getPreSurvey()
      .timeout(_surveyLoadTimeout);
});

final _postSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref
      .read(surveysServiceProvider)
      .getPostSurvey()
      .timeout(_surveyLoadTimeout);
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _skipSurvey();
      },
      child: Scaffold(
        backgroundColor: context.colors.bg,
        appBar: ZendaAppBar(
          title: widget.isPre ? l10n.surveyPreTitle : l10n.surveyPostTitle,
          actions: [
            TextButton(
              onPressed: _skipSurvey,
              child: Text(
                l10n.surveySkipButton,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: surveyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) {
            // Hardcoded fallback with 5 financial literacy questions
            final fallbackSurvey = Survey(
              id: widget.isPre ? 'pre-fallback' : 'post-fallback',
              type: widget.isPre ? 'PRE' : 'POST',
              questions: const [
                SurveyQuestion(
                  id: 'fl-1',
                  order: 1,
                  text:
                      '¿Qué porcentaje de tus ingresos deberías ahorrar cada mes según la regla 50/30/20?',
                  options: ['10%', '20%', '30%', '50%'],
                ),
                SurveyQuestion(
                  id: 'fl-2',
                  order: 2,
                  text: '¿Qué es el interés compuesto?',
                  options: [
                    'Interés solo sobre el capital',
                    'Interés sobre el capital más los intereses acumulados',
                    'Una comisión mensual fija',
                    'Un tipo de fondo de inversión',
                  ],
                ),
                SurveyQuestion(
                  id: 'fl-3',
                  order: 3,
                  text: '¿Qué es un fondo de emergencia?',
                  options: [
                    'Dinero para vacaciones',
                    'De 3 a 6 meses de gastos ahorrados',
                    'Una cuenta de jubilación',
                    'El límite de una tarjeta de crédito',
                  ],
                ),
                SurveyQuestion(
                  id: 'fl-4',
                  order: 4,
                  text:
                      '¿Cuál de estos es una "Necesidad" según la regla 50/30/20?',
                  options: [
                    'Servicios de streaming',
                    'Cenas en restaurantes',
                    'Alquiler y servicios básicos',
                    'Ropa nueva',
                  ],
                ),
                SurveyQuestion(
                  id: 'fl-5',
                  order: 5,
                  text: '¿Qué significan las siglas TEA (Tasa Efectiva Anual)?',
                  options: [
                    'Tasa Efectiva Anual',
                    'Tasa Esperada Acumulada',
                    'Tope Efectivo Anual',
                    'Tasa de Equilibrio Anual',
                  ],
                ),
              ],
            );
            if (_result != null) {
              return _ResultView(result: _result!, isPre: widget.isPre);
            }
            return _SurveyForm(
              survey: fallbackSurvey,
              currentIndex: _currentIndex,
              answers: _answers,
              submitting: _submitting,
              onAnswerChanged: (questionId, answer) {
                setState(() => _answers[questionId] = answer);
              },
              onNext: () {
                setState(() => _currentIndex++);
              },
              onSubmit: () {
                showAppToast(
                  context,
                  'No se pudo conectar con la encuesta. Puedes responderla luego.',
                  type: ToastType.warning,
                );
                _skipSurvey();
              },
            );
          },
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
      ),
    );
  }

  Future<void> _skipSurvey() async {
    if (widget.isPre) {
      await ref.read(preSurveyProvider.notifier).skipForNow();
    } else {
      await ref.read(postSurveyProvider.notifier).skipForNow();
    }
    if (mounted) context.go('/dashboard');
  }

  Future<void> _submit(Survey survey) async {
    setState(() => _submitting = true);
    try {
      final service = ref.read(surveysServiceProvider);
      final result = widget.isPre
          ? await service.submitPre(_answers)
          : await service.submitPost(_answers);
      if (widget.isPre) {
        await ref.read(preSurveyProvider.notifier).markCompleted();
      } else {
        await ref.read(postSurveyProvider.notifier).markCompleted();
      }

      if (mounted) {
        await _showResultSummarySheet(result);
      }

      if (mounted) setState(() => _result = result);
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        if (widget.isPre) {
          await ref.read(preSurveyProvider.notifier).markCompleted();
        } else {
          await ref.read(postSurveyProvider.notifier).markCompleted();
        }
        if (mounted) {
          showAppToast(
            context,
            'Esta encuesta ya fue enviada.',
            type: ToastType.info,
          );
          context.go('/dashboard');
        }
        return;
      }
      if (mounted) {
        final userId = ref.read(authNotifierProvider).user?.id;
        final shouldQueue = e is! ApiException || e.statusCode >= 500;
        if (userId != null && shouldQueue) {
          await PendingSurveyQueue.save(
            userId: userId,
            type: widget.isPre ? 'PRE' : 'POST',
            answers: _answers,
          );
          if (widget.isPre) {
            await ref.read(preSurveyProvider.notifier).skipForNow();
          } else {
            await ref.read(postSurveyProvider.notifier).skipForNow();
          }
          if (mounted) {
            showAppToast(
              context,
              'Guardamos tus respuestas y las reintentaremos en segundo plano.',
              type: ToastType.info,
            );
            context.go('/dashboard');
          }
          return;
        }

        final message = e is ApiException
            ? 'No se pudo enviar: ${e.message}'
            : context.l10n.surveySubmitError;
        showAppToast(context, message, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  /// The backend reports the literacy level as a raw enum code
  /// (`LOW` / `MEDIUM` / `HIGH`) — always localize before display.
  String _literacyLevelLabel(String? code) {
    final l10n = context.l10n;
    return switch (code) {
      'LOW' => l10n.literacyLevelLow,
      'MEDIUM' => l10n.literacyLevelMedium,
      'HIGH' => l10n.literacyLevelHigh,
      _ => '—',
    };
  }

  Future<void> _showResultSummarySheet(SurveyResult result) async {
    final l10n = context.l10n;
    final level = _literacyLevelLabel(result.level);
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

    await showConfirmSheet(
      context,
      title: title,
      message: body,
      confirmLabel: l10n.commonOk,
      tone: ConfirmTone.neutral,
      icon: Icons.school_outlined,
      showCancel: false,
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
        // Progress bar
        AppProgressBar(
          value: (currentIndex + 1) / total,
          color: const Color(0xFF34D399),
          height: 4,
          backgroundColor: const Color(0xFFE5E7EB),
        ),
        // Counter label: "3 of 5" centered in AppBar-style row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${currentIndex + 1} ${l10n.surveyProgressOf} $total',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: const Color(0xFF6B7280)),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _QuestionContent(
              question: question,
              selectedAnswer: answers[question.id],
              onChanged: (answer) => onAnswerChanged(question.id, answer),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: isLast
                ? FilledButton(
                    onPressed: (hasAnswer && !submitting) ? onSubmit : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(l10n.surveySubmitButton),
                  )
                : FilledButton(
                    onPressed: hasAnswer ? onNext : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text('${l10n.surveyNextButton} →'),
                  ),
          ),
        ),
      ],
    );
  }
}

class _QuestionContent extends StatelessWidget {
  const _QuestionContent({
    required this.question,
    required this.selectedAnswer,
    required this.onChanged,
  });

  final SurveyQuestion question;
  final String? selectedAnswer;
  final void Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Optional category icon
        const SizedBox(height: 8),
        const Icon(
          Icons.monetization_on_outlined,
          size: 40,
          color: Color(0xFF9CA3AF),
        ),
        const SizedBox(height: 20),
        // Large question text (no card wrapper)
        Text(
          question.text,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            height: 1.3,
          ),
        ),
        const SizedBox(height: 24),
        // Full-width option tiles
        ...question.options.map((option) {
          final isSelected = selectedAnswer == option;
          return GestureDetector(
            onTap: () => onChanged(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF34D399) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF34D399)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: CircleAvatar(
                              radius: 5,
                              backgroundColor: Color(0xFF34D399),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF1F2937),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result, required this.isPre});
  final SurveyResult result;
  final bool isPre;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String? badgeUnlocked = result.badgeUnlocked;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Celebration icon
          const Icon(
            Icons.celebration_rounded,
            size: 64,
            color: Color(0xFF34D399),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.surveyCompleteTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.surveyCompleteSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6B7280),
              height: 1.4,
            ),
          ),
          if (badgeUnlocked != null) ...[
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.military_tech_rounded,
                    size: 16,
                    color: Color(0xFF10B981),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '$badgeUnlocked ${l10n.surveyBadgeUnlocked}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          // Financial profile card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF34D399).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.surveyFinancialProfileTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.surveyFinancialProfileBody,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4B5563),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Go to Dashboard button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () => context.go('/dashboard'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF34D399),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('${l10n.surveyResultContinue} →'),
            ),
          ),
        ],
      ),
    );
  }
}
