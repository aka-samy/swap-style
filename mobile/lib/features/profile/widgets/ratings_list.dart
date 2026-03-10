import 'package:flutter/material.dart';
import '../../../core/models/rating.dart';

/// Displays a scrollable list of [Rating] items with a summary row at the top.
class RatingsList extends StatelessWidget {
  const RatingsList({
    super.key,
    required this.ratings,
    required this.averageScore,
    required this.total,
    this.isLoading = false,
  });

  final List<Rating> ratings;
  final double averageScore;
  final int total;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (ratings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star_border_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            const Text('No ratings yet'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SummaryCard(averageScore: averageScore, total: total),
        const SizedBox(height: 16),
        ...ratings.map((r) => _RatingItem(rating: r)),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.averageScore, required this.total});

  final double averageScore;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 40),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  averageScore.toStringAsFixed(1),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: cs.onPrimaryContainer,
                  ),
                ),
                Text(
                  '$total ${total == 1 ? "rating" : "ratings"}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onPrimaryContainer.withAlpha(180),
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

class _RatingItem extends StatelessWidget {
  const _RatingItem({required this.rating});

  final Rating rating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rater = rating.rater;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: rater?.profilePhotoUrl != null
                  ? NetworkImage(rater!.profilePhotoUrl!)
                  : null,
              child: rater?.profilePhotoUrl == null
                  ? Text(
                      rater?.displayName.characters.first.toUpperCase() ?? '?',
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rater?.displayName ?? 'Anonymous',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _StarRow(score: rating.score),
                    ],
                  ),
                  if (rating.comment != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      rating.comment!,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(rating.createdAt),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < score ? Icons.star_rounded : Icons.star_outline_rounded,
          size: 14,
          color: i < score ? Colors.amber : Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
