import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/theme/zenda_theme_x.dart';
import '../../core/utils/difficulty_utils.dart';
import '../../core/widgets/app_progress_bar.dart';
import '../../core/widgets/app_toast.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';
import 'learning_path_screen.dart';

final topicDetailProvider =
    FutureProvider.autoDispose.family<EducationTopic, String>((ref, id) {
  return ref.read(educationServiceProvider).getTopic(id);
});

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final topicAsync = ref.watch(topicDetailProvider(topicId));

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
          onRead: () async {
            // Marking as READ is not completion — completion is earned via the
            // quiz (>=70%). Refresh detail + list + path to reflect read state.
            await ref.read(educationServiceProvider).markRead(topic.id);
            ref.invalidate(topicDetailProvider(topicId));
            ref.invalidate(topicsProvider);
            ref.invalidate(learningPathProvider);
            if (context.mounted) {
              showAppToast(
                context,
                l10n.educationMarkedRead,
                type: ToastType.success,
              );
            }
          },
        ),
      ),
    );
  }
}

class _TopicDetailBody extends StatelessWidget {
  const _TopicDetailBody({required this.topic, required this.onRead});
  final EducationTopic topic;
  final Future<void> Function() onRead;

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
    return switch (topic.difficulty.toLowerCase()) {
      'principiante' || 'beginner' => const Color(0xFF43A047),
      'intermedio' || 'intermediate' => const Color(0xFFFB8C00),
      'avanzado' || 'advanced' => const Color(0xFFE53935),
      _ => const Color(0xFF757575),
    };
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
    final colors = context.colors;
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
                          label: difficultyEs(topic.difficulty),
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
        // Reading progress bar with label
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Text(
                  'Progreso de lectura',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.textMuted,
                        fontSize: 12,
                      ),
                ),
                const Spacer(),
                Text(
                  topic.isCompleted ? '100%' : '0%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF34D399),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
            child: AppProgressBar(
              value: topic.isCompleted ? 1.0 : 0.0,
              color: const Color(0xFF34D399),
              backgroundColor: colors.fill,
            ),
          ),
        ),
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Text(
              topic.content,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.75,
                    fontSize: 15,
                    color: colors.textPrimary,
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
                if (topic.isCompleted)
                  _StatusPill(
                    icon: Icons.check_circle_rounded,
                    label: l10n.educationTopicCompleted,
                    color: const Color(0xFF34D399),
                  )
                else if (topic.isRead) ...[
                  _StatusPill(
                    icon: Icons.menu_book_rounded,
                    label: l10n.educationTopicRead,
                    color: const Color(0xFF818CF8),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.educationCompleteHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF6B7280)),
                  ),
                ]
                else
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: Text(l10n.educationMarkRead),
                      onPressed: onRead,
                      style: FilledButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    iconAlignment: IconAlignment.end,
                    label: Text(l10n.educationTakeQuiz),
                    onPressed: () =>
                        context.push(
                          '/education/${topic.id}/quiz',
                          extra: topic.title,
                        ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF34D399),
                      foregroundColor: Colors.white,
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

/// Full-width status banner (e.g. "Completado" / "Leído").
class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
