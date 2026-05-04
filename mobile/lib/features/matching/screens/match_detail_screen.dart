import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';
import '../../../core/providers/auth_provider.dart';
import '../data/matching_repository.dart';
import '../providers/matching_provider.dart';
import '../providers/counter_offer_provider.dart';
import 'propose_offer_screen.dart';

final _matchDetailProvider =
    FutureProvider.family<Match, String>((ref, matchId) async {
  final client = ref.watch(apiClientProvider);
  return MatchingRepository(client).getMatch(matchId);
});

class MatchDetailScreen extends ConsumerStatefulWidget {
  final String matchId;
  const MatchDetailScreen({super.key, required this.matchId});

  @override
  ConsumerState<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends ConsumerState<MatchDetailScreen> {
  String get matchId => widget.matchId;

  @override
  Widget build(BuildContext context) {
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
    final currentUserId = ref.watch(authProvider).userId ?? '';
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
                          _StatusChip(match: match, currentUserId: currentUserId),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    if (match.status == MatchStatus.completed) ...[
                      // Rating feature coming soon
                    ] else ...[
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
                    _CounterOffersSection(matchId: matchId),
                    const SizedBox(height: 10),
                    ],
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
  final Match match;
  final String currentUserId;
  const _StatusChip({required this.match, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isUserA = currentUserId == match.userAId;
    final hasConfirmed = isUserA ? match.userAConfirmed : match.userBConfirmed;

    final (color, label) = switch (match.status) {
      MatchStatus.pending => (Colors.orange, 'Pending'),
      MatchStatus.negotiating => (Colors.blue, 'Negotiating'),
      MatchStatus.agreed => hasConfirmed ? (Colors.purple, 'Waiting for other side') : (Colors.green, 'Agreed'),
      MatchStatus.awaitingConfirmation => (Colors.purple, hasConfirmed ? 'Waiting for other side' : 'Needs your confirmation'),
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

class _CounterOffersSection extends ConsumerStatefulWidget {
  final String matchId;
  const _CounterOffersSection({required this.matchId});

  @override
  ConsumerState<_CounterOffersSection> createState() => _CounterOffersSectionState();
}

class _CounterOffersSectionState extends ConsumerState<_CounterOffersSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(counterOfferProvider(widget.matchId).notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(counterOfferProvider(widget.matchId));
    final theme = Theme.of(context);

    if (state.isLoading && state.offers.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (state.offers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text('Counter Offers', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        ...state.offers.map((offer) {
          final amountText = offer.monetaryAmount != null && offer.monetaryAmount! > 0 
              ? '\$${offer.monetaryAmount!.toStringAsFixed(2)}' 
              : '';
          final itemsText = offer.items.isNotEmpty ? '${offer.items.length} items' : '';
          final titleParts = [if (amountText.isNotEmpty) amountText, if (itemsText.isNotEmpty) itemsText];
          final title = titleParts.isEmpty ? 'Trade Offer' : titleParts.join(' + ');

          return Card(
            elevation: 0,
            color: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: Icon(Icons.compare_arrows_rounded, color: theme.colorScheme.primary),
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: offer.message != null && offer.message!.isNotEmpty 
                  ? Text('"${offer.message}"', style: const TextStyle(fontStyle: FontStyle.italic))
                  : null,
              trailing: Chip(
                label: Text(offer.status.name.toUpperCase(), style: const TextStyle(fontSize: 10)),
                padding: EdgeInsets.zero,
                backgroundColor: offer.status.name == 'pending' ? Colors.orange.withAlpha(50) : null,
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _showRatingDialog(BuildContext context, WidgetRef ref, String matchId, String rateeId) async {
    int score = 5;
    String comment = '';
    
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Rate User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your swap experience?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    onPressed: () => setState(() => score = index + 1),
                    icon: Icon(
                      index < score ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.amber,
                      size: 36,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (val) => comment = val,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(matchingRepositoryProvider).rateUser(matchId, rateeId, score, comment);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating submitted successfully!')),
                    );
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to submit rating.')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
