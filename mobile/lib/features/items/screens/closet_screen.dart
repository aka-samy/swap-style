import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/item.dart';
import '../providers/items_provider.dart';

class ClosetScreen extends ConsumerStatefulWidget {
  const ClosetScreen({super.key});

  @override
  ConsumerState<ClosetScreen> createState() => _ClosetScreenState();
}

class _ClosetScreenState extends ConsumerState<ClosetScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(itemsProvider.notifier).loadMyItems());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(itemsProvider);
    final items = state.items;
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Closet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/closet/add'),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? _buildEmptyState(theme)
              : _buildItemGrid(items, theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.checkroom,
              size: 64, color: theme.colorScheme.primary.withAlpha(128)),
          const SizedBox(height: 16),
          Text('Your closet is empty',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('Add an item to start swapping!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.go('/closet/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _buildItemGrid(List<Item> items, ThemeData theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _ItemCard(
          item: item,
          onTap: () => context.go('/closet/edit/${item.id}'),
        );
      },
    );
  }
}

class _ItemCard extends StatelessWidget {
  final Item item;
  final VoidCallback onTap;

  const _ItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: item.photos.isNotEmpty
                    ? Image.network(
                        item.photos.first.url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Center(
                        child: Icon(Icons.image,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.brand,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(item.size.name.toUpperCase(),
                          style: theme.textTheme.bodySmall),
                      const Spacer(),
                      _StatusIndicator(status: item.status),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final ItemStatus status;
  const _StatusIndicator({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      ItemStatus.available => (Colors.green, 'Active'),
      ItemStatus.swapped => (Colors.blue, 'Swapped'),
      ItemStatus.removed => (Colors.grey, 'Removed'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}
