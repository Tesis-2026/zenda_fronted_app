import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zenda_fronted/core/services/education_api_service.dart';
import 'package:zenda_fronted/core/services/pending_survey_queue.dart';
import 'package:zenda_fronted/features/surveys/survey_screen.dart';
import 'package:zenda_fronted/l10n/app_localizations.dart';
import 'package:zenda_fronted/providers/pre_survey_provider.dart';

class _SurveyApiFake extends SurveysApiService {
  _SurveyApiFake({required this.status, required this.survey});

  final FinancialLiteracyStatus status;
  final Survey survey;
  final List<Map<String, String>> savedAnswers = [];

  @override
  Future<FinancialLiteracyStatus> getPreStatus() async => status;

  @override
  Future<Survey> getPreSurvey() async => survey;

  @override
  Future<void> savePreProgress(Map<String, String> answers) async {
    savedAnswers.add(Map.of(answers));
  }
}

Survey _surveyWith12Questions() => Survey(
  id: 'finlit-pre-v1',
  type: 'PRE',
  totalQuestions: 12,
  questions: List.generate(
    12,
    (index) => SurveyQuestion(
      id: 'Q${index + 1}',
      order: index + 1,
      domain: 'PLANIFICACION',
      text: 'Pregunta ${index + 1}',
      options: const ['Opción A', 'Opción B'],
      parsedOptions: const [
        SurveyOption(id: 'A', text: 'Opción A'),
        SurveyOption(id: 'B', text: 'Opción B'),
      ],
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Financial Literacy Pre-Test Frontend Models & Integrity', () {
    test(
      'SurveyOption and SurveyQuestion parse structured JSON options correctly',
      () {
        final json = {
          'questionId': 'Q1',
          'order': 1,
          'domain': 'PLANIFICACION',
          'questionText':
              '¿Cuál es la principal finalidad de elaborar un presupuesto personal?',
          'options': [
            {'id': 'A', 'text': 'Registrar únicamente las deudas.'},
            {'id': 'B', 'text': 'Planificar y controlar ingresos y gastos.'},
            {'id': 'C', 'text': 'Aumentar automáticamente los ingresos.'},
            {'id': 'D', 'text': 'Evitar utilizar productos financieros.'},
          ],
        };

        final q = SurveyQuestion.fromJson(json);
        expect(q.id, 'Q1');
        expect(q.order, 1);
        expect(q.domain, 'PLANIFICACION');
        expect(
          q.text,
          '¿Cuál es la principal finalidad de elaborar un presupuesto personal?',
        );
        expect(q.options.length, 4);
        expect(q.parsedOptions.length, 4);
        expect(q.parsedOptions[0].id, 'A');
        expect(q.parsedOptions[0].text, 'Registrar únicamente las deudas.');
        expect(q.parsedOptions[1].id, 'B');
        expect(
          q.parsedOptions[1].text,
          'Planificar y controlar ingresos y gastos.',
        );
      },
    );

    test(
      'SurveyQuestion remains backwards-compatible with simple string options',
      () {
        final json = {
          'id': 'legacy-1',
          'order': 1,
          'text': '¿Pregunta antigua?',
          'options': ['Opción 1', 'Opción 2', 'Opción 3'],
        };

        final q = SurveyQuestion.fromJson(json);
        expect(q.id, 'legacy-1');
        expect(q.options, ['Opción 1', 'Opción 2', 'Opción 3']);
        expect(q.parsedOptions.length, 3);
        expect(q.parsedOptions[0].id, 'A');
        expect(q.parsedOptions[0].text, 'Opción 1');
        expect(q.parsedOptions[1].id, 'B');
        expect(q.parsedOptions[1].text, 'Opción 2');
      },
    );

    test(
      'FinancialLiteracyStatus correctly reflects NOT_STARTED, IN_PROGRESS, and COMPLETED',
      () {
        final notStartedJson = {
          'assessmentType': 'PRE',
          'questionnaireVersion': 'FINLIT_PRE_V1',
          'status': 'NOT_STARTED',
          'consentGiven': false,
          'consentVersion': null,
          'startedAt': null,
          'completedAt': null,
          'answeredQuestions': {},
          'totalAnswered': 0,
          'totalQuestions': 12,
          'consentText': 'Texto de consentimiento',
        };

        final notStarted = FinancialLiteracyStatus.fromJson(notStartedJson);
        expect(notStarted.isNotStarted, isTrue);
        expect(notStarted.isInProgress, isFalse);
        expect(notStarted.isCompleted, isFalse);
        expect(notStarted.consentGiven, isFalse);
        expect(notStarted.totalAnswered, 0);

        final inProgressJson = {
          'assessmentType': 'PRE',
          'questionnaireVersion': 'FINLIT_PRE_V1',
          'status': 'IN_PROGRESS',
          'consentGiven': true,
          'consentVersion': 'FINLIT_CONSENT_V1',
          'startedAt': '2026-09-22T10:00:00.000Z',
          'completedAt': null,
          'answeredQuestions': {'Q1': 'B', 'Q2': 'B'},
          'totalAnswered': 2,
          'totalQuestions': 12,
        };

        final inProgress = FinancialLiteracyStatus.fromJson(inProgressJson);
        expect(inProgress.isNotStarted, isFalse);
        expect(inProgress.isInProgress, isTrue);
        expect(inProgress.isCompleted, isFalse);
        expect(inProgress.consentGiven, isTrue);
        expect(inProgress.answeredQuestions['Q1'], 'B');
        expect(inProgress.totalAnswered, 2);

        final completedJson = {
          'assessmentType': 'PRE',
          'questionnaireVersion': 'FINLIT_PRE_V1',
          'status': 'COMPLETED',
          'consentGiven': true,
          'consentVersion': 'FINLIT_CONSENT_V1',
          'startedAt': '2026-09-22T10:00:00.000Z',
          'completedAt': '2026-09-22T10:05:00.000Z',
          'answeredQuestions': {},
          'totalAnswered': 12,
          'totalQuestions': 12,
        };

        final completed = FinancialLiteracyStatus.fromJson(completedJson);
        expect(completed.isCompleted, isTrue);
        expect(completed.totalAnswered, 12);
      },
    );

    test(
      'SurveyResult deserializes submit response without leaking score or answer keys',
      () {
        final submitResponse = {
          'completed': true,
          'message': 'Evaluación inicial completada. Gracias por participar.',
          'assessmentType': 'PRE',
          'questionnaireVersion': 'FINLIT_PRE_V1',
          'completedAt': '2026-09-22T10:05:00.000Z',
        };

        final result = SurveyResult.fromJson(submitResponse);
        expect(result.completed, isTrue);
        expect(result.message, contains('Evaluación inicial completada'));
        expect(result.score, 0.0);
        expect(result.level, isNull);
      },
    );

    test('draft and final submission send answers as an object', () async {
      FlutterSecureStorage.setMockInitialValues({
        'zenda.access_token': 'test-access-token',
        'zenda.refresh_token': 'test-refresh-token',
      });
      final sentBodies = <Map<String, dynamic>>[];
      final client = MockClient((request) async {
        sentBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
        if (request.method == 'POST') {
          return http.Response(
            jsonEncode({'completed': true, 'message': 'Completada'}),
            201,
          );
        }
        return http.Response('{}', 200);
      });

      await http.runWithClient(() async {
        const answers = {'Q1': 'B', 'Q2': 'A'};
        final service = SurveysApiService();
        await service.savePreProgress(answers);
        await service.submitPre(answers);
      }, () => client);

      expect(sentBodies, hasLength(2));
      expect(sentBodies[0]['answers'], {'Q1': 'B', 'Q2': 'A'});
      expect(sentBodies[1]['answers'], {'Q1': 'B', 'Q2': 'A'});
      expect(sentBodies.every((body) => body['answers'] is Map), isTrue);
    });

    test(
      'completion and pending submission survive restart per user',
      () async {
        SharedPreferences.setMockInitialValues({});

        await PreSurveyCompletionStore.markConfirmed('user-a');
        await PendingSurveyQueue.save(
          userId: 'user-b',
          type: 'PRE',
          answers: const {'Q1': 'B'},
        );

        expect(await PreSurveyCompletionStore.isConfirmed('user-a'), isTrue);
        expect(await PreSurveyCompletionStore.isConfirmed('user-b'), isFalse);
        expect(
          await PendingSurveyQueue.hasPending(userId: 'user-b', type: 'PRE'),
          isTrue,
        );
        expect(
          await PendingSurveyQueue.hasPending(userId: 'user-a', type: 'PRE'),
          isFalse,
        );
      },
    );

    testWidgets('Siguiente advances and Anterior returns without skipping', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(738, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final fake = _SurveyApiFake(
        status: const FinancialLiteracyStatus(
          assessmentType: 'PRE',
          questionnaireVersion: 'FINLIT_PRE_V1',
          status: 'IN_PROGRESS',
          consentGiven: true,
          answeredQuestions: {'Q1': 'B'},
          totalAnswered: 1,
          totalQuestions: 12,
        ),
        survey: _surveyWith12Questions(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [surveysServiceProvider.overrideWithValue(fake)],
          child: const MaterialApp(
            locale: Locale('es'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SurveyScreen(isPre: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pregunta 2 de 12'), findsOneWidget);
      await tester.tap(find.text('Anterior'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 1 de 12'), findsOneWidget);

      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 2 de 12'), findsOneWidget);
      expect(find.textContaining('Pregunta -'), findsNothing);

      await tester.tap(find.text('Opción A').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Siguiente'));
      await tester.pumpAndSettle();
      expect(find.text('Pregunta 3 de 12'), findsOneWidget);
      expect(fake.savedAnswers.last['Q2'], 'A');
    });
  });
}
