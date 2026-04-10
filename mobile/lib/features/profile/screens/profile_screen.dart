import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/rating.dart';
import '../../../core/models/item.dart';
import '../providers/profile_provider.dart';
import '../widgets/ratings_list.dart';
import '../../items/providers/items_provider.dart';
import '../../matching/providers/matching_provider.dart';

final _userRatingsProvider =
    FutureProvider.family<RatingsPage, String>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.dio.get('/users/$userId/ratings');
  final payload = response.data;

  if (payload is List) {
    final ratings = payload
        .map((e) => Rating.fromJson(e as Map<String, dynamic>))
        .toList();
    final avg = ratings.isEmpty
        ? 0.0
        : ratings.map((r) => r.score).reduce((a, b) => a + b) / ratings.length;
    return RatingsPage(ratings: ratings, average: avg);
  }

  if (payload is Map<String, dynamic>) {
    final ratingsJson =
        (payload['ratings'] as List<dynamic>?) ??
        (payload['data'] as List<dynamic>?) ??
        const <dynamic>[];

    final ratings = ratingsJson
        .whereType<Map<String, dynamic>>()
        .map(Rating.fromJson)
        .toList();

    final averageRaw = payload['average'];
    final average = averageRaw is num
        ? averageRaw.toDouble()
        : (ratings.isEmpty
            ? 0.0
            : ratings.map((r) => r.score).reduce((a, b) => a + b) /
                ratings.length);

    return RatingsPage(ratings: ratings, average: average);
  }

  return const RatingsPage(ratings: [], average: 0);
});

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isEditingProfile = false;
  bool _isSaving = false;
  File? _pickedPhoto;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _imagePicker = ImagePicker();

  String _safeInitial(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return '?';
    return cleaned.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      ref.read(profileProvider.notifier).loadProfile();
      ref.read(profileProvider.notifier).loadWishlist();
      ref.read(itemsProvider.notifier).loadMyItems();
      ref.read(matchingProvider.notifier).loadMatches();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _startEditing() {
    final user = ref.read(profileProvider).user;
    _nameController.text = user?.displayName ?? '';
    _bioController.text = user?.bio ?? '';
    _pickedPhoto = null;
    setState(() => _isEditingProfile = true);
  }

  void _cancelEditing() {
    setState(() {
      _isEditingProfile = false;
      _pickedPhoto = null;
    });
  }

  Future<void> _pickPhoto() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _pickedPhoto = File(picked.path));
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    try {
      // Upload photo if picked
      String? newPhotoUrl;
      if (_pickedPhoto != null) {
        newPhotoUrl = await ref
            .read(profileProvider.notifier)
            .uploadProfilePhoto(_pickedPhoto!.path);
        if (newPhotoUrl == null && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Photo upload failed. Profile saved without photo.'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }

      final data = <String, dynamic>{};
      final user = ref.read(profileProvider).user;
      if (_nameController.text.trim() != user?.displayName) {
        data['displayName'] = _nameController.text.trim();
      }
      if (_bioController.text.trim() != (user?.bio ?? '')) {
        data['bio'] = _bioController.text.trim();
      }
      if (newPhotoUrl != null) {
        data['profilePhotoUrl'] = newPhotoUrl;
      }
      if (data.isEmpty && _pickedPhoto == null) {
        setState(() {
          _isEditingProfile = false;
          _isSaving = false;
        });
        return;
      }
      if (data.isNotEmpty) {
        final ok = await ref.read(profileProvider.notifier).updateProfile(data);
        if (!ok && mounted) {
          final error = ref.read(profileProvider).error;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error ?? 'Failed to save profile'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          setState(() => _isSaving = false);
          return;
        }
      }
      if (mounted) {
        setState(() {
          _isEditingProfile = false;
          _pickedPhoto = null;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final profileState = ref.watch(profileProvider);
    final user = profileState.user;

    if (profileState.isLoading && user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (profileState.error != null && user == null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  profileState.error!,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  onPressed: () =>
                      ref.read(profileProvider.notifier).loadProfile(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverToBoxAdapter(
              child: _buildHeader(
                theme,
                user,
                authState,
                profileState.isLoading,
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                tabBar: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'Closet'),
                    Tab(text: 'History'),
                    Tab(text: 'Wishlist'),
                    Tab(text: 'Ratings'),
                  ],
                ),
                color: theme.colorScheme.surface,
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildClosetTab(theme),
              _buildHistoryTab(theme),
              _buildWishlistTab(theme),
              _buildRatingsTab(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    dynamic user,
    AuthState authState,
    bool isLoading,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              Text('Profile',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                onPressed: () => context.go('/profile/achievements'),
                icon: const Icon(Icons.emoji_events_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () => _showSettingsSheet(),
                icon: const Icon(Icons.settings_outlined),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avatar + info
          if (_isEditingProfile)
            _buildEditForm(theme)
          else
            _buildProfileInfo(theme, user, authState, isLoading),
        ],
      ),
    );
  }

  Widget _buildProfileInfo(
    ThemeData theme,
    dynamic user,
    AuthState authState,
    bool isLoading,
  ) {
    final resolvedName = (user?.displayName as String?)?.trim().isNotEmpty == true
        ? user.displayName as String
        : ((authState.displayName ?? '').trim().isNotEmpty
            ? authState.displayName!
            : (isLoading ? 'Loading profile...' : 'SwapStyle User'));

    return Column(
      children: [
        // Avatar
        Stack(
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: theme.colorScheme.primary.withAlpha(30),
              backgroundImage: user?.profilePhotoUrl != null
                  ? NetworkImage(user!.profilePhotoUrl!)
                  : null,
              child: user?.profilePhotoUrl == null
                  ? Text(
                    _safeInitial(resolvedName),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: _startEditing,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                  child: const Icon(Icons.edit, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          resolvedName,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (user?.bio != null && user!.bio!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            user.bio!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 12),
        // Verification + Rating row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _StatBadge(
              icon: Icons.star_rounded,
              iconColor: Colors.amber,
              value: user?.stats?.averageRating?.toStringAsFixed(1) ?? '--',
              label: '${user?.stats?.ratingCount ?? 0} reviews',
            ),
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.colorScheme.outlineVariant,
            ),
            _StatBadge(
              icon: user?.emailVerified == true
                  ? Icons.verified_rounded
                  : Icons.shield_outlined,
              iconColor: user?.emailVerified == true
                  ? Colors.green
                  : theme.colorScheme.onSurfaceVariant,
              value: user?.emailVerified == true ? 'Verified' : 'Unverified',
              label: 'Account',
            ),
            Container(
              width: 1,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: theme.colorScheme.outlineVariant,
            ),
            _StatBadge(
              icon: Icons.checkroom_rounded,
              iconColor: theme.colorScheme.primary,
              value: '${user?.stats?.itemCount ?? 0}',
              label: 'Items',
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEditForm(ThemeData theme) {
    final user = ref.read(profileProvider).user;
    return Column(
      children: [
        // Tappable avatar for photo change
        GestureDetector(
          onTap: _pickPhoto,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: theme.colorScheme.primary.withAlpha(30),
                backgroundImage: _pickedPhoto != null
                    ? FileImage(_pickedPhoto!)
                    : (user?.profilePhotoUrl != null
                        ? NetworkImage(user!.profilePhotoUrl!)
                        : null) as ImageProvider?,
                child: _pickedPhoto == null && user?.profilePhotoUrl == null
                    ? Text(
                        _safeInitial(user?.displayName),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                  child:
                      const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tap photo to change',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            hintText: 'Display name',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bioController,
          decoration: const InputDecoration(
            hintText: 'Bio (optional)',
            prefixIcon: Icon(Icons.info_outline),
          ),
          maxLines: 2,
          maxLength: 160,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _isSaving ? null : _cancelEditing,
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _isSaving ? null : _saveProfile,
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.pop(ctx);
                _startEditing();
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              onTap: () => Navigator.pop(ctx),
            ),
            if (ref.read(authProvider).isAdmin)
              ListTile(
                leading: const Icon(Icons.admin_panel_settings_outlined),
                title: const Text('Admin Panel'),
                onTap: () {
                  Navigator.pop(ctx);
                  context.go('/admin');
                },
              ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: theme.colorScheme.error),
              title: Text('Sign Out',
                  style: TextStyle(color: theme.colorScheme.error)),
              onTap: () {
                Navigator.pop(ctx);
                ref.read(authProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  ThemeData get theme => Theme.of(context);

  Widget _buildClosetTab(ThemeData theme) {
    final itemState = ref.watch(itemsProvider);
    if (itemState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (itemState.error != null && itemState.items.isEmpty) {
      return _emptyState(
        theme,
        icon: Icons.error_outline_rounded,
        title: 'Could not load closet',
        subtitle: itemState.error!,
        actionLabel: 'Retry',
        onAction: () => ref.read(itemsProvider.notifier).loadMyItems(),
      );
    }
    if (itemState.items.isEmpty) {
      return _emptyState(
        theme,
        icon: Icons.checkroom_rounded,
        title: 'No items yet',
        subtitle: 'Add your first clothing item to start swapping',
        actionLabel: 'Add Item',
        onAction: () => context.go('/closet/add'),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: itemState.items.length,
      itemBuilder: (ctx, i) {
        final item = itemState.items[i];
        final sizeLabel = item.category == ItemCategory.shoes && item.shoeSizeEu != null
          ? 'EU ${item.shoeSizeEu!.toStringAsFixed(0)}'
          : item.size.label;
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: item.photos.isNotEmpty
                    ? Image.network(item.photos.first.url, fit: BoxFit.cover)
                    : Center(
                        child: Icon(Icons.checkroom,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant
                                .withAlpha(100)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.brand,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    Text(
                      '${item.category.apiValue} • $sizeLabel',
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
  }

  Widget _buildHistoryTab(ThemeData theme) {
    final matchState = ref.watch(matchingProvider);
    final completed = matchState.matches
        .where((m) => m.status.name == 'completed')
        .toList();
    if (completed.isEmpty) {
      return _emptyState(
        theme,
        icon: Icons.swap_horiz_rounded,
        title: 'No swaps yet',
        subtitle: 'Complete a swap to see your history here',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: completed.length,
      itemBuilder: (ctx, i) {
        final match = completed[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.green.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: Colors.green, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${match.itemA?.brand ?? "Item"} ↔ ${match.itemB?.brand ?? "Item"}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    Text('Completed',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                        )),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWishlistTab(ThemeData theme) {
    final wishlist = ref.watch(profileProvider).wishlist;
    if (wishlist.isEmpty) {
      return _emptyState(
        theme,
        icon: Icons.bookmark_outline_rounded,
        title: 'Wishlist empty',
        subtitle: 'Add items you\'re looking for',
        actionLabel: 'Manage Wishlist',
        onAction: () => context.go('/profile/wishlist'),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemCount: wishlist.length,
      itemBuilder: (ctx, i) {
        final entry = wishlist[i];
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.surfaceContainerHighest,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bookmark_rounded,
                    color: theme.colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(entry.category,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    if (entry.size != null || entry.brand != null)
                      Text(
                        [
                          if (entry.size != null) 'Size: ${entry.size}',
                          if (entry.brand != null) entry.brand!,
                        ].join(' • '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () =>
                    ref.read(profileProvider.notifier).removeWishlistEntry(entry.id),
              ),
            ],
          ),
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
      error: (e, _) => _emptyState(
        theme,
        icon: Icons.error_outline_rounded,
        title: 'Could not load ratings',
        subtitle: 'Pull down to try again',
      ),
      data: (page) => page.ratings.isEmpty
          ? _emptyState(
              theme,
              icon: Icons.star_outline_rounded,
              title: 'No ratings yet',
              subtitle: 'Complete swaps to receive ratings',
            )
          : RatingsList(
              ratings: page.ratings,
              averageScore: page.average,
              total: page.ratings.length,
            ),
    );
  }

  Widget _emptyState(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56,
                color: theme.colorScheme.onSurfaceVariant.withAlpha(80)),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                )),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBadge({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(height: 4),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color color;

  _TabBarDelegate({required this.tabBar, required this.color});

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: color, child: tabBar);
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
