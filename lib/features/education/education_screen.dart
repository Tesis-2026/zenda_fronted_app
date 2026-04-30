import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../l10n/l10n_extension.dart';

final _educationServiceProvider = Provider<EducationApiService>(
  (_) => EducationApiService(),
);

final _topicsProvider =
    FutureProvider.autoDispose<List<EducationTopic>>((ref) {
  return ref.read(_educationServiceProvider).listTopics();
});

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final topicsAsync = ref.watch(_topicsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.educationTitle)),
      body: topicsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.educationErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_topicsProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (topics) {
          final completed = topics.where((t) => t.isCompleted).length;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_topicsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _ProgressHeader(
                    completed: completed,
                    total: topics.length,
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              context.l10n.educationPersonalized,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(width: 6),
                            const Text('✨', style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.educationPersonalizedSubtitle,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.outline,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList.builder(
                  itemCount: topics.length,
                  itemBuilder: (context, index) => _TopicTile(
                    topic: topics[index],
                    onTap: () => context.push(
                      '/education/${topics[index].id}',
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.completed, required this.total});
  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final progress = total == 0 ? 0.0 : completed / total;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.educationProgressLabel(completed, total),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.topic, required this.onTap});
  final EducationTopic topic;
  final VoidCallback onTap;

  Color _difficultyColor(String difficulty) {
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
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: topic.isCompleted
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Icon(
          topic.isCompleted ? Icons.check : Icons.menu_book_outlined,
          color: topic.isCompleted
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20,
        ),
      ),
      title: Text(topic.title),
      subtitle: Chip(
        label: Text(topic.difficulty),
        backgroundColor: _difficultyColor(topic.difficulty).withValues(alpha: 0.12),
        labelStyle: TextStyle(
          color: _difficultyColor(topic.difficulty),
          fontSize: 11,
        ),
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
