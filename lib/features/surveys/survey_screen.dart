import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/api_client.dart';
import '../../core/services/education_api_service.dart';
import '../../core/services/pending_survey_queue.dart';
import '../../core/widgets/app_toast.dart';
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

final _preStatusProvider = FutureProvider.autoDispose<FinancialLiteracyStatus>((
  ref,
) {
  return ref
      .read(surveysServiceProvider)
      .getPreStatus()
      .timeout(_surveyLoadTimeout);
});

final _postSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref
      .read(surveysServiceProvider)
      .getPostSurvey()
      .timeout(_surveyLoadTimeout);
});

/// Fallback 12 questions bank for FINLIT_PRE_V1.
/// Strictly contains questionId, questionText, domain, and options (without any correctAnswer).
const List<SurveyQuestion> _finlitFallbackQuestions = [
  SurveyQuestion(
    id: 'Q1',
    order: 1,
    domain: 'PLANIFICACION',
    text:
        '¿Cuál es la principal finalidad de elaborar un presupuesto personal?',
    options: [
      'Registrar únicamente las deudas.',
      'Planificar y controlar ingresos y gastos.',
      'Aumentar automáticamente los ingresos.',
      'Evitar utilizar productos financieros.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'Registrar únicamente las deudas.'),
      SurveyOption(id: 'B', text: 'Planificar y controlar ingresos y gastos.'),
      SurveyOption(id: 'C', text: 'Aumentar automáticamente los ingresos.'),
      SurveyOption(id: 'D', text: 'Evitar utilizar productos financieros.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q2',
    order: 2,
    domain: 'AHORRO',
    text:
        '¿Cuál es el principal objetivo de contar con un fondo de emergencia?',
    options: [
      'Financiar compras impulsivas.',
      'Tener dinero disponible para gastos imprevistos.',
      'Obtener mayores líneas de crédito.',
      'Reemplazar todos los seguros.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'Financiar compras impulsivas.'),
      SurveyOption(
        id: 'B',
        text: 'Tener dinero disponible para gastos imprevistos.',
      ),
      SurveyOption(id: 'C', text: 'Obtener mayores líneas de crédito.'),
      SurveyOption(id: 'D', text: 'Reemplazar todos los seguros.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q3',
    order: 3,
    domain: 'PLANIFICACION',
    text:
        'Si una persona tiene recursos limitados, ¿qué debería priorizar primero?',
    options: [
      'Gastos esenciales como alimentación, vivienda y transporte.',
      'Entretenimiento.',
      'Compras por promociones.',
      'Productos que desea aunque no necesite.',
    ],
    parsedOptions: [
      SurveyOption(
        id: 'A',
        text: 'Gastos esenciales como alimentación, vivienda y transporte.',
      ),
      SurveyOption(id: 'B', text: 'Entretenimiento.'),
      SurveyOption(id: 'C', text: 'Compras por promociones.'),
      SurveyOption(id: 'D', text: 'Productos que desea aunque no necesite.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q4',
    order: 4,
    domain: 'PLANIFICACION',
    text: '¿Cuál de los siguientes es normalmente un gasto variable?',
    options: [
      'Una cuota mensual fija de alquiler.',
      'Una pensión mensual con monto fijo.',
      'El gasto mensual en entretenimiento.',
      'Una cuota fija de un préstamo.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'Una cuota mensual fija de alquiler.'),
      SurveyOption(id: 'B', text: 'Una pensión mensual con monto fijo.'),
      SurveyOption(id: 'C', text: 'El gasto mensual en entretenimiento.'),
      SurveyOption(id: 'D', text: 'Una cuota fija de un préstamo.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q5',
    order: 5,
    domain: 'CONOCIMIENTO_FINANCIERO',
    text:
        'Si depositas S/ 100 en una cuenta que paga 10 % de interés anual y no retiras dinero, ¿cuánto tendrás aproximadamente después de un año?',
    options: ['S/ 100', 'S/ 105', 'S/ 110', 'S/ 120'],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'S/ 100'),
      SurveyOption(id: 'B', text: 'S/ 105'),
      SurveyOption(id: 'C', text: 'S/ 110'),
      SurveyOption(id: 'D', text: 'S/ 120'),
    ],
  ),
  SurveyQuestion(
    id: 'Q6',
    order: 6,
    domain: 'INFLACION',
    text:
        'Si tus ingresos se mantienen iguales pero los precios aumentan debido a la inflación, ¿qué ocurre con tu poder adquisitivo?',
    options: [
      'Aumenta.',
      'Disminuye.',
      'Permanece necesariamente igual.',
      'Se duplica.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'Aumenta.'),
      SurveyOption(id: 'B', text: 'Disminuye.'),
      SurveyOption(id: 'C', text: 'Permanece necesariamente igual.'),
      SurveyOption(id: 'D', text: 'Se duplica.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q7',
    order: 7,
    domain: 'RIESGO',
    text: '¿Qué estrategia generalmente ayuda a reducir el riesgo al invertir?',
    options: [
      'Colocar todo el dinero en una sola inversión.',
      'Pedir dinero prestado para invertir más.',
      'Distribuir el dinero entre diferentes alternativas de inversión.',
      'Elegir únicamente la inversión que tuvo mayor rentabilidad el mes anterior.',
    ],
    parsedOptions: [
      SurveyOption(
        id: 'A',
        text: 'Colocar todo el dinero en una sola inversión.',
      ),
      SurveyOption(id: 'B', text: 'Pedir dinero prestado para invertir más.'),
      SurveyOption(
        id: 'C',
        text:
            'Distribuir el dinero entre diferentes alternativas de inversión.',
      ),
      SurveyOption(
        id: 'D',
        text:
            'Elegir únicamente la inversión que tuvo mayor rentabilidad el mes anterior.',
      ),
    ],
  ),
  SurveyQuestion(
    id: 'Q8',
    order: 8,
    domain: 'CREDITO',
    text:
        'Si deseas comparar dos préstamos similares, ¿qué indicador permite conocer mejor el costo total del crédito en Perú?',
    options: [
      'El monto de la primera cuota.',
      'La TCEA.',
      'El número de publicidad del banco.',
      'El límite disponible de la tarjeta.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'El monto de la primera cuota.'),
      SurveyOption(id: 'B', text: 'La TCEA.'),
      SurveyOption(id: 'C', text: 'El número de publicidad del banco.'),
      SurveyOption(id: 'D', text: 'El límite disponible de la tarjeta.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q9',
    order: 9,
    domain: 'CREDITO',
    text:
        '¿Qué puede ocurrir si una persona paga repetidamente sus créditos después de la fecha de vencimiento?',
    options: [
      'La deuda desaparece progresivamente.',
      'Puede generar intereses, penalidades y afectar su historial crediticio.',
      'El banco aumenta automáticamente sus ahorros.',
      'No ocurre nada mientras pague algún monto.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'La deuda desaparece progresivamente.'),
      SurveyOption(
        id: 'B',
        text:
            'Puede generar intereses, penalidades y afectar su historial crediticio.',
      ),
      SurveyOption(
        id: 'C',
        text: 'El banco aumenta automáticamente sus ahorros.',
      ),
      SurveyOption(id: 'D', text: 'No ocurre nada mientras pague algún monto.'),
    ],
  ),
  SurveyQuestion(
    id: 'Q10',
    order: 10,
    domain: 'CREDITO',
    text:
        'Antes de solicitar un préstamo, ¿qué debería evaluar principalmente una persona?',
    options: [
      'Solamente cuánto dinero le ofrecen.',
      'Sus ingresos, gastos, deudas existentes y capacidad para pagar las cuotas.',
      'Únicamente el número de cuotas.',
      'Si otras personas también solicitaron el mismo préstamo.',
    ],
    parsedOptions: [
      SurveyOption(id: 'A', text: 'Solamente cuánto dinero le ofrecen.'),
      SurveyOption(
        id: 'B',
        text:
            'Sus ingresos, gastos, deudas existentes y capacidad para pagar las cuotas.',
      ),
      SurveyOption(id: 'C', text: 'Únicamente el número de cuotas.'),
      SurveyOption(
        id: 'D',
        text: 'Si otras personas también solicitaron el mismo préstamo.',
      ),
    ],
  ),
  SurveyQuestion(
    id: 'Q11',
    order: 11,
    domain: 'SEGURIDAD_FINANCIERA',
    text:
        'Si recibes un mensaje que aparenta ser de una entidad financiera solicitando tu clave, CVV o código de verificación, ¿qué deberías hacer?',
    options: [
      'Compartir los datos si el mensaje parece urgente.',
      'Compartir únicamente el código de verificación.',
      'No compartirlos y verificar la comunicación mediante los canales oficiales.',
      'Responder solicitando más información personal del remitente.',
    ],
    parsedOptions: [
      SurveyOption(
        id: 'A',
        text: 'Compartir los datos si el mensaje parece urgente.',
      ),
      SurveyOption(
        id: 'B',
        text: 'Compartir únicamente el código de verificación.',
      ),
      SurveyOption(
        id: 'C',
        text:
            'No compartirlos y verificar la comunicación mediante los canales oficiales.',
      ),
      SurveyOption(
        id: 'D',
        text: 'Responder solicitando más información personal del remitente.',
      ),
    ],
  ),
  SurveyQuestion(
    id: 'Q12',
    order: 12,
    domain: 'AHORRO',
    text:
        '¿Cuál de las siguientes prácticas favorece mejor el cumplimiento de una meta de ahorro?',
    options: [
      'Ahorrar únicamente cuando sobra dinero de manera ocasional.',
      'Definir una meta, un monto y un plazo, y separar dinero periódicamente.',
      'Utilizar crédito cada vez que no alcance el dinero.',
      'Posponer indefinidamente el ahorro hasta tener mayores ingresos.',
    ],
    parsedOptions: [
      SurveyOption(
        id: 'A',
        text: 'Ahorrar únicamente cuando sobra dinero de manera ocasional.',
      ),
      SurveyOption(
        id: 'B',
        text:
            'Definir una meta, un monto y un plazo, y separar dinero periódicamente.',
      ),
      SurveyOption(
        id: 'C',
        text: 'Utilizar crédito cada vez que no alcance el dinero.',
      ),
      SurveyOption(
        id: 'D',
        text:
            'Posponer indefinidamente el ahorro hasta tener mayores ingresos.',
      ),
    ],
  ),
];

String _formatDomain(String? domain) {
  return switch (domain) {
    'PLANIFICACION' => 'Planificación',
    'AHORRO' => 'Ahorro',
    'CONOCIMIENTO_FINANCIERO' => 'Conocimiento Financiero',
    'INFLACION' => 'Inflación',
    'RIESGO' => 'Riesgo',
    'CREDITO' => 'Crédito',
    'SEGURIDAD_FINANCIERA' => 'Seguridad Financiera',
    _ => domain ?? 'Educación Financiera',
  };
}

/// [isPre] determines whether to render the initial pre-test (mandatory academic assessment)
/// or the post-test evaluation.
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
  bool _localConsentGiven = false;
  bool _initializedStatus = false;
  bool _resumePositioned = false;
  bool _completedSubmitted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // PopScope prevents skipping the mandatory pre-test.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBackAttempt();
        }
      },
      child: Scaffold(
        backgroundColor: colors.bg,
        appBar: ZendaAppBar(
          title: widget.isPre
              ? 'Evaluación Inicial'
              : context.l10n.surveyPostTitle,
          onLeadingPressed: _handleBackAttempt,
        ),
        body: widget.isPre ? _buildPreFlow() : _buildPostFlow(),
      ),
    );
  }

  void _handleBackAttempt() {
    if (widget.isPre) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Evaluación Indispensable'),
          content: const Text(
            'El pre-test de educación financiera es obligatorio para el estudio académico.\n\n'
            'Tus respuestas están guardadas automáticamente. Continúa para poder acceder a Zenda.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
              ),
              child: const Text('Continuar evaluación'),
            ),
          ],
        ),
      );
    } else {
      context.go('/dashboard');
    }
  }

  Widget _buildPreFlow() {
    if (_completedSubmitted) {
      return _PreCompletedView(onContinue: _navigateToNextScreen);
    }

    final statusAsync = ref.watch(_preStatusProvider);
    final surveyAsync = ref.watch(_preSurveyProvider);

    return statusAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) {
        // Fallback offline flow: show consent if needed, then fallback 12 questions
        return _buildPreWithQuestions(
          Survey(
            id: 'finlit-pre-v1',
            type: 'PRE',
            questionnaireVersion: 'FINLIT_PRE_V1',
            totalQuestions: 12,
            questions: _finlitFallbackQuestions,
          ),
          consentGiven: _localConsentGiven,
        );
      },
      data: (status) {
        if (status.isCompleted) {
          return _PreCompletedView(onContinue: _navigateToNextScreen);
        }

        if (!_initializedStatus) {
          _initializedStatus = true;
          _localConsentGiven = status.consentGiven;
          if (status.answeredQuestions.isNotEmpty) {
            _answers.addAll(status.answeredQuestions);
          }
        }

        return surveyAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, _) => _buildPreWithQuestions(
            Survey(
              id: 'finlit-pre-v1',
              type: 'PRE',
              questionnaireVersion: 'FINLIT_PRE_V1',
              totalQuestions: 12,
              questions: _finlitFallbackQuestions,
            ),
            consentGiven: _localConsentGiven,
          ),
          data: (survey) =>
              _buildPreWithQuestions(survey, consentGiven: _localConsentGiven),
        );
      },
    );
  }

  Widget _buildPreWithQuestions(Survey survey, {required bool consentGiven}) {
    if (!consentGiven) {
      return _InformedConsentView(
        onAccept: () async {
          try {
            await ref
                .read(surveysServiceProvider)
                .startPre(
                  consentGiven: true,
                  consentVersion: 'FINLIT_CONSENT_V1',
                );
          } catch (_) {
            // Continues even if network error occurs
          }
          if (mounted) {
            setState(() {
              _localConsentGiven = true;
            });
          }
        },
      );
    }

    final questions = survey.questions.isNotEmpty
        ? survey.questions
        : _finlitFallbackQuestions;

    // Resume only once. Re-running this during build made "Anterior" jump
    // forward again whenever question 1 already had an answer.
    if (!_resumePositioned) {
      _resumePositioned = true;
      final firstUnanswered = questions.indexWhere(
        (question) => !_answers.containsKey(question.id),
      );
      _currentIndex = firstUnanswered >= 0
          ? firstUnanswered
          : questions.length - 1;
    }

    final safeIndex = _currentIndex.clamp(0, questions.length - 1);
    if (_currentIndex != safeIndex) _currentIndex = safeIndex;
    final currentQuestion = questions[safeIndex];

    return _PreSurveyQuestionnaire(
      questions: questions,
      currentIndex: safeIndex,
      currentQuestion: currentQuestion,
      answers: _answers,
      submitting: _submitting,
      onAnswerSelected: (questionId, optionId) {
        setState(() {
          _answers[questionId] = optionId;
        });
        // Auto-save draft progress in background
        ref
            .read(surveysServiceProvider)
            .savePreProgress(_answers)
            .catchError((_) {});
      },
      onPrevious: () {
        if (_currentIndex > 0) {
          setState(() => _currentIndex -= 1);
        }
      },
      onNext: () {
        if (_currentIndex < questions.length - 1) {
          setState(() => _currentIndex += 1);
        }
      },
      onSubmit: () => _submitPre(questions),
      onJumpToQuestion: (index) {
        if (index >= 0 && index < questions.length) {
          setState(() => _currentIndex = index);
        }
      },
    );
  }

  Future<void> _submitPre(List<SurveyQuestion> questions) async {
    final answeredQuestionIds = questions
        .where((question) => _answers.containsKey(question.id))
        .length;
    if (answeredQuestionIds != questions.length) {
      showAppToast(
        context,
        'Debes responder todas las preguntas ($answeredQuestionIds/${questions.length}) antes de finalizar.',
        type: ToastType.warning,
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ref.read(surveysServiceProvider).submitPre(_answers);
      await ref.read(preSurveyProvider.notifier).markCompleted();
      if (mounted) {
        setState(() {
          _completedSubmitted = true;
        });
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 409) {
        // Already completed
        await ref.read(preSurveyProvider.notifier).markCompleted();
        if (mounted) {
          setState(() {
            _completedSubmitted = true;
          });
        }
        return;
      }

      // Offline resilience
      final userId = ref.read(authNotifierProvider).user?.id;
      if (userId != null && (e is! ApiException || e.statusCode >= 500)) {
        await PendingSurveyQueue.save(
          userId: userId,
          type: 'PRE',
          answers: _answers,
        );
        await ref
            .read(preSurveyProvider.notifier)
            .markCompleted(confirmedByServer: false);
        if (mounted) {
          showAppToast(
            context,
            'Respuestas guardadas localmente. Se sincronizarán al conectarse.',
            type: ToastType.info,
          );
          setState(() {
            _completedSubmitted = true;
          });
        }
        return;
      }

      final message = e is ApiException
          ? 'Error al enviar: ${e.message}'
          : 'No se pudo enviar la evaluación. Intenta nuevamente.';
      if (mounted) {
        showAppToast(context, message, type: ToastType.error);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _navigateToNextScreen() {
    final user = ref.read(authNotifierProvider).user;
    if (user != null && !user.profileCompleted) {
      context.go('/profile-setup');
    } else {
      context.go('/dashboard');
    }
  }

  // ── Post Flow (Legacy compatible) ──────────────────────────────────────────

  Widget _buildPostFlow() {
    final surveyAsync = ref.watch(_postSurveyProvider);
    return surveyAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se pudo cargar la evaluación.'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/dashboard'),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
      data: (survey) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 64,
                  color: Color(0xFF10B981),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Post-Test de Educación Financiera',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta evaluación se habilitará al término de la fase de intervención.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/dashboard'),
                  child: const Text('Ir al inicio'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Informed Consent View ────────────────────────────────────────────────────

class _InformedConsentView extends StatefulWidget {
  const _InformedConsentView({required this.onAccept});
  final VoidCallback onAccept;

  @override
  State<_InformedConsentView> createState() => _InformedConsentViewState();
}

class _InformedConsentViewState extends State<_InformedConsentView> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                size: 36,
                color: Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Consentimiento Informado',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Investigación Académica · Proyecto Zenda',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBulletPoint(
                  colors,
                  'Finalidad Científica',
                  'El presente cuestionario forma parte de una investigación académica sobre educación financiera y toma de decisiones económicas en estudiantes universitarios.',
                ),
                const SizedBox(height: 16),
                _buildBulletPoint(
                  colors,
                  'Confidencialidad Estricta',
                  'Tus respuestas serán tratadas de manera estrictamente confidencial y se utilizarán únicamente con fines científicos y de mejora de la aplicación.',
                ),
                const SizedBox(height: 16),
                _buildBulletPoint(
                  colors,
                  'Tratamiento Seudónimo',
                  'La información se procesa de forma seudónima, sin asociar directamente tu identidad personal (nombre, correo o DNI) a los resultados obtenidos.',
                ),
                const SizedBox(height: 16),
                _buildBulletPoint(
                  colors,
                  'Carácter Indispensable',
                  'Completar la evaluación inicial es indispensable para el desarrollo del estudio. Te pedimos responder con sinceridad.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => setState(() => _accepted = !_accepted),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Checkbox(
                  value: _accepted,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) => setState(() => _accepted = val ?? false),
                ),
                Expanded(
                  child: Text(
                    'He leído la información y acepto participar en la evaluación.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _accepted ? widget.onAccept : null,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                disabledBackgroundColor: colors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Comenzar evaluación',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(
    ZendaColors colors,
    String title,
    String description,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 10),
          child: Icon(
            Icons.check_circle_rounded,
            size: 18,
            color: Color(0xFF10B981),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Pre-Survey Questionnaire ──────────────────────────────────────────────────

class _PreSurveyQuestionnaire extends StatelessWidget {
  const _PreSurveyQuestionnaire({
    required this.questions,
    required this.currentIndex,
    required this.currentQuestion,
    required this.answers,
    required this.submitting,
    required this.onAnswerSelected,
    required this.onPrevious,
    required this.onNext,
    required this.onSubmit,
    required this.onJumpToQuestion,
  });

  final List<SurveyQuestion> questions;
  final int currentIndex;
  final SurveyQuestion currentQuestion;
  final Map<String, String> answers;
  final bool submitting;
  final void Function(String questionId, String optionId) onAnswerSelected;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onSubmit;
  final ValueChanged<int> onJumpToQuestion;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final total = questions.length;
    final progress = (currentIndex + 1) / total;
    final selectedOptionId = answers[currentQuestion.id];
    final answeredCount = questions
        .where((question) => answers.containsKey(question.id))
        .length;
    final allAnswered = answeredCount == total;
    final isLastQuestion = currentIndex == total - 1;

    // Use structured parsedOptions if available, otherwise build from options
    final options = currentQuestion.parsedOptions.isNotEmpty
        ? currentQuestion.parsedOptions
        : List.generate(
            currentQuestion.options.length,
            (i) => SurveyOption(
              id: String.fromCharCode(65 + i),
              text: currentQuestion.options[i],
            ),
          );

    return SafeArea(
      child: Column(
        children: [
          // Header with question number and linear progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${currentIndex + 1} de $total',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatDomain(currentQuestion.domain),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: colors.fill,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF10B981),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                // Indicator dots / chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(total, (i) {
                      final qId = questions[i].id;
                      final isAnswered = answers.containsKey(qId);
                      final isCurrent = i == currentIndex;
                      return GestureDetector(
                        onTap: () => onJumpToQuestion(i),
                        child: Container(
                          width: 22,
                          height: 22,
                          margin: const EdgeInsets.only(right: 6, top: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCurrent
                                ? const Color(0xFF10B981)
                                : isAnswered
                                ? const Color(
                                    0xFF10B981,
                                  ).withValues(alpha: 0.25)
                                : colors.fill,
                            border: Border.all(
                              color: isCurrent
                                  ? const Color(0xFF10B981)
                                  : isAnswered
                                  ? const Color(0xFF10B981)
                                  : colors.border,
                              width: 1.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isCurrent
                                    ? Colors.white
                                    : colors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 16),
          // Question card and options
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentQuestion.text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ...options.map((opt) {
                    final isSelected = selectedOptionId == opt.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () =>
                            onAnswerSelected(currentQuestion.id, opt.id),
                        borderRadius: BorderRadius.circular(14),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : colors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : colors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? const Color(0xFF10B981)
                                      : colors.fill,
                                ),
                                child: Center(
                                  child: Text(
                                    opt.id,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: isSelected
                                          ? Colors.white
                                          : colors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  opt.text,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.3,
                                    color: colors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Navigation Footer
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(top: BorderSide(color: colors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!allAnswered && isLastQuestion) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'Faltan responder ${total - answeredCount} de $total preguntas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                Row(
                  children: [
                    if (currentIndex > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onPrevious,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Anterior'),
                        ),
                      ),
                    if (currentIndex > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: isLastQuestion
                          ? FilledButton(
                              onPressed: (allAnswered && !submitting)
                                  ? onSubmit
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                disabledBackgroundColor: colors.border,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Finalizar evaluación',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                            )
                          : FilledButton(
                              onPressed: selectedOptionId != null
                                  ? onNext
                                  : null,
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Siguiente',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Completed View (Neutral Academic Confirmation) ───────────────────────────

class _PreCompletedView extends StatelessWidget {
  const _PreCompletedView({required this.onContinue});
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 54,
                color: Color(0xFF10B981),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Evaluación inicial completada',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Gracias por participar. Tus respuestas han sido registradas de forma segura y seudónima para la investigación académica.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.textMuted,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    colors,
                    'Instrumento:',
                    'Pre-test (FINLIT_PRE_V1)',
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    colors,
                    'Preguntas respondidas:',
                    '12 de 12',
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    colors,
                    'Estado del registro:',
                    'Completado y bloqueado',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Continuar a Zenda',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(ZendaColors colors, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: colors.textMuted)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }
}
