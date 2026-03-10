import 'package:flutter/material.dart';

class EmptyFeed extends StatelessWidget {
  const EmptyFeed({super.key, this.onAdjustFilters});

  final VoidCallback? onAdjustFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_off,
              size: 80,
              color: theme.colorScheme.primary.withAlpha(102),
            ),
            const SizedBox(height: 24),
            Text(
              'No more items nearby',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Try expanding your search radius or check back later for new listings.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onAdjustFilters,
              icon: const Icon(Icons.tune),
              label: const Text('Adjust Filters'),
            ),
          ],
        ),
      ),
    );
  }
}
