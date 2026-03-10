import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/gamification_provider.dart';
import '../../../core/models/gamification.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gamificationStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stats) => RefreshIndicator(
          onRefresh: () => ref.refresh(gamificationStatsProvider.future),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StreakCard(streak: stats.streak),
              const SizedBox(height: 24),
              Text(
                'Badges',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              if (stats.badges.isEmpty)
                _EmptyBadges()
              else
                _BadgeGrid(badges: stats.badges),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Streak Card ────────────────────────────────────────

class _StreakCard extends StatelessWidget {
  const _StreakCard({this.streak});
  final Streak? streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final current = streak?.currentStreak ?? 0;
    final longest = streak?.longestStreak ?? 0;

    return Card(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _FlameIcon(streak: current),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$current day${current == 1 ? '' : 's'} streak',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: cs.onSecondaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Best: $longest days',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSecondaryContainer.withAlpha(180),
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

class _FlameIcon extends StatelessWidget {
  const _FlameIcon({required this.streak});
  final int streak;

  @override
  Widget build(BuildContext context) {
    final color = streak >= 7
        ? Colors.deepOrange
        : streak >= 3
            ? Colors.orange
            : Colors.grey;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          streak > 0 ? '🔥' : '💤',
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }
}

// ─── Badge Grid ─────────────────────────────────────────

class _BadgeGrid extends StatelessWidget {
  const _BadgeGrid({required this.badges});
  final List<Badge> badges;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (_, i) => _BadgeTile(badge: badges[i]),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge});
  final Badge badge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => _showBadgeDetail(context, badge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.military_tech_rounded, size: 36),
          ),
          const SizedBox(height: 6),
          Text(
            badge.name,
            style: theme.textTheme.labelSmall,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(badge.name),
        content: Text(badge.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBadges extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.military_tech_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 12),
            const Text('No badges earned yet.\nKeep swapping to unlock them!'),
          ],
        ),
      ),
    );
  }
}
