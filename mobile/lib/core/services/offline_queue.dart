import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_client.dart';

/// A queued action that should be replayed when connectivity is restored.
class QueuedAction {
  final String method; // POST, PATCH, DELETE
  final String path;
  final Map<String, dynamic>? data;
  final DateTime queuedAt;

  QueuedAction({
    required this.method,
    required this.path,
    this.data,
    required this.queuedAt,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'path': path,
        'data': data,
        'queuedAt': queuedAt.toIso8601String(),
      };

  factory QueuedAction.fromJson(Map<String, dynamic> json) => QueuedAction(
        method: json['method'],
        path: json['path'],
        data: json['data'] as Map<String, dynamic>?,
        queuedAt: DateTime.parse(json['queuedAt']),
      );
}

class OfflineQueueNotifier extends StateNotifier<List<QueuedAction>> {
  final ApiClient _apiClient;
  static const _storageKey = 'offline_action_queue';

  OfflineQueueNotifier(this._apiClient) : super([]) {
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final list = (jsonDecode(raw) as List)
          .map((e) => QueuedAction.fromJson(e as Map<String, dynamic>))
          .toList();
      state = list;
    }
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(state.map((a) => a.toJson()).toList());
    await prefs.setString(_storageKey, raw);
  }

  /// Queue an action for later replay.
  Future<void> enqueue(String method, String path,
      [Map<String, dynamic>? data]) async {
    final action = QueuedAction(
      method: method,
      path: path,
      data: data,
      queuedAt: DateTime.now(),
    );
    state = [...state, action];
    await _saveToStorage();
  }

  /// Replay all queued actions. Call this when connectivity is restored.
  Future<int> replayAll() async {
    if (state.isEmpty) return 0;

    int replayed = 0;
    final remaining = <QueuedAction>[];

    for (final action in state) {
      try {
        switch (action.method) {
          case 'POST':
            await _apiClient.dio.post(action.path, data: action.data);
            break;
          case 'PATCH':
            await _apiClient.dio.patch(action.path, data: action.data);
            break;
          case 'DELETE':
            await _apiClient.dio.delete(action.path);
            break;
        }
        replayed++;
      } catch (_) {
        remaining.add(action);
      }
    }

    state = remaining;
    await _saveToStorage();
    return replayed;
  }

  int get pendingCount => state.length;
}

final offlineQueueProvider =
    StateNotifierProvider<OfflineQueueNotifier, List<QueuedAction>>((ref) {
  return OfflineQueueNotifier(ref.watch(apiClientProvider));
});
