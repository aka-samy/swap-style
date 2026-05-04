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

  Future<Message?> getLastMessage(String matchId) async {
    final response = await _client.dio.get(
      '/matches/$matchId/messages',
      queryParameters: {'limit': 1},
    );
    final list = (response.data as List).map((e) => Message.fromJson(e)).toList();
    return list.isNotEmpty ? list.first : null;
  }

  Future<void> markRead(String matchId) async {
    await _client.dio.patch('/matches/$matchId/messages/read');
  }

  String _buildSocketBaseUrl(String serverUrl) {
    final uri = Uri.parse(serverUrl);
    final hasCustomPort = uri.port != 80 && uri.port != 443;
    return '${uri.scheme}://${uri.host}${hasCustomPort ? ':${uri.port}' : ''}';
  }

  // Socket.IO real-time
  void connect(String serverUrl, String token) {
    final socketBaseUrl = _buildSocketBaseUrl(serverUrl);

    _socket?.disconnect();
    _socket?.dispose();

    _socket = IO.io(
      '$socketBaseUrl/chat',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(8)
          .setReconnectionDelay(1200)
          .setTimeout(12000)
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

  void onConnected(void Function() callback) {
    _socket?.onConnect((_) => callback());
  }

  void onDisconnected(void Function(String reason) callback) {
    _socket?.onDisconnect((reason) => callback(reason.toString()));
  }

  void onConnectionError(void Function(String message) callback) {
    _socket?.onConnectError((error) => callback(error.toString()));
    _socket?.onError((error) => callback(error.toString()));
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
