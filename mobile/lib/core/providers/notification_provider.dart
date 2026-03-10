import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

class NotificationState {
  final int unreadCount;
  final bool isLoading;
  final List<AppNotification> notifications;

  const NotificationState({
    this.unreadCount = 0,
    this.isLoading = false,
    this.notifications = const [],
  });

  NotificationState copyWith({
    int? unreadCount,
    bool? isLoading,
    List<AppNotification>? notifications,
  }) {
    return NotificationState(
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      notifications: notifications ?? this.notifications,
    );
  }
}

class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      data: json['data'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  final ApiClient _apiClient;

  NotificationNotifier(this._apiClient) : super(const NotificationState());

  Future<void> loadNotifications() async {
    state = state.copyWith(isLoading: true);
    try {
      final response = await _apiClient.dio.get('/notifications');
      final list = (response.data as List)
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      final unread = list.where((n) => !n.isRead).length;
      state = state.copyWith(
        notifications: list,
        unreadCount: unread,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.dio.patch('/notifications/$notificationId/read');
      state = state.copyWith(
        notifications: state.notifications
            .map((n) => n.id == notificationId
                ? AppNotification(
                    id: n.id,
                    type: n.type,
                    title: n.title,
                    body: n.body,
                    data: n.data,
                    isRead: true,
                    createdAt: n.createdAt,
                  )
                : n)
            .toList(),
        unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
      );
    } catch (_) {}
  }

  void clearUnread() {
    state = state.copyWith(unreadCount: 0);
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref.watch(apiClientProvider));
});
