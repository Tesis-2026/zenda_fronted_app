import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';

final _topicDetailProvider =
    FutureProvider.autoDispose.family<EducationTopic, String>((ref, id) {
  return ref.read(educationServiceProvider).getTopic(id);
});

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final topicAsync = ref.watch(_topicDetailProvider(topicId));

    return topicAsync.when(
      loading: () => const Scaffold(
        backgroundColor: Color(0xFF1F2937),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF34D399)),
        ),
      ),
      error: (_, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.educationErrorLoad)),
      ),
      data: (topic) => Scaffold(
        body: _TopicDetailBody(
          topic: topic,
          onComplete: () async {
            await ref.read(educationServiceProvider).completeTopic(topic.id);
            ref.invalidate(_topicDetailProvider(topicId));
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.educationTopicCompleted)),
              );
            }
          },
        ),
      ),
    );
  }
}

class _TopicDetailBody extends StatelessWidget {
  const _TopicDetailBody({required this.topic, required this.onComplete});
  final EducationTopic topic;
  final Future<void> Function() onComplete;

  Color _categoryColor() {
    switch (topic.category.toLowerCase()) {
      case 'budgeting':
        return const Color(0xFF34D399);
      case 'saving':
        return const Color(0xFF60A5FA);
      case 'investing':
        return const Color(0xFF818CF8);
      default:
        return const Color(0xFF9CA3AF);
    }
  }

  Color _difficultyColor() {
    switch (topic.difficulty.toUpperCase()) {
      case 'BEGINNER':
        return const Color(0xFF43A047);
      case 'INTERMEDIATE':
        return const Color(0xFFFB8C00);
      case 'ADVANCED':
        return const Color(0xFFE53935);
      default:
        return const Color(0xFF757575);
    }
  }

  String _categoryLabel(BuildContext context) {
    final l10n = context.l10n;
    switch (topic.category.toLowerCase()) {
      case 'budgeting':
        return l10n.educationFilterBudgeting;
      case 'saving':
        return l10n.educationFilterSaving;
      case 'investing':
        return l10n.educationFilterInvesting;
      default:
        return topic.category.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final catColor = _categoryColor();
    final diffColor = _difficultyColor();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 210,
          pinned: true,
          backgroundColor: const Color(0xFF1F2937),
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _categoryLabel(context).toUpperCase(),
                        style: TextStyle(
                          color: catColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      topic.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        _MetaBadge(
                          label: topic.difficulty.toUpperCase(),
                          accentColor: diffColor,
                        ),
                        const SizedBox(width: 8),
                        _MetaBadge(
                          label: l10n.educationMinRead(
                              topic.readingTimeMinutes),
                          accentColor:
                              Colors.white.withValues(alpha: 0.55),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Thin reading progress bar
        SliverToBoxAdapter(
          child: LinearProgressIndicator(
            value: topic.isCompleted ? 1.0 : 0.0,
            minHeight: 3,
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF34D399)),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text(
              topic.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.75,
                    fontSize: 15,
                    color: const Color(0xFF374151),
                  ),
            ),
          ),
        ),
        // CTAs
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            child: Column(
              children: [
                if (!topic.isCompleted)
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check_rounded, size: 18),
                      label: Text(l10n.educationMarkComplete),
                      onPressed: onComplete,
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34D399)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: Color(0xFF34D399), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          l10n.educationTopicCompleted,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon:
                        const Icon(Icons.quiz_outlined, size: 18),
                    label: Text(l10n.educationTakeQuiz),
                    onPressed: () =>
                        context.push('/education/${topic.id}/quiz'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F2937),
                      padding:
                          const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label, required this.accentColor});
  final String label;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
