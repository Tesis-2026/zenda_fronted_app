import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/badges_api_service.dart';
import '../../l10n/l10n_extension.dart';

final badgesServiceProvider = Provider<BadgesApiService>(
  (_) => BadgesApiService(),
);

final _badgesProvider = FutureProvider.autoDispose<List<ZendaBadge>>((ref) {
  return ref.read(badgesServiceProvider).getAll();
});

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final badgesAsync = ref.watch(_badgesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.badgesTitle)),
      body: badgesAsync.when(
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
          final earned = badges.where((b) => b.isEarned).length;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(_badgesProvider),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.badgesEarnedCount(earned, badges.length),
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: badges.length,
                    itemBuilder: (context, index) =>
                        _BadgeTile(badge: badges[index]),
                  ),
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

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final ZendaBadge badge;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: badge.isEarned ? badge.description : '???',
      child: Container(
        decoration: BoxDecoration(
          color: badge.isEarned
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: badge.isEarned
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!badge.isEarned)
              ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0,      0,      0,      1, 0,
                ]),
                child: Icon(
                  Icons.military_tech,
                  size: 36,
                  color: colorScheme.onSurfaceVariant,
                ),
              )
            else
              Icon(
                Icons.military_tech,
                size: 36,
                color: colorScheme.onPrimaryContainer,
              ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                badge.isEarned ? badge.name : '???',
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: badge.isEarned
                          ? colorScheme.onPrimaryContainer
                          : colorScheme.onSurfaceVariant,
                      fontWeight: badge.isEarned
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
