import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/education_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _educationServiceProvider = Provider<EducationApiService>(
  (_) => EducationApiService(),
);

final _topicDetailProvider =
    FutureProvider.autoDispose.family<EducationTopic, String>((ref, id) {
  return ref.read(_educationServiceProvider).getTopic(id);
});

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final topicAsync = ref.watch(_topicDetailProvider(topicId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.educationTopicDetailTitle)),
      body: topicAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(child: Text(l10n.educationErrorLoad)),
        data: (topic) => _TopicContent(
          topic: topic,
          onComplete: () async {
            await ref
                .read(_educationServiceProvider)
                .completeTopic(topic.id);
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

class _TopicContent extends StatelessWidget {
  const _TopicContent({required this.topic, required this.onComplete});
  final EducationTopic topic;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topic.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _DifficultyBadge(difficulty: topic.difficulty),
          const SizedBox(height: 20),
          Text(
            topic.content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
          ),
          const SizedBox(height: 32),
          if (topic.isCompleted)
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.educationTopicCompleted,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l10n.educationMarkComplete),
                onPressed: onComplete,
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  const _DifficultyBadge({required this.difficulty});
  final String difficulty;

  Color _color() {
    switch (difficulty.toUpperCase()) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color().withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: _color(),
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
