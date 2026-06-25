import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/education_api_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/difficulty_utils.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';
import 'education_screen.dart';

final learningPathProvider =
    FutureProvider.autoDispose<PersonalizedLearningPath>((ref) {
      return ref.read(educationServiceProvider).getPersonalizedLearningPath();
    });

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({
    super.key,
    this.embedded = false,
    this.active = true,
  });

  final bool embedded;
  final bool active;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(learningPathProvider);
    await ref.read(learningPathProvider.future);
  }

  void _openStep(BuildContext context, LearningPathStep step) {
    if (step.isPersonalizedQuiz) {
      context.push('/education/quiz/personalized');
      return;
    }

    final topicId = step.topicId;
    if (topicId != null && topicId.isNotEmpty) {
      context.push('/education/$topicId');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    if (!active) return const SizedBox.shrink();

    final pathAsync = ref.watch(learningPathProvider);

    final body = pathAsync.when(
      loading: () => const _PathLoading(),
      error: (_, _) =>
          _PathError(onRetry: () => ref.invalidate(learningPathProvider)),
      data: (path) => RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _AiBanner(
              path: path,
              onRefresh: () => ref.invalidate(learningPathProvider),
            ),
            const SizedBox(height: 16),
            if (path.steps.isEmpty)
              const _EmptyPath()
            else
              ...path.steps.map(
                (step) => _PathStepCard(
                  step: step,
                  onTap: () => _openStep(context, step),
                ),
              ),
          ],
        ),
      ),
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(title: l10n.learningPathTitle),
      body: body,
    );
  }
}

class _AiBanner extends StatelessWidget {
  const _AiBanner({required this.path, required this.onRefresh});

  final PersonalizedLearningPath path;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final sourceLabel = path.usedAgent ? 'Ruta IA' : 'Ruta sugerida';

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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: AppColors.info,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        sourceLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: context.l10n.commonRetry,
                      onPressed: onRefresh,
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  path.summary.isEmpty
                      ? 'Sigue tu ruta recomendada paso a paso.'
                      : path.summary,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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

class _PathStepCard extends StatelessWidget {
  const _PathStepCard({required this.step, required this.onTap});

  final LearningPathStep step;
  final VoidCallback onTap;

  Color get _accent =>
      step.isPersonalizedQuiz ? AppColors.info : AppColors.primary;

  IconData get _icon => step.isPersonalizedQuiz
      ? Icons.psychology_alt_rounded
      : Icons.menu_book_rounded;

  String get _statusLabel {
    if (step.isCompleted) return 'Completado';
    if (step.isRead) return 'Leido';
    return step.isPersonalizedQuiz ? 'Quiz IA' : 'Pendiente';
  }

  Color _difficultyColor(String value) {
    switch (value.toLowerCase()) {
      case 'beginner':
      case 'principiante':
        return AppColors.primary;
      case 'intermediate':
      case 'intermedio':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _difficultyColor(step.difficulty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: step.isCompleted
                    ? AppColors.primary.withValues(alpha: 0.45)
                    : AppColors.border,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StepMarker(
                  order: step.order,
                  icon: _icon,
                  color: _accent,
                  completed: step.isCompleted,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              step.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: context.colors.icon,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.reason,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textMuted,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: Icons.flag_rounded,
                            label: _statusLabel,
                            color: _accent,
                          ),
                          _InfoChip(
                            icon: Icons.school_rounded,
                            label: difficultyEs(step.difficulty),
                            color: diffColor,
                          ),
                          _InfoChip(
                            icon: Icons.schedule_rounded,
                            label: '${step.estimatedMinutes} min',
                            color: AppColors.textMuted,
                          ),
                        ],
                      ),
                      if (step.focus.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.track_changes_rounded,
                              size: 14,
                              color: _accent,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                step.focus,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.82,
                                  ),
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepMarker extends StatelessWidget {
  const _StepMarker({
    required this.order,
    required this.icon,
    required this.color,
    required this.completed,
  });

  final int order;
  final IconData icon;
  final Color color;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: completed ? AppColors.primary : color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: completed
          ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
          : Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: color.withValues(alpha: 0.28)),
                    ),
                    child: Text(
                      '$order',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
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
      constraints: const BoxConstraints(minHeight: 28),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathLoading extends StatelessWidget {
  const _PathLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          const SizedBox(height: 16),
          const Text(
            'Preparando tu ruta...',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PathError extends StatelessWidget {
  const _PathError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.route_outlined,
              size: 52,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar la ruta de aprendizaje',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyPath extends StatelessWidget {
  const _EmptyPath();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.menu_book_outlined, size: 44, color: AppColors.textSubtle),
          SizedBox(height: 12),
          Text(
            'Aun no hay pasos disponibles.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
