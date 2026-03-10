import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/rating.dart';
import '../providers/profile_provider.dart';
import '../widgets/ratings_list.dart';
import '../../items/providers/items_provider.dart';
import '../../matching/providers/matching_provider.dart';

final _userRatingsProvider =
    FutureProvider.family<RatingsPage, String>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.dio.get('/users/$userId/ratings');
  final ratings = (response.data as List)
      .map((e) => Rating.fromJson(e as Map<String, dynamic>))
      .toList();
  // Compute average from the ratings list
  final avg = ratings.isEmpty
      ? 0.0
      : ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;
  return RatingsPage(ratings: ratings, average: avg);
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(profileProvider.notifier).loadWishlist();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events_outlined),
            onPressed: () => context.go('/profile/achievements'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider.notifier).signOut(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Profile header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  backgroundImage: user?.profilePhotoUrl != null
                      ? NetworkImage(user!.profilePhotoUrl!)
                      : null,
                  child: user?.profilePhotoUrl == null
                      ? Icon(Icons.person,
                          size: 36,
                          color: theme.colorScheme.onPrimaryContainer)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Loading...',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${user?.stats?.averageRating?.toStringAsFixed(1) ?? '--'} (${user?.stats?.ratingCount ?? 0} reviews)',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Closet'),
              Tab(text: 'History'),
              Tab(text: 'Wishlist'),
              Tab(text: 'Ratings'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildClosetTab(theme),
                _buildHistoryTab(theme),
                _buildWishlistTab(theme),
                _buildRatingsTab(theme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClosetTab(ThemeData theme) {
    final itemState = ref.watch(itemsProvider);
    if (itemState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (itemState.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.checkroom, size: 64,
                color: theme.colorScheme.primary.withAlpha(102)),
            const SizedBox(height: 16),
            const Text('No items in your closet yet'),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.go('/closet/add'),
              icon: const Icon(Icons.add),
              label: const Text('List Your First Item'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: itemState.items.length,
      itemBuilder: (ctx, i) {
        final item = itemState.items[i];
        return ListTile(
          leading: const Icon(Icons.checkroom),
          title: Text(item.brand),
          subtitle: Text('${item.category.name} • ${item.size.name}'),
        );
      },
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    final matchState = ref.watch(matchingProvider);
    final completed = matchState.matches
        .where((m) => m.status.name == 'completed')
        .toList();
    if (completed.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.swap_horiz, size: 64,
                color: theme.colorScheme.primary.withAlpha(102)),
            const SizedBox(height: 16),
            const Text('No completed swaps yet'),
            const SizedBox(height: 8),
            Text('Complete a swap to see your history here',
                style: theme.textTheme.bodySmall),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: completed.length,
      itemBuilder: (ctx, i) {
        final match = completed[i];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(
              '${match.itemA?.brand ?? "Item"} ↔ ${match.itemB?.brand ?? "Item"}'),
          subtitle: Text(match.status.name),
        );
      },
    );
  }

  Widget _buildWishlistTab(ThemeData theme) {
    final wishlist = ref.watch(profileProvider).wishlist;
    if (wishlist.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Wishlist is empty', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: () => context.go('/profile/wishlist'),
              icon: const Icon(Icons.add),
              label: const Text('Manage Wishlist'),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      itemCount: wishlist.length,
      itemBuilder: (ctx, i) {
        final entry = wishlist[i];
        return ListTile(
          title: Text(entry.category),
          subtitle: Text([
            if (entry.size != null) 'Size: ${entry.size}',
            if (entry.brand != null) entry.brand!,
          ].join(' • ')),
        );
      },
    );
  }

  Widget _buildRatingsTab(ThemeData theme) {
    final userId = ref.watch(authProvider).userId;
    if (userId == null) {
      return const Center(child: Text('Sign in to see ratings'));
    }
    final ratingsAsync = ref.watch(_userRatingsProvider(userId));
    return ratingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load ratings')),
      data: (page) => RatingsList(
        ratings: page.ratings,
        averageScore: page.average,
        total: page.ratings.length,
      ),
    );
  }
}
