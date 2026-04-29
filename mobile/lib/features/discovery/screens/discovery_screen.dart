import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../matching/providers/matching_provider.dart';
import '../../../core/services/location_service.dart';
import '../data/discovery_repository.dart';
import '../providers/discovery_provider.dart';
import '../providers/filter_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/empty_feed.dart';
import '../widgets/filter_panel.dart';

class _DiscoverySearchDelegate extends SearchDelegate<FeedItem?> {
  _DiscoverySearchDelegate(this.items);

  final List<FeedItem> items;

  @override
  String get searchFieldLabel => 'Search brand, category, owner';

  List<FeedItem> _filtered() {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;

    return items.where((item) {
      return item.brand.toLowerCase().contains(q) ||
          item.category.toLowerCase().contains(q) ||
          item.ownerName.toLowerCase().contains(q) ||
          item.condition.toLowerCase().contains(q);
    }).toList();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear search',
        onPressed: () => query = '',
        icon: const Icon(Icons.clear_rounded),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back_rounded),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    final theme = Theme.of(context);
    final matches = _filtered();

    if (items.isEmpty) {
      return Center(
        child: Text(
          'No discovery items loaded yet',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'No items found for "$query"',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    return ListView.separated(
      itemCount: matches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = matches[index];
        return ListTile(
          onTap: () => close(context, item),
          leading: CircleAvatar(
            backgroundImage: item.photos.isNotEmpty
                ? NetworkImage(item.photos.first.thumbnailUrl ?? item.photos.first.url)
                : null,
            child: item.photos.isEmpty ? const Icon(Icons.checkroom_rounded) : null,
          ),
          title: Text(item.brand),
          subtitle: Text('${item.category} • ${item.ownerName}'),
          trailing: Text('${item.distanceKm.toStringAsFixed(1)} km'),
        );
      },
    );
  }
}

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  bool _isBootstrappingFeed = true;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    Future.microtask(() => _loadFeed());
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _loadFeed() async {
    if (mounted) {
      setState(() => _isBootstrappingFeed = true);
    }

    try {
      final filters = ref.read(filterProvider);
      final location = await ref.read(currentLocationProvider.future);
      await ref.read(discoveryProvider.notifier).loadFeed(
            latitude: location.latitude,
            longitude: location.longitude,
            radiusKm: filters.radiusKm,
            size: filters.size,
            category: filters.category,
            shoeSizeEu: filters.shoeSizeEu,
          );
    } finally {
      if (mounted) {
        setState(() => _isBootstrappingFeed = false);
      }
    }
  }

  void _onSwipe(FeedItem item, String action) async {
    final result = await ref.read(discoveryProvider.notifier).swipe(item.id, action);
    if (result != null && result.matched && mounted) {
      _showMatchDialog(result.match!);
    }
    // Auto-load more when running low
    final state = ref.read(discoveryProvider);
    if (state.cards.length <= 3 && state.hasMore) {
      final filters = ref.read(filterProvider);
      final location = await ref.read(currentLocationProvider.future);
      ref.read(discoveryProvider.notifier).loadMore(
            latitude: location.latitude,
            longitude: location.longitude,
            radiusKm: filters.radiusKm,
            size: filters.size,
            category: filters.category,
        shoeSizeEu: filters.shoeSizeEu,
          );
    }
  }

  void _showMatchDialog(SwipeMatchInfo match) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.favorite, size: 36,
                    color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text("It's a Match!",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const SizedBox(height: 8),
              Text(
                'You and ${match.otherUser.name} both liked each other\'s items!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMatchItemPreview(match.myItem.brand, match.myItem.thumbnailUrl),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.swap_horiz,
                        color: Theme.of(context).colorScheme.primary, size: 28),
                  ),
                  _buildMatchItemPreview(match.theirItem.brand, match.theirItem.thumbnailUrl),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    if (mounted) {
                      context.go('/matches/${match.id}/chat');
                    }
                  },
                  child: const Text('Send a Message'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Keep Swiping'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchItemPreview(String brand, String? thumbnailUrl) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            image: thumbnailUrl != null
                ? DecorationImage(
                    image: NetworkImage(thumbnailUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: thumbnailUrl == null
              ? Icon(Icons.checkroom,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)
              : null,
        ),
        const SizedBox(height: 4),
        Text(brand,
            style: Theme.of(context).textTheme.labelSmall,
            overflow: TextOverflow.ellipsis),
      ],
    );
  }

  void _animateSwipe(FeedItem item, String action) {
    final screenWidth = MediaQuery.of(context).size.width;
    final target = action == 'like'
        ? Offset(screenWidth * 1.5, 0)
        : Offset(-screenWidth * 1.5, 0);

    final anim = Tween<Offset>(begin: _dragOffset, end: target)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    anim.addListener(() {
      setState(() => _dragOffset = anim.value);
    });

    _animController.forward(from: 0).then((_) {
      setState(() => _dragOffset = Offset.zero);
      _onSwipe(item, action);
    });
  }

  void _openFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => FilterPanel(
        onApply: () {
          Navigator.of(context).pop();
          _loadFeed();
        },
      ),
    );
  }

  Future<void> _openChatForItem(FeedItem item) async {
    try {
      final match = await ref
          .read(matchingRepositoryProvider)
          .openChatForItem(item.id);
      if (!mounted) return;
      context.go('/matches/${match.id}/chat');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open chat for this item. Make sure you have at least one available item in your closet.',
          ),
        ),
      );
    }
  }

  Future<void> _openSearch() async {
    final cards = ref.read(discoveryProvider).cards;
    final selected = await showSearch<FeedItem?>(
      context: context,
      delegate: _DiscoverySearchDelegate(cards),
    );

    if (selected != null && mounted) {
      _openItemActions(selected);
    }
  }

  void _showNextCard() {
    ref.read(discoveryProvider.notifier).showNextCard();
    setState(() => _dragOffset = Offset.zero);
    _prefetchMoreIfNeeded();
  }

  void _showPreviousCard() {
    ref.read(discoveryProvider.notifier).showPreviousCard();
    setState(() => _dragOffset = Offset.zero);
  }

  Future<void> _prefetchMoreIfNeeded() async {
    final state = ref.read(discoveryProvider);
    if (state.cards.length > 3 || !state.hasMore) return;

    final filters = ref.read(filterProvider);
    final location = await ref.read(currentLocationProvider.future);
    await ref.read(discoveryProvider.notifier).loadMore(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusKm: filters.radiusKm,
          size: filters.size,
          category: filters.category,
          shoeSizeEu: filters.shoeSizeEu,
        );
  }

  void _openItemActions(FeedItem item) {
    final cards = ref.read(discoveryProvider).cards;
    final isTopCard = cards.isNotEmpty && cards.first.id == item.id;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final previewHeight =
            (MediaQuery.sizeOf(sheetContext).height * 0.34).clamp(170.0, 280.0);
        var selectedPhotoIndex = 0;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.78,
              minChildSize: 0.55,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return SafeArea(
                  top: false,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      8,
                      20,
                      20 + MediaQuery.viewInsetsOf(sheetContext).bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: SizedBox(
                            height: previewHeight,
                            width: double.infinity,
                            child: item.photos.isNotEmpty
                                ? Stack(
                                    children: [
                                      PageView.builder(
                                        itemCount: item.photos.length,
                                        onPageChanged: (index) {
                                          setSheetState(
                                              () => selectedPhotoIndex = index);
                                        },
                                        itemBuilder: (context, index) {
                                          return Image.network(
                                            item.photos[index].url,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(
                                              color: theme.colorScheme
                                                  .surfaceContainerHighest,
                                              child: const Icon(
                                                Icons.checkroom_rounded,
                                                size: 48,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      if (item.photos.length > 1)
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.black.withAlpha(140),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              '${selectedPhotoIndex + 1}/${item.photos.length}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      if (item.photos.length > 1)
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 10,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: List.generate(
                                              item.photos.length,
                                              (index) => AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 180),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 3),
                                                width: selectedPhotoIndex == index
                                                    ? 16
                                                    : 7,
                                                height: 7,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(99),
                                                  color:
                                                      selectedPhotoIndex == index
                                                          ? Colors.white
                                                          : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : Container(
                                    color:
                                        theme.colorScheme.surfaceContainerHighest,
                                    child: const Icon(
                                      Icons.checkroom_rounded,
                                      size: 48,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          item.brand,
                          style: theme.textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(label: Text(item.category)),
                            Chip(label: Text(item.size.toUpperCase())),
                            if (item.shoeSizeEu != null)
                              Chip(
                                  label: Text(
                                      'EU ${item.shoeSizeEu!.toStringAsFixed(0)}')),
                            Chip(label: Text(item.condition)),
                            Chip(
                                label:
                                    Text('${item.distanceKm.toStringAsFixed(1)} km away')),
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
                              child: item.ownerPhotoUrl == null
                                  ? Text(
                                      item.ownerName.characters.first
                                          .toUpperCase())
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.ownerName,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  context.go('/profile/user/${item.ownerId}');
                                },
                                icon: const Icon(Icons.person_outline),
                                label: const Text('Open Profile'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.tonalIcon(
                                onPressed: () {
                                  Navigator.of(sheetContext).pop();
                                  _openChatForItem(item);
                                },
                                icon: const Icon(Icons.chat_bubble_outline),
                                label: const Text('Chat About Item'),
                              ),
                            ),
                          ],
                        ),
                        if (isTopCard) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                    _animateSwipe(item, 'pass');
                                  },
                                  icon: const Icon(Icons.close_rounded),
                                  label: const Text('Pass'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () {
                                    Navigator.of(sheetContext).pop();
                                    _animateSwipe(item, 'like');
                                  },
                                  icon: const Icon(Icons.favorite_rounded),
                                  label: const Text('Like'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);
    final cards = state.cards;
    final isLoading = state.isLoading;
    final showInitialLoader = _isBootstrappingFeed && cards.isEmpty;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
              child: Row(
                children: [
                  Text('Discover',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          )),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Search items',
                    onPressed: _openSearch,
                    icon: const Icon(Icons.search_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    tooltip: 'Open filters',
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Content
            Expanded(
              child: showInitialLoader || (isLoading && cards.isEmpty)
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && cards.isEmpty
                      ? _buildError(state.error!)
                      : cards.isEmpty
                          ? EmptyFeed(
                              onAdjustFilters: _openFilters,
                            )
                          : _buildSwipeStack(cards),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64,
                color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(120)),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(error,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
            const SizedBox(height: 20),
            FilledButton.tonal(
              onPressed: _loadFeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwipeStack(List<FeedItem> cards) {
    final screenWidth = MediaQuery.of(context).size.width;
    final canNavigateVertically = cards.length > 1;
    // Show up to 3 cards in stack
    final visibleCount = min(3, cards.length);

    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background cards
              for (int i = visibleCount - 1; i > 0; i--)
                Positioned(
                  top: 8.0 * i,
                  left: 20 + (4.0 * i),
                  right: 20 + (4.0 * i),
                  bottom: 8.0 * i,
                  child: Opacity(
                    opacity: 1.0 - (i * 0.15),
                    child: ItemCard(item: cards[i]),
                  ),
                ),
              // Top card (draggable)
              if (cards.isNotEmpty)
                Positioned(
                  top: 0,
                  left: 20,
                  right: 20,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _openItemActions(cards.first),
                    onPanStart: (_) => setState(() => _isDragging = true),
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta;
                      });
                    },
                    onPanEnd: (details) {
                      setState(() => _isDragging = false);
                      const verticalThreshold = 70.0;
                      const verticalVelocityThreshold = 700.0;
                      final horizontalThreshold = screenWidth * 0.3;
                      final velocity = details.velocity.pixelsPerSecond;
                      final horizontalDelta = _dragOffset.dx.abs();
                      final verticalDelta = _dragOffset.dy.abs();
                      final isVerticalDrag =
                          verticalDelta > (horizontalDelta * 0.7) ||
                          velocity.dy.abs() >
                              (velocity.dx.abs() * 1.2);

                      if (isVerticalDrag &&
                          canNavigateVertically &&
                          (verticalDelta > verticalThreshold ||
                              velocity.dy.abs() >
                                  verticalVelocityThreshold)) {
                        if (_dragOffset.dy < 0) {
                          _showNextCard();
                        } else {
                          _showPreviousCard();
                        }
                        return;
                      }

                      if (_dragOffset.dx.abs() > horizontalThreshold) {
                        final action =
                            _dragOffset.dx > 0 ? 'like' : 'pass';
                        _animateSwipe(cards.first, action);
                      } else {
                        // Snap back
                        setState(() => _dragOffset = Offset.zero);
                      }
                    },
                    child: Transform.translate(
                      offset: _dragOffset,
                      child: Transform.rotate(
                        angle: _dragOffset.dx / screenWidth * 0.4,
                        child: Stack(
                          children: [
                            ItemCard(item: cards.first),
                            // Like/Pass overlay
                            if (_isDragging && _dragOffset.dx.abs() > 30)
                              Positioned(
                                top: 24,
                                left: _dragOffset.dx > 0 ? 24 : null,
                                right: _dragOffset.dx < 0 ? 24 : null,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _dragOffset.dx > 0
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    _dragOffset.dx > 0 ? 'LIKE' : 'PASS',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            if (_isDragging &&
                                canNavigateVertically &&
                                _dragOffset.dy.abs() > 40 &&
                                _dragOffset.dy.abs() > _dragOffset.dx.abs())
                              Positioned(
                                top: _dragOffset.dy < 0 ? 24 : null,
                                bottom: _dragOffset.dy > 0 ? 24 : null,
                                left: 24,
                                right: 24,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    _dragOffset.dy < 0
                                        ? 'NEXT ITEM'
                                        : 'PREVIOUS ITEM',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Action buttons
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ActionButton(
                icon: Icons.skip_previous_rounded,
                tooltip: 'Previous item',
                color: Colors.amber,
                size: 44,
                iconSize: 24,
                onTap: cards.length > 1 ? _showPreviousCard : null,
              ),
              const SizedBox(width: 14),
              _ActionButton(
                icon: Icons.close_rounded,
                tooltip: 'Pass item',
                color: Colors.red,
                size: 56,
                iconSize: 28,
                onTap: cards.isEmpty
                    ? null
                    : () => _animateSwipe(cards.first, 'pass'),
              ),
              const SizedBox(width: 14),
              _ActionButton(
                icon: Icons.skip_next_rounded,
                tooltip: 'Next item',
                color: Colors.blue,
                size: 44,
                iconSize: 24,
                onTap: cards.length > 1 ? _showNextCard : null,
              ),
              const SizedBox(width: 14),
              _ActionButton(
                icon: Icons.favorite_rounded,
                tooltip: 'Like item',
                color: Colors.green,
                size: 56,
                iconSize: 28,
                onTap: cards.isEmpty
                    ? null
                    : () => _animateSwipe(cards.first, 'like'),
              ),
            ],
          ),
        ),
        Text(
          'Tip: swipe up/down to browse next or previous item',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.size,
    required this.iconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withAlpha(25),
              border: Border.all(color: color.withAlpha(80), width: 2),
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
        ),
      ),
    );
  }
}
