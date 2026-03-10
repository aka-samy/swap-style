import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/user.dart';
import '../data/profile_repository.dart';

final _publicProfileProvider =
    FutureProvider.family<User, String>((ref, userId) async {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client).getPublicProfile(userId);
});

class PublicProfileScreen extends ConsumerWidget {
  final String userId;
  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(_publicProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'report') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              } else if (value == 'block') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'report', child: Text('Report')),
              const PopupMenuItem(value: 'block', child: Text('Block')),
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
            const Center(child: Text('No public items yet')),
          ],
        ),
      ),
    );
  }
}
