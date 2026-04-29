import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';
import '../../../core/providers/auth_provider.dart';
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
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48,
                  color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text('Could not load match',
                  style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      ),
      data: (match) => _buildContent(context, ref, theme, match),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, ThemeData theme, Match match) {
    final currentUserId = ref.watch(authProvider).userId;
    final isUserA = currentUserId == match.userAId;
    final otherUserId = isUserA ? match.userBId : match.userAId;
    final otherDisplayName =
        (isUserA ? match.userB?.displayName : match.userA?.displayName) ??
            'Seller';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Text('Match Details',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Items swap visual
                    Row(
                      children: [
                        Expanded(
                          child: _ItemPreview(
                            label: 'Your Item',
                            brand: match.itemA?.brand ?? 'Item',
                            thumbnailUrl:
                                match.itemA?.photos.firstOrNull?.url,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withAlpha(20),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.swap_horiz_rounded,
                                size: 22, color: theme.colorScheme.primary),
                          ),
                        ),
                        Expanded(
                          child: _ItemPreview(
                            label: 'Their Item',
                            brand: match.itemB?.brand ?? 'Item',
                            thumbnailUrl:
                                match.itemB?.photos.firstOrNull?.url,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Status card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Column(
                        children: [
                          Text('Status',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              )),
                          const SizedBox(height: 6),
                          _StatusChip(status: match.status),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.go('/matches/$matchId/chat'),
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Open Chat'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            context.go('/profile/user/$otherUserId'),
                        icon: const Icon(Icons.person_outline_rounded),
                        label: Text('View $otherDisplayName Profile'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.tonal(
                        onPressed: () async {
                          await ref
                              .read(matchingProvider.notifier)
                              .confirmMatch(matchId);
                          if (context.mounted) context.pop();
                        },
                        child: const Text('Confirm Swap'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) =>
                                ProposeOfferScreen(matchId: matchId),
                          ));
                        },
                        icon: const Icon(Icons.compare_arrows_rounded),
                        label: const Text('Counter-Offer'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel Match?'),
                            content: const Text(
                                'This will cancel the swap. This action cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Keep')),
                              FilledButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: theme.colorScheme.error,
                                  ),
                                  child: const Text('Cancel Match')),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await ref
                              .read(matchingProvider.notifier)
                              .cancelMatch(matchId);
                          if (context.mounted) context.pop();
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      child: const Text('Cancel Match'),
                    ),
                  ],
                ),
              ),
            ),
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: [
          Container(
            height: 110,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: thumbnailUrl != null
                ? Image.network(thumbnailUrl!, fit: BoxFit.cover)
                : Center(
                    child: Icon(Icons.checkroom_rounded,
                        size: 36,
                        color: theme.colorScheme.onSurfaceVariant
                            .withAlpha(100)),
                  ),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          Text(brand,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final MatchStatus status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      MatchStatus.pending => (Colors.orange, 'Pending'),
      MatchStatus.negotiating => (Colors.blue, 'Negotiating'),
      MatchStatus.agreed => (Colors.green, 'Agreed'),
      MatchStatus.awaitingConfirmation => (Colors.purple, 'Awaiting Confirmation'),
      MatchStatus.completed => (Colors.teal, 'Completed'),
      MatchStatus.canceled => (Colors.grey, 'Canceled'),
      MatchStatus.expired => (Colors.red, 'Expired'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
