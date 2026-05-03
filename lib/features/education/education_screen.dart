import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../l10n/l10n_extension.dart';


final educationServiceProvider = Provider<EducationApiService>(
  (_) => EducationApiService(),
);

final _topicsProvider =
    FutureProvider.autoDispose<List<EducationTopic>>((ref) {
  return ref.read(educationServiceProvider).listTopics();
});

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key});

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _filter = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EducationTopic> _applyFilters(List<EducationTopic> topics) {
    var result = topics;
    if (_query.isNotEmpty) {
      result = result
          .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_filter != 'all') {
      result = result.where((t) => t.difficulty.toLowerCase() == _filter).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topicsAsync = ref.watch(_topicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.educationTitle),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: UserMenuButton(),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNav(activeIndex: 4),
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
          final filtered = _applyFilters(topics);
          final featured = filtered.firstOrNull;
          final rest = filtered.length > 1 ? filtered.sublist(1) : <EducationTopic>[];

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
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: l10n.educationSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _query = '');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterChips(
                    selected: _filter,
                    onSelect: (v) => setState(() => _filter = v),
                  ),
                ),
                if (featured != null) ...[
                  SliverToBoxAdapter(
                    child: _FeaturedCard(
                      topic: featured,
                      onTap: () => context.push('/education/${featured.id}'),
                    ),
                  ),
                  SliverList.builder(
                    itemCount: rest.length,
                    itemBuilder: (context, index) => _TopicTile(
                      topic: rest[index],
                      isRecommended: false,
                      onTap: () => context.push('/education/${rest[index].id}'),
                    ),
                  ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Center(child: Text(l10n.educationErrorLoad)),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              l10n.educationPersonalized,
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
                          l10n.educationPersonalizedSubtitle,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                context.push('/education/quiz/personalized'),
                            icon: const Icon(Icons.auto_awesome, size: 18),
                            label: Text(l10n.quizPersonalizedButton),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF818CF8),
                              side:
                                  const BorderSide(color: Color(0xFF818CF8)),
                            ),
                          ),
                        ),
                      ],
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelect});
  final String selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = {
      'all': l10n.educationFilterAll,
      'beginner': l10n.educationFilterBeginner,
      'intermediate': l10n.educationFilterIntermediate,
      'advanced': l10n.educationFilterAdvanced,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: chips.entries.map((e) {
          final isSelected = selected == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(e.value),
              selected: isSelected,
              onSelected: (_) => onSelect(e.key),
              selectedColor: const Color(0xFF34D399).withValues(alpha: 0.2),
              checkmarkColor: const Color(0xFF10B981),
              labelStyle: TextStyle(
                color: isSelected ? const Color(0xFF065F46) : null,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.topic, required this.onTap});
  final EducationTopic topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.educationFeaturedLabel,
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                if (topic.isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF34D399), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              topic.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF34D399),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(l10n.educationStartLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
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
  const _TopicTile({
    required this.topic,
    required this.onTap,
    this.isRecommended = false,
  });
  final EducationTopic topic;
  final VoidCallback onTap;
  final bool isRecommended;

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
      title: Row(
        children: [
          Expanded(child: Text(topic.title)),
          if (isRecommended) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                context.l10n.educationRecommended,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF818CF8),
                ),
              ),
            ),
          ],
        ],
      ),
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
