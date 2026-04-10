import 'package:flutter/material.dart';

import '../data/discovery_repository.dart';

class ItemCard extends StatelessWidget {
  final FeedItem item;

  const ItemCard({super.key, required this.item});

  String _safeInitial(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return '?';
    return cleaned.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          item.photos.isNotEmpty
              ? Image.network(
                  item.photos.first.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(theme),
                )
              : _placeholder(theme),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withAlpha(180),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Row(
              children: [
                if (item.isVerified)
                  _Badge(
                    icon: Icons.verified_rounded,
                    label: 'Verified',
                    color: theme.colorScheme.primary,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${item.distanceKm.toStringAsFixed(1)} km',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.brand,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _GlassChip(label: item.size.toUpperCase()),
                    _GlassChip(label: item.category),
                    _GlassChip(label: item.condition),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundImage: item.ownerPhotoUrl != null
                          ? NetworkImage(item.ownerPhotoUrl!)
                          : null,
                      backgroundColor: Colors.white.withAlpha(60),
                      child: item.ownerPhotoUrl == null
                          ? Text(
                              _safeInitial(item.ownerName),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.ownerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.ownerVerified)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(
                          Icons.verified_user_rounded,
                          size: 14,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.checkroom_rounded,
          size: 64,
          color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final String label;

  const _GlassChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(40),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
