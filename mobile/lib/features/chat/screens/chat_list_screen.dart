import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/match.dart';
import '../../matching/providers/matching_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(matchingProvider.notifier).loadMatches());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Show matches that are active (have potential for chat)
    final matchState = ref.watch(matchingProvider);
    final activeMatches = matchState.matches
        .where((m) =>
            m.status != MatchStatus.canceled &&
            m.status != MatchStatus.expired)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: matchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : activeMatches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64,
                          color: theme.colorScheme.primary.withAlpha(102)),
                      const SizedBox(height: 16),
                      Text('No conversations yet',
                          style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text('Match with someone to start chatting!',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: activeMatches.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, i) {
                    final match = activeMatches[i];
                    final otherBrand =
                        match.itemB?.brand ?? match.itemA?.brand ?? 'Match';
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(otherBrand[0].toUpperCase()),
                      ),
                      title: Text(otherBrand),
                      subtitle: Text(
                        'Status: ${match.status.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/matches/${match.id}/chat'),
                    );
                  },
                ),
    );
  }
}
