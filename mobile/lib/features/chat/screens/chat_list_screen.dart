import 'dart:core' hide Match;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/match.dart';
import '../providers/chat_provider.dart';
import '../../matching/providers/matching_provider.dart';

enum ChatFilter {
  all('All'),
  active('Active'),
  pending('Pending'),
  completed('Completed');

  final String label;
  const ChatFilter(this.label);
}

class _ChatListItem extends ConsumerStatefulWidget {
  final Match match;
  final String otherBrand;
  final ThemeData theme;
  final VoidCallback onTap;

  const _ChatListItem({
    required this.match,
    required this.otherBrand,
    required this.theme,
    required this.onTap,
  });

  @override
  ConsumerState<_ChatListItem> createState() => _ChatListItemState();
}

class _ChatListItemState extends ConsumerState<_ChatListItem> {
  String? _lastMessage;
  DateTime? _lastMessageTime;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLastMessage();
  }

  Future<void> _loadLastMessage() async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      final msg = await repo.getLastMessage(widget.match.id);
      
      if (mounted) {
        setState(() {
          if (msg != null) {
            _lastMessage = msg.text;
            _lastMessageTime = msg.createdAt;
          }
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}';
  }

  Widget _buildStatusIndicator(MatchStatus status) {
    Color color;
    switch (status) {
      case MatchStatus.agreed:
      case MatchStatus.completed:
        color = Colors.green;
      case MatchStatus.pending:
      case MatchStatus.awaitingConfirmation:
        color = Colors.orange;
      case MatchStatus.negotiating:
        color = widget.theme.colorScheme.primary;
      default:
        color = widget.theme.colorScheme.onSurfaceVariant;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: widget.theme.scaffoldBackgroundColor, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.theme.shadowColor.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: widget.onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.theme.colorScheme.primary.withAlpha(200),
                            widget.theme.colorScheme.secondary.withAlpha(200),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        widget.otherBrand.isNotEmpty ? widget.otherBrand[0].toUpperCase() : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildStatusIndicator(widget.match.status),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.otherBrand,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 17,
                              ),
                            ),
                          ),
                          if (_lastMessageTime != null)
                            Text(
                              _formatTime(_lastMessageTime!),
                              style: widget.theme.textTheme.labelMedium?.copyWith(
                                color: widget.theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      _loading
                          ? SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: widget.theme.colorScheme.primary.withAlpha(100),
                              ),
                            )
                          : Text(
                              _lastMessage ?? 'Status: ${widget.match.status.name}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: widget.theme.textTheme.bodyMedium?.copyWith(
                                color: _lastMessage != null
                                    ? widget.theme.colorScheme.onSurfaceVariant
                                    : widget.theme.colorScheme.primary,
                                fontWeight: _lastMessage != null ? FontWeight.w500 : FontWeight.w600,
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  int _refreshKey = 0;
  ChatFilter _selectedFilter = ChatFilter.all;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(matchingProvider.notifier).loadMatches());
  }

  Future<void> _navigateToChat(String matchId) async {
    await context.push('/matches/$matchId/chat');
    if (mounted) {
      setState(() {
        _refreshKey++;
      });
      ref.read(matchingProvider.notifier).loadMatches();
    }
  }

  bool _matchesFilter(Match match, ChatFilter filter) {
    switch (filter) {
      case ChatFilter.all:
        return true;
      case ChatFilter.active:
        return match.status == MatchStatus.negotiating;
      case ChatFilter.pending:
        return match.status == MatchStatus.pending || 
               match.status == MatchStatus.awaitingConfirmation;
      case ChatFilter.completed:
        return match.status == MatchStatus.agreed || 
               match.status == MatchStatus.completed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchState = ref.watch(matchingProvider);
    
    final activeMatches = matchState.matches
        .where((m) =>
            m.status != MatchStatus.canceled &&
            m.status != MatchStatus.expired &&
            _matchesFilter(m, _selectedFilter))
        .toList()
      ..sort((a, b) => b.lastActivityAt.compareTo(a.lastActivityAt));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                'Messages',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: ChatFilter.values.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedFilter = filter);
                        }
                      },
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      selectedColor: theme.colorScheme.primary.withAlpha(25),
                      labelStyle: theme.textTheme.labelLarge?.copyWith(
                        color: isSelected 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected 
                              ? theme.colorScheme.primary.withAlpha(100) 
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      showCheckmark: false,
                    ),
                  );
                }).toList(),
              ),
            ),
            
            Expanded(
              child: matchState.isLoading && activeMatches.isEmpty
                  ? Center(
                      child: CircularProgressIndicator(
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : activeMatches.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary.withAlpha(30),
                                        theme.colorScheme.secondary.withAlpha(30),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.chat_rounded,
                                    size: 48,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'No conversations found',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedFilter == ChatFilter.all
                                      ? 'Match with someone to start chatting and negotiating your swaps!'
                                      : 'You have no chats matching this filter.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          key: ValueKey('$_refreshKey-${_selectedFilter.name}'),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: activeMatches.length,
                          itemBuilder: (ctx, i) {
                            final match = activeMatches[i];
                            final otherBrand = match.itemB?.brand ??
                                match.itemA?.brand ??
                                'Match';
                            return _ChatListItem(
                              match: match,
                              otherBrand: otherBrand,
                              theme: theme,
                              onTap: () => _navigateToChat(match.id),
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

