import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';
part 'message.g.dart';

@freezed
class Message with _$Message {
  const factory Message({
    required String id,
    required String matchId,
    required String senderId,
    required String text,
    DateTime? readAt,
    required DateTime createdAt,
    MessageSender? sender,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

@freezed
class MessageSender with _$MessageSender {
  const factory MessageSender({
    required String id,
    required String displayName,
    String? profilePhotoUrl,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}
