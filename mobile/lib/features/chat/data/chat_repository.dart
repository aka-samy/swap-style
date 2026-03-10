import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../core/api/api_client.dart';
import '../../../core/models/message.dart';

class ChatRepository {
  final ApiClient _client;
  IO.Socket? _socket;

  ChatRepository(this._client);

  Future<List<Message>> getMessages(
    String matchId, {
    int limit = 20,
    String? cursor,
  }) async {
    final response = await _client.dio.get(
      '/matches/$matchId/messages',
      queryParameters: {
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      },
    );
    return (response.data as List).map((e) => Message.fromJson(e)).toList();
  }

  Future<Message> sendMessage(String matchId, String text) async {
    final response = await _client.dio.post(
      '/matches/$matchId/messages',
      data: {'text': text},
    );
    return Message.fromJson(response.data);
  }

  Future<void> markRead(String matchId) async {
    await _client.dio.patch('/matches/$matchId/messages/read');
  }

  // Socket.IO real-time
  void connect(String serverUrl, String token) {
    _socket = IO.io(
      '$serverUrl/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .build(),
    );
  }

  void joinMatch(String matchId) {
    _socket?.emit('join_match', {'matchId': matchId});
  }

  void sendMessageViaSocket(String matchId, String text) {
    _socket?.emit('send_message', {'matchId': matchId, 'text': text});
  }

  void emitTyping(String matchId, bool isTyping) {
    _socket?.emit('typing', {'matchId': matchId, 'isTyping': isTyping});
  }

  void onNewMessage(void Function(Message) callback) {
    _socket?.on('new_message', (data) {
      callback(Message.fromJson(data as Map<String, dynamic>));
    });
  }

  void onTyping(void Function(String userId, bool isTyping) callback) {
    _socket?.on('typing', (data) {
      final d = data as Map<String, dynamic>;
      callback(d['userId'] as String, d['isTyping'] as bool);
    });
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
