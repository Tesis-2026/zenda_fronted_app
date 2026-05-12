import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import '../../providers/pre_survey_provider.dart';

final surveysServiceProvider = Provider<SurveysApiService>(
  (_) => SurveysApiService(),
);

final _preSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref.read(surveysServiceProvider).getPreSurvey();
});

final _postSurveyProvider = FutureProvider.autoDispose<Survey>((ref) {
  return ref.read(surveysServiceProvider).getPostSurvey();
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
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(
        title: widget.isPre ? l10n.surveyPreTitle : l10n.surveyPostTitle,
        actions: [
          TextButton(
            onPressed: () => context.go('/dashboard'),
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
                text: 'What percentage of your income should you save each month according to the 50/30/20 rule?',
                options: ['10%', '20%', '30%', '50%'],
              ),
              SurveyQuestion(
                id: 'fl-2',
                order: 2,
                text: 'What is compound interest?',
                options: [
                  'Interest on principal only',
                  'Interest on principal + accumulated interest',
                  'A fixed monthly fee',
                  'A type of investment fund',
                ],
              ),
              SurveyQuestion(
                id: 'fl-3',
                order: 3,
                text: 'What is an emergency fund?',
                options: [
                  'Money for vacations',
                  '3-6 months of expenses saved',
                  'A retirement account',
                  'A credit card limit',
                ],
              ),
              SurveyQuestion(
                id: 'fl-4',
                order: 4,
                text: "Which of these is a 'Need' in the 50/30/20 rule?",
                options: [
                  'Streaming services',
                  'Restaurant dinners',
                  'Rent and utilities',
                  'New clothing',
                ],
              ),
              SurveyQuestion(
                id: 'fl-5',
                order: 5,
                text: 'What does APR stand for?',
                options: [
                  'Annual Percentage Rate',
                  'Average Payment Return',
                  'Asset Price Ratio',
                  'Annual Premium Rate',
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
            onSubmit: () => _submit(fallbackSurvey),
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
    );
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
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
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
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : Text(l10n.surveySubmitButton),
                  )
                : FilledButton(
                    onPressed: hasAnswer ? onNext : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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
        const Icon(Icons.monetization_on_outlined,
            size: 40, color: Color(0xFF9CA3AF)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF34D399)
                    : Colors.white,
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
                      color: isSelected
                          ? Colors.white
                          : Colors.transparent,
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
          const Icon(Icons.celebration_rounded, size: 64, color: Color(0xFF34D399)),
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF34D399).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.military_tech_rounded,
                      size: 16, color: Color(0xFF10B981)),
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
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('${l10n.surveyResultContinue} →'),
            ),
          ),
        ],
      ),
    );
  }
}
