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

final _topicsProvider = FutureProvider.autoDispose<List<EducationTopic>>((ref) {
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
      result = result.where((t) => t.category.toLowerCase() == _filter).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final topicsAsync = ref.watch(_topicsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.educationLearnGrow),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥', style: TextStyle(fontSize: 14)),
                SizedBox(width: 2),
                Text(
                  '12',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 8),
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
          final filtered = _applyFilters(topics);
          final featured = filtered.firstOrNull;
          final rest = filtered.length > 1 ? filtered.sublist(1) : <EducationTopic>[];

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_topicsProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: l10n.educationSearchHint,
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                              color: Color(0xFF34D399), width: 1.5),
                        ),
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
                  child: _CategoryFilterChips(
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
                    itemBuilder: (_, i) => _TopicCard(
                      topic: rest[i],
                      onTap: () => context.push('/education/${rest[i].id}'),
                    ),
                  ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          l10n.educationErrorLoad,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                SliverToBoxAdapter(
                  child: _PersonalizedSection(),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Category filter chips
// ─────────────────────────────────────────────────────────────────

class _CategoryFilterChips extends StatelessWidget {
  const _CategoryFilterChips(
      {required this.selected, required this.onSelect});
  final String selected;
  final void Function(String) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final chips = {
      'all': l10n.educationFilterAll,
      'budgeting': l10n.educationFilterBudgeting,
      'saving': l10n.educationFilterSaving,
      'investing': l10n.educationFilterInvesting,
    };
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: chips.entries.map((e) {
          final isSelected = selected == e.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF34D399)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Featured dark card
// ─────────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.topic, required this.onTap});
  final EducationTopic topic;
  final VoidCallback onTap;

  String _emoji(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return '💡';
      case 'saving':
        return '🐷';
      case 'investing':
        return '📈';
      default:
        return '📚';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final excerpt = topic.content.length > 100
        ? '${topic.content.substring(0, 100)}...'
        : topic.content;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2937),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n.educationFeaturedLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                if (topic.isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: Color(0xFF34D399), size: 18),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(_emoji(topic.category),
                        style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        excerpt,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.educationStartLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.educationMinRead(topic.readingTimeMinutes),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Topic card
// ─────────────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});
  final EducationTopic topic;
  final VoidCallback onTap;

  IconData _icon(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Icons.account_balance_wallet_outlined;
      case 'saving':
        return Icons.savings_outlined;
      case 'investing':
        return Icons.trending_up_rounded;
      default:
        return Icons.menu_book_outlined;
    }
  }

  Color _color(String category) {
    switch (category.toLowerCase()) {
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

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final color = _color(topic.category);
    final icon = _icon(topic.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF3F4F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          topic.category.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.educationMinRead(topic.readingTimeMinutes),
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF9CA3AF)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: topic.isCompleted ? 1.0 : 0.0,
                      minHeight: 3,
                      backgroundColor: const Color(0xFFF3F4F6),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF34D399)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            topic.isCompleted
                ? const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF34D399), size: 20)
                : const Icon(Icons.chevron_right,
                    color: Color(0xFF9CA3AF), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Personalized quiz CTA
// ─────────────────────────────────────────────────────────────────

class _PersonalizedSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF818CF8).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.educationPersonalized,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(width: 6),
              const Text('✨', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.educationPersonalizedSubtitle,
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  context.push('/education/quiz/personalized'),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(l10n.quizPersonalizedButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF818CF8),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
