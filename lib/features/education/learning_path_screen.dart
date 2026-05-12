import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';

// ── Demo: AI-prioritised order + reasons ─────────────────────────────────────
// Based on demo user (Paolo, May 2026):
//   • No savings recorded this month
//   • Food budget at 77%, Health at 80%
//   • Emergency Fund goal at 28% (S/ 850 of S/ 3 000)
//   • Has Visa Credit card with S/ 1 150 available

class _PathStep {
  final String topicId;
  final String reason;
  const _PathStep(this.topicId, this.reason);
}

const _demoPath = [
  _PathStep(
    'topic-3',
    'No savings recorded in May — building an emergency fund is your highest priority right now.',
  ),
  _PathStep(
    'topic-2',
    'Food is at 77% and Health at 80% of their budgets. Better planning keeps you on track.',
  ),
  _PathStep(
    'topic-4',
    'Automating a small transfer on payday removes willpower from the equation.',
  ),
  _PathStep(
    'topic-1',
    'Review: 58% of your spending goes to Needs this month, above the 50% target.',
  ),
  _PathStep(
    'topic-5',
    'You have a Visa Credit card — understanding interest will save you money every month.',
  ),
  _PathStep(
    'topic-6',
    'Once your emergency fund reaches S/ 3 000, investing is your natural next milestone.',
  ),
];

// ── Provider ─────────────────────────────────────────────────────────────────

final learningPathProvider =
    FutureProvider.autoDispose<List<EducationTopic>>((ref) async {
  final topics = await ref.read(educationServiceProvider).listTopics();
  final result = <EducationTopic>[];
  for (final step in _demoPath) {
    final match = topics.where((t) => t.id == step.topicId);
    if (match.isNotEmpty) result.add(match.first);
  }
  return result;
});

// ── Screen ────────────────────────────────────────────────────────────────────

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pathAsync = ref.watch(learningPathProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: ZendaAppBar(title: l10n.learningPathTitle),
      body: pathAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => const Center(child: Text('Could not load learning path')),
        data: (topics) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _AiBanner(),
            const SizedBox(height: 20),
            ...topics.asMap().entries.map(
                  (e) => _PathCard(
                    index: e.key,
                    topic: e.value,
                    reason: _demoPath[e.key].reason,
                    onTap: () => context.push('/education/${e.value.id}'),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _AiBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF818CF8).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFF818CF8), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF818CF8).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'AI Personalized',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF818CF8),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Topics ordered by what will help you most this month.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Based on May spending — no savings yet, food at 77%, health at 80%.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF9CA3AF),
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

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.index,
    required this.topic,
    required this.reason,
    required this.onTap,
  });

  final int index;
  final EducationTopic topic;
  final String reason;
  final VoidCallback onTap;

  Color _diffColor(String d) => switch (d.toLowerCase()) {
        'beginner' => const Color(0xFF34D399),
        'intermediate' => const Color(0xFFF97316),
        _ => const Color(0xFFEF4444),
      };

  @override
  Widget build(BuildContext context) {
    final done = topic.isCompleted;
    final locked = topic.isLocked;

    return GestureDetector(
      onTap: locked ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: done
                ? const Color(0xFF34D399).withValues(alpha: 0.35)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Priority badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: done
                    ? const Color(0xFF34D399)
                    : locked
                        ? const Color(0xFFF3F4F6)
                        : const Color(0xFF34D399).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : locked
                      ? const Icon(Icons.lock_outline_rounded,
                          size: 13, color: Color(0xFF9CA3AF))
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF34D399),
                          ),
                        ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + difficulty
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: locked
                                ? const Color(0xFF9CA3AF)
                                : const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: _diffColor(topic.difficulty)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${topic.difficulty[0].toUpperCase()}${topic.difficulty.substring(1)}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _diffColor(topic.difficulty),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // AI reason
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.auto_awesome_rounded,
                            size: 11, color: Color(0xFF818CF8)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontStyle: FontStyle.italic,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (!locked) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        done ? 'Review →' : 'Start →',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
