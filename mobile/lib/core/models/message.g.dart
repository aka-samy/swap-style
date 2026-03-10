// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MessageImpl _$$MessageImplFromJson(Map<String, dynamic> json) =>
    _$MessageImpl(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      sender: json['sender'] == null
          ? null
          : MessageSender.fromJson(json['sender'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MessageImplToJson(_$MessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'senderId': instance.senderId,
      'text': instance.text,
      'readAt': instance.readAt?.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'sender': instance.sender,
    };

_$MessageSenderImpl _$$MessageSenderImplFromJson(Map<String, dynamic> json) =>
    _$MessageSenderImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );

Map<String, dynamic> _$$MessageSenderImplToJson(_$MessageSenderImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'profilePhotoUrl': instance.profilePhotoUrl,
    };
