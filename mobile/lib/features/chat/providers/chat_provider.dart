import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/message.dart';
import '../data/chat_repository.dart';

class ChatState {
  final List<Message> messages;
  final bool isLoading;
  final bool isConnected;
  final Map<String, bool> typingUsers; // userId -> isTyping
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isConnected = false,
    this.typingUsers = const {},
    this.error,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isLoading,
    bool? isConnected,
    Map<String, bool>? typingUsers,
    String? error,
  }) =>
      ChatState(
        messages: messages ?? this.messages,
        isLoading: isLoading ?? this.isLoading,
        isConnected: isConnected ?? this.isConnected,
        typingUsers: typingUsers ?? this.typingUsers,
        error: error,
      );
}

class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final ApiClient _apiClient;
  final String matchId;

  ChatNotifier(this._repository, this._apiClient, this.matchId)
      : super(const ChatState());

  void _handleNewMessage(Message message) {
    if (message.matchId == matchId) {
      if (!state.messages.any((m) => m.id == message.id)) {
        state = state.copyWith(messages: [message, ...state.messages]);
      }
    }
  }

  void _handleTyping(String userId, bool isTyping) {
    final updated = Map<String, bool>.from(state.typingUsers);
    if (isTyping) {
      updated[userId] = true;
    } else {
      updated.remove(userId);
    }
    state = state.copyWith(typingUsers: updated);
  }

  Future<void> loadMessages({String? cursor}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final messages = await _repository.getMessages(matchId, cursor: cursor);
      state = state.copyWith(
        messages: cursor == null
            ? messages
            : [...state.messages, ...messages],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> send(String text) async {
    try {
      final message = await _repository.sendMessage(matchId, text);
      if (!state.messages.any((m) => m.id == message.id)) {
        state = state.copyWith(messages: [message, ...state.messages]);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void setTyping(bool isTyping) {
    _repository.emitTyping(matchId, isTyping);
  }

  Future<void> markRead() async {
    await _repository.markRead(matchId).catchError((_) {});
  }

  Future<Message?> getLastMessage(String matchId) async {
    return _repository.getLastMessage(matchId);
  }

  Future<void> joinRoom() async {
    state = state.copyWith(isConnected: false, error: null);

    var token = _apiClient.authToken;
    if (token == null || token.isEmpty) {
      token = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (token != null && token.isNotEmpty) {
        _apiClient.setAuthToken(token);
      }
    }

    if (token == null || token.isEmpty) {
      state = state.copyWith(
        isConnected: false,
        error: 'Realtime chat unavailable: authentication token missing.',
      );
      return;
    }

    _repository.connect(_apiClient.serverUrl, token);
    _repository.onNewMessage(_handleNewMessage);
    _repository.onTyping(_handleTyping);

    _repository.onConnected(() {
      state = state.copyWith(isConnected: true, error: null);
      _repository.joinMatch(matchId);
    });

    _repository.onDisconnected((_) {
      state = state.copyWith(isConnected: false);
    });

    _repository.onConnectionError((message) {
      state = state.copyWith(
        isConnected: false,
        error: 'Realtime chat unavailable. Messages still work over REST.',
      );
    });
  }

  @override
  void dispose() {
    _repository.disconnect();
    super.dispose();
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(apiClientProvider));
});

final chatProvider = StateNotifierProvider.family<
    ChatNotifier, ChatState, String>((ref, matchId) {
  return ChatNotifier(
    ref.watch(chatRepositoryProvider),
    ref.watch(apiClientProvider),
    matchId,
  );
});
