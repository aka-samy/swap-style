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
      appBar: AppBar(title: const Text('Matches')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : matches.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: matches.length,
                  itemBuilder: (context, index) {
                    return _MatchCard(
                      match: matches[index],
                      onTap: () => context.go('/matches/${matches[index].id}'),
                    );
                  },
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.handshake,
              size: 64, color: theme.colorScheme.primary.withAlpha(102)),
          const SizedBox(height: 16),
          Text('No matches yet', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Keep swiping to find your first match!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Item thumbnails
              SizedBox(
                width: 80,
                height: 60,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      child: _ItemThumb(
                        photoUrl: match.itemA?.photos.firstOrNull?.url,
                      ),
                    ),
                    Positioned(
                      left: 30,
                      child: _ItemThumb(
                        photoUrl: match.itemB?.photos.firstOrNull?.url,
                      ),
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
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: match.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _ItemThumb extends StatelessWidget {
  final String? photoUrl;
  const _ItemThumb({this.photoUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 60,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
      ),
      child: photoUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(photoUrl!, fit: BoxFit.cover),
            )
          : const Icon(Icons.image, size: 20),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
