import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/location_service.dart';
import '../data/discovery_repository.dart';
import '../providers/discovery_provider.dart';
import '../providers/filter_provider.dart';
import '../widgets/item_card.dart';
import '../widgets/empty_feed.dart';
import '../widgets/filter_panel.dart';

class DiscoveryScreen extends ConsumerStatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  ConsumerState<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;
  late AnimationController _animController;
  FeedItem? _lastSwiped;

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
    final filters = ref.read(filterProvider);
    final location = await ref.read(currentLocationProvider.future);
    ref.read(discoveryProvider.notifier).loadFeed(
          latitude: location.latitude,
          longitude: location.longitude,
          radiusKm: filters.radiusKm,
          size: filters.size,
          category: filters.category,
          shoeSizeEu: filters.shoeSizeEu,
        );
  }

  void _onSwipe(FeedItem item, String action) async {
    _lastSwiped = item;
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
                  onPressed: () => Navigator.of(ctx).pop(),
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);
    final cards = state.cards;
    final isLoading = state.isLoading;

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
              child: isLoading && cards.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && cards.isEmpty
                      ? _buildError(state.error!)
                      : cards.isEmpty
                          ? EmptyFeed(onAdjustFilters: _openFilters)
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
                    onPanStart: (_) => setState(() => _isDragging = true),
                    onPanUpdate: (details) {
                      setState(() {
                        _dragOffset += details.delta;
                      });
                    },
                    onPanEnd: (details) {
                      setState(() => _isDragging = false);
                      final threshold = screenWidth * 0.3;
                      if (_dragOffset.dx.abs() > threshold) {
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
                icon: Icons.close_rounded,
                color: Colors.red,
                size: 56,
                iconSize: 28,
                onTap: cards.isEmpty
                    ? null
                    : () => _animateSwipe(cards.first, 'pass'),
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.undo_rounded,
                color: Colors.amber,
                size: 44,
                iconSize: 22,
                onTap: _lastSwiped != null ? _undoLastSwipe : null,
              ),
              const SizedBox(width: 24),
              _ActionButton(
                icon: Icons.favorite_rounded,
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
      ],
    );
  }

  void _undoLastSwipe() {
    if (_lastSwiped == null) return;
    ref.read(discoveryProvider.notifier).undoSwipe(_lastSwiped!);
    setState(() {
      _lastSwiped = null;
    });
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    required this.iconSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
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
    );
  }
}
