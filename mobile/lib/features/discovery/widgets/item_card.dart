import 'package:flutter/material.dart';
import '../data/discovery_repository.dart';

class ItemCard extends StatelessWidget {
  final FeedItem item;

  const ItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Photo area
          Expanded(
            child: item.photos.isNotEmpty
                ? Image.network(
                    item.photos.first.url,
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(Icons.image,
                        size: 64, color: theme.colorScheme.onSurfaceVariant),
                  ),
          ),

          // Info section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.brand,
                        style: theme.textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (item.isVerified)
                      Icon(Icons.verified,
                          color: theme.colorScheme.primary, size: 20),
                  ],
                ),
                const SizedBox(height: 4),

                // Size / Category / Condition chips
                Wrap(
                  spacing: 8,
                  children: [
                    _InfoChip(label: item.size.toUpperCase()),
                    _InfoChip(label: item.category),
                    _InfoChip(label: item.condition),
                  ],
                ),
                const SizedBox(height: 8),

                // Owner + Distance
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: item.ownerPhotoUrl != null
                          ? NetworkImage(item.ownerPhotoUrl!)
                          : null,
                      child: item.ownerPhotoUrl == null
                          ? Text(item.ownerName[0].toUpperCase(),
                              style: const TextStyle(fontSize: 12))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(item.ownerName,
                        style: theme.textTheme.bodyMedium),
                    if (item.ownerVerified)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified_user,
                            size: 14, color: theme.colorScheme.primary),
                      ),
                    const Spacer(),
                    Icon(Icons.location_on,
                        size: 16, color: theme.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 2),
                    Text('${item.distanceKm} km',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  const _InfoChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
