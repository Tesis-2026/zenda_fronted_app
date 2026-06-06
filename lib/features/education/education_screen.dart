import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/user_menu_button.dart';
import '../../features/dashboard/dashboard_providers.dart';
import '../badges/badges_screen.dart';
import '../challenges/challenges_screen.dart';
import 'learning_path_screen.dart';
import '../../l10n/l10n_extension.dart';

final educationServiceProvider = Provider<EducationApiService>(
  (_) => EducationApiService(),
);

final topicsProvider = FutureProvider.autoDispose<List<EducationTopic>>((ref) {
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
  int _tab = 0; // 0 Aprende · 1 Ruta · 2 Retos · 3 Logros

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EducationTopic> _applyFilters(List<EducationTopic> topics) {
    if (_query.isEmpty) return topics;
    return topics
        .where((t) => t.title.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final streakDays = ref.watch(streakProvider);

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, size: 16, color: Color(0xFFD97706)),
                const SizedBox(width: 2),
                Text(
                  l10n.streakLabel(streakDays),
                  style: const TextStyle(
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
      body: Column(
        children: [
          _SectionTabs(
            selected: _tab,
            onSelect: (i) => setState(() => _tab = i),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab,
              children: [
                _buildLearnTab(context),
                const LearningPathScreen(embedded: true),
                const ChallengesScreen(embedded: true),
                const BadgesScreen(embedded: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearnTab(BuildContext context) {
    final l10n = context.l10n;
    final topicsAsync = ref.watch(topicsProvider);
    return topicsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.educationErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(topicsProvider),
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
            onRefresh: () async => ref.invalidate(topicsProvider),
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Section tabs (Learn / Challenges / Badges / Progress)
// ─────────────────────────────────────────────────────────────────

class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = [
      l10n.educationTabLearn,
      l10n.educationTabPath,
      l10n.educationTabChallenges,
      l10n.educationTabBadges,
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onSelect(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected == i
                        ? const Color(0xFF34D399)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: selected == i
                        ? null
                        : Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected == i
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Featured card
// ─────────────────────────────────────────────────────────────────

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.topic, required this.onTap});
  final EducationTopic topic;
  final VoidCallback onTap;

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'budgeting':
        return Icons.lightbulb_outline_rounded;
      case 'saving':
        return Icons.savings_rounded;
      case 'investing':
        return Icons.trending_up_rounded;
      default:
        return Icons.menu_book_rounded;
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Use first sentence as the subtitle excerpt (up to 80 chars)
    final firstSentence = topic.content.split(RegExp(r'[.!?\n]')).first.trim();
    final excerpt = firstSentence.length > 80
        ? '${firstSentence.substring(0, 80)}...'
        : firstSentence;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.textDark,
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
                    child: Icon(_categoryIcon(topic.category),
                        size: 24, color: Colors.white70),
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
                Icon(Icons.access_time_rounded,
                    color: Colors.white.withValues(alpha: 0.55), size: 14),
                const SizedBox(width: 4),
                Text(
                  l10n.educationMinRead(topic.readingTimeMinutes),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 12,
                  ),
                ),
                if (topic.questionCount > 0) ...[
                  const SizedBox(width: 14),
                  Icon(Icons.edit_outlined,
                      color: Colors.white.withValues(alpha: 0.55), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    l10n.educationQuestions(topic.questionCount),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.55),
                      fontSize: 12,
                    ),
                  ),
                ],
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
    final isLocked = topic.isLocked;

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Opacity(
        opacity: isLocked ? 0.65 : 1.0,
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
              Stack(
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
                  if (isLocked)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_rounded,
                            color: Colors.white, size: 10),
                      ),
                    ),
                ],
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
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          l10n.educationMinRead(topic.readingTimeMinutes),
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF9CA3AF)),
                        ),
                        if (topic.questionCount > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            l10n.educationQuestions(topic.questionCount),
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9CA3AF)),
                          ),
                        ],
                      ],
                    ),
                    if (isLocked) ...[
                      const SizedBox(height: 5),
                      Text(
                        l10n.educationLocked,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9CA3AF),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      AppProgressBar(
                        value: topic.isCompleted ? 1.0 : 0.0,
                        color: const Color(0xFF34D399),
                        height: 3,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLocked)
                const Icon(Icons.lock_outline_rounded,
                    color: Color(0xFF9CA3AF), size: 18)
              else if (topic.isCompleted)
                const Icon(Icons.check_circle_rounded,
                    color: Color(0xFF34D399), size: 20)
              else
                const Icon(Icons.chevron_right,
                    color: Color(0xFF9CA3AF), size: 20),
            ],
          ),
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
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFF818CF8)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.educationPersonalizedSubtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
