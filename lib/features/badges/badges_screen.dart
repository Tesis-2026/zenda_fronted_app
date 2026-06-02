import '../../core/theme/zenda_theme_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/education_api_service.dart';
import '../../core/widgets/zenda_app_bar.dart';
import '../../l10n/l10n_extension.dart';

final badgesServiceProvider = Provider<BadgesApiService>(
  (_) => BadgesApiService(),
);

final _badgesProvider = FutureProvider.autoDispose<List<ZendaBadge>>((ref) {
  return ref.read(badgesServiceProvider).getAll();
});

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key, this.embedded = false});

  /// When true, returns just the content (no Scaffold/AppBar) so it can be
  /// hosted inside the Education screen's tab stack.
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final badgesAsync = ref.watch(_badgesProvider);

    final body = badgesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(l10n.badgesErrorLoad),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(_badgesProvider),
                child: Text(l10n.commonRetry),
              ),
            ],
          ),
        ),
        data: (badges) {
          final earnedBadges = badges.where((b) => b.isEarned).toList();
          final lockedBadges = badges.where((b) => !b.isEarned).toList();
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_badgesProvider),
            child: CustomScrollView(
              slivers: [
                // AppBar action: "N earned" chip is handled below as inline header
                // Earned section header
                if (earnedBadges.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        l10n.badgesSectionEarned,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (earnedBadges.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: earnedBadges.length,
                      itemBuilder: (context, index) =>
                          _BadgeTile(badge: earnedBadges[index]),
                    ),
                  ),
                // Locked section header
                if (lockedBadges.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        l10n.badgesSectionLocked,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (lockedBadges.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: lockedBadges.length,
                      itemBuilder: (context, index) =>
                          _BadgeTile(badge: lockedBadges[index]),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          );
        },
    );

    if (embedded) return body;
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: ZendaAppBar(
        title: l10n.badgesTitle,
        actions: [
          badgesAsync.whenOrNull(
            data: (badges) {
              final earned = badges.where((b) => b.isEarned).length;
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF34D399).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$earned ${l10n.badgesEarnedLabel}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              );
            },
          ) ?? const SizedBox.shrink(),
        ],
      ),
      body: body,
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final ZendaBadge badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: badge.isEarned
                ? const Color(0xFF34D399).withValues(alpha: 0.0)
                : const Color(0xFFE5E7EB),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (badge.isEarned)
              Icon(
                Icons.military_tech_rounded,
                size: 40,
                color: const Color(0xFF1F2937),
              )
            else
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: const Icon(
                  Icons.military_tech_rounded,
                  size: 40,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                // Always show the badge name (locked names are visible in design)
                badge.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: badge.isEarned
                          ? const Color(0xFF1F2937)
                          : const Color(0xFF9CA3AF),
                      fontWeight: badge.isEarned
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ),
            if (badge.isEarned && badge.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
