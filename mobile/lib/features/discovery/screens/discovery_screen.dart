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

class _DiscoveryScreenState extends ConsumerState<DiscoveryScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadFeed());
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
        );
  }

  void _onSwipeRight(FeedItem item) {
    ref.read(discoveryProvider.notifier).swipe(item.id, 'like');
    _nextCard();
  }

  void _onSwipeLeft(FeedItem item) {
    ref.read(discoveryProvider.notifier).swipe(item.id, 'pass');
    _nextCard();
  }

  void _nextCard() {
    setState(() => _currentIndex++);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discoveryProvider);
    final cards = state.cards;
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => FilterPanel(
                  onApply: () {
                    Navigator.of(context).pop();
                    setState(() => _currentIndex = 0);
                    _loadFeed();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cards.isEmpty || _currentIndex >= cards.length
              ? EmptyFeed(
                  onAdjustFilters: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (_) => FilterPanel(
                        onApply: () {
                          Navigator.of(context).pop();
                          setState(() => _currentIndex = 0);
                          _loadFeed();
                        },
                      ),
                    );
                  },
                )
              : _buildSwipeStack(cards),
    );
  }

  Widget _buildSwipeStack(List<FeedItem> cards) {
    final current = cards[_currentIndex];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity == null) return;
                if (details.primaryVelocity! > 0) {
                  _onSwipeRight(current);
                } else if (details.primaryVelocity! < 0) {
                  _onSwipeLeft(current);
                }
              },
              child: ItemCard(item: current),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FloatingActionButton(
                heroTag: 'pass',
                onPressed: () => _onSwipeLeft(current),
                backgroundColor: Colors.red.shade100,
                child: const Icon(Icons.close, color: Colors.red, size: 32),
              ),
              FloatingActionButton(
                heroTag: 'like',
                onPressed: () => _onSwipeRight(current),
                backgroundColor: Colors.green.shade100,
                child:
                    const Icon(Icons.favorite, color: Colors.green, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
