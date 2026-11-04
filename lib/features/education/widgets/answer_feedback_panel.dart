import 'package:flutter/material.dart';

import '../../../core/models/quiz_models.dart';
import '../../../l10n/l10n_extension.dart';

/// Right/wrong verdict for the answer just given, plus the concept
/// explanation. Falls back to a neutral note when grading was unavailable.
class AnswerFeedbackPanel extends StatelessWidget {
  const AnswerFeedbackPanel({
    super.key,
    required this.feedback,
    this.explanation,
  });

  final QuizFeedback? feedback;
  final String? explanation;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final fb = feedback;
    final correct = fb?.correct ?? true;
    final accent = correct ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final textColor = correct
        ? const Color(0xFF065F46)
        : const Color(0xFF991B1B);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: accent,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (fb != null)
                  Text(
                    correct ? l10n.quizCorrect : l10n.quizIncorrect,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                if (fb != null && !correct) ...[
                  const SizedBox(height: 4),
                  Text(
                    l10n.quizCorrectAnswerIs(fb.correctAnswer),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  explanation ?? l10n.quizAnswerRecorded,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
