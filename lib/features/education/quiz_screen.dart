import 'package:flutter/material.dart';
import '../../l10n/l10n_extension.dart';

// Quiz screen stub — shown when a topic has an associated quiz.
// Full implementation pending quiz endpoints from the backend (US-1004).
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key, required this.topicId});

  final String topicId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.quizTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_outlined,
                size: 72,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 24),
              Text(
                l10n.quizEmpty,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
