import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';
import '../data/matching_repository.dart';
import '../providers/matching_provider.dart';
import 'propose_offer_screen.dart';

final _matchDetailProvider =
    FutureProvider.family<Match, String>((ref, matchId) async {
  final client = ref.watch(apiClientProvider);
  return MatchingRepository(client).getMatch(matchId);
});

class MatchDetailScreen extends ConsumerWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final matchAsync = ref.watch(_matchDetailProvider(matchId));

    return matchAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Match Details')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (match) => _buildContent(context, ref, theme, match),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ThemeData theme, Match match) {

    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Items comparison
            Row(
              children: [
                Expanded(
                    child: _ItemPreview(
                  label: 'Your Item',
                  brand: match.itemA?.brand ?? 'Item',
                  thumbnailUrl: match.itemA?.photos.firstOrNull?.url,
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_horiz,
                      size: 32, color: theme.colorScheme.primary),
                ),
                Expanded(
                    child: _ItemPreview(
                  label: 'Their Item',
                  brand: match.itemB?.brand ?? 'Item',
                  thumbnailUrl: match.itemB?.photos.firstOrNull?.url,
                )),
              ],
            ),
            const SizedBox(height: 24),

            // Status section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text('Match Status', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(match.status.name.toUpperCase(),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        )),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await ref
                          .read(matchingProvider.notifier)
                          .cancelMatch(matchId);
                      if (context.mounted) context.pop();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      await ref
                          .read(matchingProvider.notifier)
                          .confirmMatch(matchId);
                      if (context.mounted) context.pop();
                    },
                    child: const Text('Confirm Swap'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Chat action
            OutlinedButton.icon(
              onPressed: () => context.go('/matches/$matchId/chat'),
              icon: const Icon(Icons.chat),
              label: const Text('Open Chat'),
            ),
            const SizedBox(height: 8),
            // Counter-offer action
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => ProposeOfferScreen(matchId: matchId),
                ));
              },
              icon: const Icon(Icons.compare_arrows),
              label: const Text('Propose Counter-Offer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ItemPreview extends StatelessWidget {
  final String label;
  final String brand;
  final String? thumbnailUrl;

  const _ItemPreview({
    required this.label,
    required this.brand,
    this.thumbnailUrl,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: thumbnailUrl != null
                  ? Image.network(thumbnailUrl!, fit: BoxFit.cover)
                  : const Center(child: Icon(Icons.image, size: 40)),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            Text(brand, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
