import 'package:flutter_test/flutter_test.dart';
import 'package:zenda_fronted/core/services/education_api_service.dart';

void main() {
  group('Financial Literacy Pre-Test Frontend Models & Integrity', () {
    test('SurveyOption and SurveyQuestion parse structured JSON options correctly', () {
      final json = {
        'questionId': 'Q1',
        'order': 1,
        'domain': 'PLANIFICACION',
        'questionText': '¿Cuál es la principal finalidad de elaborar un presupuesto personal?',
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
      expect(q.text, '¿Cuál es la principal finalidad de elaborar un presupuesto personal?');
      expect(q.options.length, 4);
      expect(q.parsedOptions.length, 4);
      expect(q.parsedOptions[0].id, 'A');
      expect(q.parsedOptions[0].text, 'Registrar únicamente las deudas.');
      expect(q.parsedOptions[1].id, 'B');
      expect(q.parsedOptions[1].text, 'Planificar y controlar ingresos y gastos.');
    });

    test('SurveyQuestion remains backwards-compatible with simple string options', () {
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
    });

    test('FinancialLiteracyStatus correctly reflects NOT_STARTED, IN_PROGRESS, and COMPLETED', () {
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
    });

    test('SurveyResult deserializes submit response without leaking score or answer keys', () {
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
    });
  });
}
