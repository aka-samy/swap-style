import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/item.dart';
import '../../../core/models/user.dart';
import '../data/profile_repository.dart';
import '../providers/profile_provider.dart';
import 'report_user_sheet.dart';
import '../../items/data/items_repository.dart';
import '../../items/providers/items_provider.dart';
import '../../matching/providers/matching_provider.dart';

final _publicProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client).getPublicProfile(userId);
});

final _publicClosetProvider =
    FutureProvider.family<List<Item>, String>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client).getPublicCloset(userId);
});

final _blocksProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(profileRepositoryProvider).getBlocks();
});

class PublicProfileScreen extends ConsumerStatefulWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  ConsumerState<PublicProfileScreen> createState() => _PublicProfileScreenState();
}

class _PublicProfileScreenState extends ConsumerState<PublicProfileScreen> {
  bool _isTogglingBlock = false;

  Future<void> _openChatAboutItem(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    try {
      final match =
          await ref.read(matchingRepositoryProvider).openChatForItem(item.id);
      if (!context.mounted) return;
      context.go('/matches/${match.id}/chat');
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open chat for this item. Make sure you have at least one available item in your closet.',
          ),
        ),
      );
    }
  }

  void _showFullScreenPhotos(BuildContext context, Item item, int initialIndex) {
    if (item.photos.isEmpty) return;
    
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) {
        final pageController = PageController(initialPage: initialIndex);
        return Dialog.fullscreen(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              PageView.builder(
                controller: pageController,
                itemCount: item.photos.length,
                itemBuilder: (context, index) {
                  return InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4.0,
                    child: Center(
                      child: Image.network(
                        item.photos[index].url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                        ),
                      ),
                    ),
                  );
                },
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedBuilder(
                      animation: pageController,
                      builder: (context, _) {
                        final page = pageController.hasClients
                            ? (pageController.page?.round() ?? initialIndex)
                            : initialIndex;
                        return Text(
                          '${page + 1} / ${item.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showPublicItemActions(
    BuildContext context,
    WidgetRef ref,
    Item item,
  ) async {
    final itemRepo = ref.read(itemsRepositoryProvider);

    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(item.brand),
                  subtitle: Text('${item.category.apiValue} • ${item.size.label}'),
                ),
                if (item.photos.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.photo_library_outlined),
                    title: const Text('View photos'),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _showFullScreenPhotos(context, item, 0);
                    },
                  ),
                FutureBuilder<ItemStats>(
                  future: itemRepo.getItemStats(item.id),
                  builder: (context, snapshot) {
                    final likes = snapshot.data?.likesCount ?? 0;
                    final activeMatches = snapshot.data?.activeMatches ?? 0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.favorite_rounded,
                                    color: Colors.pink, size: 18),
                                const SizedBox(width: 6),
                                Text('$likes likes'),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                Icon(Icons.handshake_outlined,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 18),
                                const SizedBox(width: 6),
                                Text('$activeMatches active matches'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.chat_bubble_outline),
                  title: const Text('Chat about this item'),
                  subtitle: const Text('Starts chat and includes item context'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openChatAboutItem(context, ref, item);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: const Text('Report item'),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Report submitted')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(_publicProfileProvider(widget.userId));
    final closetAsync = ref.watch(_publicClosetProvider(widget.userId));
    final blocksAsync = ref.watch(_blocksProvider);
    
    final isBlocked = blocksAsync.valueOrNull?.contains(widget.userId) ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'report') {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ReportUserSheet(targetUserId: widget.userId),
                );
              } else if (value == 'block_toggle') {
                setState(() => _isTogglingBlock = true);
                try {
                  if (isBlocked) {
                    await ref.read(profileRepositoryProvider).unblockUser(widget.userId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
                    }
                  } else {
                    await ref.read(profileRepositoryProvider).blockUser(widget.userId);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User blocked')));
                    }
                  }
                  ref.invalidate(_blocksProvider);
                } catch (_) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Action failed')));
                  }
                } finally {
                  if (mounted) setState(() => _isTogglingBlock = false);
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('Report User')),
              PopupMenuItem(
                value: 'block_toggle',
                enabled: !_isTogglingBlock,
                child: Text(isBlocked ? 'Unblock User' : 'Block User'),
              ),
            ],
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (user) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    backgroundImage: user.profilePhotoUrl != null
                        ? NetworkImage(user.profilePhotoUrl!)
                        : null,
                    child: user.profilePhotoUrl == null
                        ? Icon(Icons.person,
                            size: 48,
                            color: theme.colorScheme.onPrimaryContainer)
                        : null,
                  ),
                  const SizedBox(height: 12),
                  Text(user.displayName,
                      style: theme.textTheme.headlineSmall),
                  if (isBlocked) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'You blocked this user',
                        style: TextStyle(
                          color: theme.colorScheme.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: _isTogglingBlock ? null : () async {
                        setState(() => _isTogglingBlock = true);
                        try {
                          await ref.read(profileRepositoryProvider).unblockUser(widget.userId);
                          ref.invalidate(_blocksProvider);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User unblocked')));
                          }
                        } finally {
                          if (mounted) setState(() => _isTogglingBlock = false);
                        }
                      },
                      child: const Text('Unblock User'),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '${user.stats?.averageRating?.toStringAsFixed(1) ?? '--'} rating',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Closet', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            closetAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => Center(
                child: Text(
                  'Could not load closet items',
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              data: (items) {
                if (isBlocked) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        'You cannot view the closet of a blocked user.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  );
                }

                if (items.isEmpty) {
                  return const Center(child: Text('No public items yet'));
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final subtitle =
                        item.category == ItemCategory.shoes && item.shoeSizeEu != null
                            ? 'EU ${item.shoeSizeEu!.toStringAsFixed(0)}'
                            : item.size.label;

                    return GestureDetector(
                      onTap: () => _showPublicItemActions(context, ref, item),
                      child: Container(
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
                                  ? Stack(
                                      children: [
                                        Positioned.fill(
                                          child: Image.network(
                                            item.photos.first.thumbnailUrl ?? item.photos.first.url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Center(
                                              child: Icon(
                                                Icons.checkroom_rounded,
                                                color: theme.colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (item.photos.length > 1)
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(130),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                '${item.photos.length} photos',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
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
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
