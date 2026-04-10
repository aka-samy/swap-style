import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_error_mapper.dart';

class NotificationItem {
  final String id;
  final String type;
  final String title;
  final String body;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.read,
    required this.createdAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now();
    final isRead = (json['read'] == true) || json['readAt'] != null;
    return NotificationItem(
      id: json['id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      read: isRead,
      createdAt: createdAt,
      data: json['data'],
    );
  }
}

class NotificationsState {
  final List<NotificationItem> items;
  final bool isLoading;
  final String? error;

  const NotificationsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  NotificationsState copyWith({
    List<NotificationItem>? items,
    bool? isLoading,
    String? error,
  }) => NotificationsState(
    items: items ?? this.items,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final ApiClient _client;
  NotificationsNotifier(this._client) : super(const NotificationsState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _client.dio.get('/notifications');
      final payload = response.data;
      final listPayload = payload is List
          ? payload
          : (payload as Map<String, dynamic>)['data'] as List<dynamic>? ??
              <dynamic>[];

      final list = listPayload
          .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(items: list, isLoading: false);
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load notifications',
        ),
      );
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _client.dio.patch('/notifications/$id/read');
      state = state.copyWith(
        items: state.items.map((n) =>
          n.id == id ? NotificationItem(
            id: n.id, type: n.type, title: n.title, body: n.body,
            read: true, createdAt: n.createdAt, data: n.data,
          ) : n
        ).toList(),
      );
    } catch (_) {}
  }

  Future<void> markAllRead() async {
    try {
      await _client.dio.patch('/notifications/read-all');
      state = state.copyWith(
        items: state.items.map((n) => NotificationItem(
          id: n.id, type: n.type, title: n.title, body: n.body,
          read: true, createdAt: n.createdAt, data: n.data,
        )).toList(),
      );
    } catch (_) {}
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref.watch(apiClientProvider));
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(notificationsProvider.notifier).loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(notificationsProvider);
    final items = state.items;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
              child: Row(
                children: [
                  Text('Notifications',
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Spacer(),
                  if (items.any((n) => !n.read))
                    TextButton(
                      onPressed: () => ref
                          .read(notificationsProvider.notifier)
                          .markAllRead(),
                      child: const Text('Mark all read'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: state.isLoading && items.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null && items.isEmpty
                      ? _buildError(theme, state.error!)
                      : items.isEmpty
                          ? _buildEmpty(theme)
                          : RefreshIndicator(
                              onRefresh: () => ref
                                  .read(notificationsProvider.notifier)
                                  .loadNotifications(),
                              child: ListView.separated(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 4),
                                itemCount: items.length,
                                itemBuilder: (ctx, i) =>
                                    _NotificationTile(item: items[i]),
                              ),
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(ThemeData theme) {
    return Center(
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
              child: Icon(Icons.notifications_none_rounded,
                  size: 40,
                  color: theme.colorScheme.primary.withAlpha(120)),
            ),
            const SizedBox(height: 20),
            Text('All caught up!',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              'You\'ll see match updates and messages here',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(ThemeData theme, String error) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 48, color: theme.colorScheme.onSurfaceVariant.withAlpha(100)),
          const SizedBox(height: 12),
          Text('Could not load notifications',
              style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: () =>
                ref.read(notificationsProvider.notifier).loadNotifications(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationItem item;
  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final (IconData icon, Color color) = switch (item.type) {
      'match' => (Icons.favorite_rounded, Colors.pink),
      'message' => (Icons.chat_bubble_rounded, Colors.blue),
      'swap_complete' => (Icons.check_circle_rounded, Colors.green),
      'counter_offer' => (Icons.compare_arrows_rounded, Colors.orange),
      'badge' => (Icons.military_tech_rounded, Colors.amber),
      _ => (Icons.notifications_rounded, theme.colorScheme.primary),
    };

    return GestureDetector(
      onTap: () {
        if (!item.read) {
          ref.read(notificationsProvider.notifier).markRead(item.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: item.read
              ? Colors.transparent
              : theme.colorScheme.primary.withAlpha(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: item.read ? FontWeight.normal : FontWeight.w600,
                      )),
                  if (item.body.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(item.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )),
                  ],
                  const SizedBox(height: 4),
                  Text(_timeAgo(item.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                ],
              ),
            ),
            if (!item.read)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
