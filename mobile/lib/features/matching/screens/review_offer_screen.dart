import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/counter_offer.dart';
import '../providers/counter_offer_provider.dart';

class ReviewOfferScreen extends ConsumerWidget {
  final String matchId;
  final CounterOffer offer;
  final bool isProposer;

  const ReviewOfferScreen({
    super.key,
    required this.matchId,
    required this.offer,
    required this.isProposer,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review Offer')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _statusColor(offer.status).withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor(offer.status)),
              ),
              child: Text(
                _statusLabel(offer.status),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _statusColor(offer.status),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),

            // Extra items
            if (offer.items.isNotEmpty) ...[
              Text('Additional Items', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              ...offer.items.map((ci) => ListTile(
                    leading: const Icon(Icons.checkroom),
                    title: Text(ci.item?.brand ?? ci.itemId),
                    subtitle: Text(ci.item?.size.name.toUpperCase() ?? ''),
                  )),
              const SizedBox(height: 12),
            ],

            // Cash adjustment
            if (offer.monetaryAmount != 0) ...[
              Text('Cash Adjustment', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '\$${offer.monetaryAmount.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Message
            if (offer.message != null) ...[
              Text('Message', style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(offer.message!),
              const SizedBox(height: 20),
            ],

            const Spacer(),

            // Action buttons (only for recipient)
            if (!isProposer &&
                offer.status == CounterOfferStatus.pending) ...[
              FilledButton(
                onPressed: () async {
                  await ref
                      .read(counterOfferProvider(matchId).notifier)
                      .accept(offer.id);
                  if (context.mounted) Navigator.of(context).pop('accepted');
                },
                child: const Text('Accept'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () async {
                  await ref
                      .read(counterOfferProvider(matchId).notifier)
                      .decline(offer.id);
                  if (context.mounted) Navigator.of(context).pop('declined');
                },
                child: const Text('Decline'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop('counter');
                },
                child: const Text('Make Counter-Offer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(CounterOfferStatus status) {
    return switch (status) {
      CounterOfferStatus.pending => Colors.orange,
      CounterOfferStatus.accepted => Colors.green,
      CounterOfferStatus.declined => Colors.red,
      CounterOfferStatus.superseded => Colors.grey,
    };
  }

  String _statusLabel(CounterOfferStatus status) {
    return switch (status) {
      CounterOfferStatus.pending => 'Awaiting Response',
      CounterOfferStatus.accepted => 'Accepted',
      CounterOfferStatus.declined => 'Declined',
      CounterOfferStatus.superseded => 'Superseded by new offer',
    };
  }
}
