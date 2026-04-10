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
  String _safeInitial(String? value) {
    final cleaned = value?.trim();
    if (cleaned == null || cleaned.isEmpty) return '?';
    return cleaned.substring(0, 1).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(matchingProvider.notifier).loadMatches());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchState = ref.watch(matchingProvider);
    final activeMatches = matchState.matches
        .where((m) =>
            m.status != MatchStatus.canceled &&
            m.status != MatchStatus.expired)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text('Messages',
                  style: theme.textTheme.headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: matchState.isLoading && activeMatches.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : activeMatches.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.chat_bubble_outline_rounded,
                                      size: 40,
                                      color: theme.colorScheme.primary.withAlpha(120)),
                                ),
                                const SizedBox(height: 20),
                                Text('No conversations yet',
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 8),
                                Text('Match with someone to start chatting!',
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    )),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 4),
                          itemCount: activeMatches.length,
                          itemBuilder: (ctx, i) {
                            final match = activeMatches[i];
                            final otherBrand = match.itemB?.brand ??
                                match.itemA?.brand ??
                                'Match';
                            return GestureDetector(
                              onTap: () =>
                                  context.go('/matches/${match.id}/chat'),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  color: theme.colorScheme
                                      .surfaceContainerHighest,
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor: theme
                                          .colorScheme.primary
                                          .withAlpha(25),
                                      child: Text(
                                        _safeInitial(otherBrand),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(otherBrand,
                                              style: theme
                                                  .textTheme.bodyMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600)),
                                          Text(
                                            match.status.name,
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.chevron_right_rounded,
                                        color: theme
                                            .colorScheme.onSurfaceVariant),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
