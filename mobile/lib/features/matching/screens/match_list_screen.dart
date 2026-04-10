import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/match.dart';
import '../providers/matching_provider.dart';

class MatchListScreen extends ConsumerStatefulWidget {
  const MatchListScreen({super.key});

  @override
  ConsumerState<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends ConsumerState<MatchListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(matchingProvider.notifier).loadMatches());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(matchingProvider);
    final matches = state.matches;
    final isLoading = state.isLoading;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text('Matches',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: isLoading && matches.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : matches.isEmpty
                      ? _buildEmptyState(theme)
                      : RefreshIndicator(
                          onRefresh: () =>
                              ref.read(matchingProvider.notifier).loadMatches(),
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              return _MatchCard(
                                match: matches[index],
                                onTap: () =>
                                    context.go('/matches/${matches[index].id}'),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.favorite_rounded,
                  size: 40, color: theme.colorScheme.primary.withAlpha(120)),
            ),
            const SizedBox(height: 20),
            Text('No matches yet',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'Keep swiping on Discover to find your first match!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Match match;
  final VoidCallback onTap;

  const _MatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: theme.colorScheme.surfaceContainerHighest,
        ),
        child: Row(
          children: [
            // Overlapping item thumbnails
            SizedBox(
              width: 72,
              height: 52,
              child: Stack(
                children: [
                  _ItemThumb(
                    photoUrl: match.itemA?.photos.firstOrNull?.url,
                    offset: 0,
                  ),
                  _ItemThumb(
                    photoUrl: match.itemB?.photos.firstOrNull?.url,
                    offset: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.itemA?.brand ?? "Item"} ↔ ${match.itemB?.brand ?? "Item"}',
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  _StatusBadge(status: match.status),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final String? photoUrl;
  final double offset;
  const _ItemThumb({this.photoUrl, required this.offset});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: offset,
      child: Container(
        width: 48,
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Theme.of(context).colorScheme.surface, width: 2),
          image: photoUrl != null
              ? DecorationImage(
                  image: NetworkImage(photoUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: photoUrl == null
            ? Icon(Icons.checkroom,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant)
            : null,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      MatchStatus.pending => (Colors.orange, 'Pending'),
      MatchStatus.negotiating => (Colors.blue, 'Negotiating'),
      MatchStatus.agreed => (Colors.green, 'Agreed'),
      MatchStatus.awaitingConfirmation => (Colors.purple, 'Confirming'),
      MatchStatus.completed => (Colors.teal, 'Completed'),
      MatchStatus.canceled => (Colors.grey, 'Canceled'),
      MatchStatus.expired => (Colors.red, 'Expired'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
