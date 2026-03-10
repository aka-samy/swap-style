import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(profileProvider.notifier).loadWishlist());
  }

  void _showAddDialog() {
    final brandCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Add to Wishlist',
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 16),
            TextField(
              controller: brandCtrl,
              decoration: const InputDecoration(labelText: 'Brand (optional)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                await ref.read(profileProvider.notifier).addWishlistEntry({
                  'category': 'shirt',
                  if (brandCtrl.text.trim().isNotEmpty)
                    'brand': brandCtrl.text.trim(),
                  if (notesCtrl.text.trim().isNotEmpty)
                    'notes': notesCtrl.text.trim(),
                });
                if (ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Add'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = ref.watch(profileProvider).wishlist;

    return Scaffold(
      appBar: AppBar(title: const Text('Wishlist')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
      body: entries.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64, color: theme.colorScheme.primary.withAlpha(102)),
                  const SizedBox(height: 16),
                  Text('Your wishlist is empty',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Add items you\'re looking for and get notified when a match appears.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                return Card(
                  child: ListTile(
                    title: Text(entry.category),
                    subtitle: Text([
                      if (entry.size != null) 'Size: ${entry.size}',
                      if (entry.brand != null) entry.brand!,
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => ref
                          .read(profileProvider.notifier)
                          .removeWishlistEntry(entry.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
