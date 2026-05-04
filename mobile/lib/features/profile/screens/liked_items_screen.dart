import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/item.dart';
import '../../items/providers/items_provider.dart';

final likedItemsProvider = FutureProvider.autoDispose<List<Item>>((ref) async {
  final repo = ref.watch(itemsRepositoryProvider);
  final result = await repo.getLikedItems();
  return result.data;
});

class LikedItemsScreen extends ConsumerWidget {
  const LikedItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final likedItemsAsync = ref.watch(likedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Likes'),
      ),
      body: likedItemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('You have not liked any items yet.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.72,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final subtitle =
                  item.category.name == 'Shoes' && item.shoeSizeEu != null
                      ? 'EU ${item.shoeSizeEu!.toStringAsFixed(0)}'
                      : item.size.label;

              return Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: item.photos.isNotEmpty
                          ? Image.network(
                              item.photos.first.thumbnailUrl ?? item.photos.first.url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Icon(
                                  Icons.checkroom_rounded,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : Center(
                              child: Icon(
                                Icons.checkroom_rounded,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.category.name} • $subtitle',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
