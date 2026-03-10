// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Message _$MessageFromJson(Map<String, dynamic> json) {
  return _Message.fromJson(json);
}

/// @nodoc
mixin _$Message {
  String get id => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;
  String get text => throw _privateConstructorUsedError;
  DateTime? get readAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  MessageSender? get sender => throw _privateConstructorUsedError;

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageCopyWith<Message> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageCopyWith<$Res> {
  factory $MessageCopyWith(Message value, $Res Function(Message) then) =
      _$MessageCopyWithImpl<$Res, Message>;
  @useResult
  $Res call(
      {String id,
      String matchId,
      String senderId,
      String text,
      DateTime? readAt,
      DateTime createdAt,
      MessageSender? sender});

  $MessageSenderCopyWith<$Res>? get sender;
}

/// @nodoc
class _$MessageCopyWithImpl<$Res, $Val extends Message>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? senderId = null,
    Object? text = null,
    Object? readAt = freezed,
    Object? createdAt = null,
    Object? sender = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender?,
    ) as $Val);
  }

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MessageSenderCopyWith<$Res>? get sender {
    if (_value.sender == null) {
      return null;
    }

    return $MessageSenderCopyWith<$Res>(_value.sender!, (value) {
      return _then(_value.copyWith(sender: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MessageImplCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$$MessageImplCopyWith(
          _$MessageImpl value, $Res Function(_$MessageImpl) then) =
      __$$MessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String matchId,
      String senderId,
      String text,
      DateTime? readAt,
      DateTime createdAt,
      MessageSender? sender});

  @override
  $MessageSenderCopyWith<$Res>? get sender;
}

/// @nodoc
class __$$MessageImplCopyWithImpl<$Res>
    extends _$MessageCopyWithImpl<$Res, _$MessageImpl>
    implements _$$MessageImplCopyWith<$Res> {
  __$$MessageImplCopyWithImpl(
      _$MessageImpl _value, $Res Function(_$MessageImpl) _then)
      : super(_value, _then);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? senderId = null,
    Object? text = null,
    Object? readAt = freezed,
    Object? createdAt = null,
    Object? sender = freezed,
  }) {
    return _then(_$MessageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _value.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      readAt: freezed == readAt
          ? _value.readAt
          : readAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      sender: freezed == sender
          ? _value.sender
          : sender // ignore: cast_nullable_to_non_nullable
              as MessageSender?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageImpl implements _Message {
  const _$MessageImpl(
      {required this.id,
      required this.matchId,
      required this.senderId,
      required this.text,
      this.readAt,
      required this.createdAt,
      this.sender});

  factory _$MessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageImplFromJson(json);

  @override
  final String id;
  @override
  final String matchId;
  @override
  final String senderId;
  @override
  final String text;
  @override
  final DateTime? readAt;
  @override
  final DateTime createdAt;
  @override
  final MessageSender? sender;

  @override
  String toString() {
    return 'Message(id: $id, matchId: $matchId, senderId: $senderId, text: $text, readAt: $readAt, createdAt: $createdAt, sender: $sender)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.readAt, readAt) || other.readAt == readAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.sender, sender) || other.sender == sender));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, matchId, senderId, text, readAt, createdAt, sender);

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      __$$MessageImplCopyWithImpl<_$MessageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageImplToJson(
      this,
    );
  }
}

abstract class _Message implements Message {
  const factory _Message(
      {required final String id,
      required final String matchId,
      required final String senderId,
      required final String text,
      final DateTime? readAt,
      required final DateTime createdAt,
      final MessageSender? sender}) = _$MessageImpl;

  factory _Message.fromJson(Map<String, dynamic> json) = _$MessageImpl.fromJson;

  @override
  String get id;
  @override
  String get matchId;
  @override
  String get senderId;
  @override
  String get text;
  @override
  DateTime? get readAt;
  @override
  DateTime get createdAt;
  @override
  MessageSender? get sender;

  /// Create a copy of Message
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageImplCopyWith<_$MessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MessageSender _$MessageSenderFromJson(Map<String, dynamic> json) {
  return _MessageSender.fromJson(json);
}

/// @nodoc
mixin _$MessageSender {
  String get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this MessageSender to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MessageSenderCopyWith<MessageSender> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MessageSenderCopyWith<$Res> {
  factory $MessageSenderCopyWith(
          MessageSender value, $Res Function(MessageSender) then) =
      _$MessageSenderCopyWithImpl<$Res, MessageSender>;
  @useResult
  $Res call({String id, String displayName, String? profilePhotoUrl});
}

/// @nodoc
class _$MessageSenderCopyWithImpl<$Res, $Val extends MessageSender>
    implements $MessageSenderCopyWith<$Res> {
  _$MessageSenderCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MessageSenderImplCopyWith<$Res>
    implements $MessageSenderCopyWith<$Res> {
  factory _$$MessageSenderImplCopyWith(
          _$MessageSenderImpl value, $Res Function(_$MessageSenderImpl) then) =
      __$$MessageSenderImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String displayName, String? profilePhotoUrl});
}

/// @nodoc
class __$$MessageSenderImplCopyWithImpl<$Res>
    extends _$MessageSenderCopyWithImpl<$Res, _$MessageSenderImpl>
    implements _$$MessageSenderImplCopyWith<$Res> {
  __$$MessageSenderImplCopyWithImpl(
      _$MessageSenderImpl _value, $Res Function(_$MessageSenderImpl) _then)
      : super(_value, _then);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_$MessageSenderImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      displayName: null == displayName
          ? _value.displayName
          : displayName // ignore: cast_nullable_to_non_nullable
              as String,
      profilePhotoUrl: freezed == profilePhotoUrl
          ? _value.profilePhotoUrl
          : profilePhotoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MessageSenderImpl implements _MessageSender {
  const _$MessageSenderImpl(
      {required this.id, required this.displayName, this.profilePhotoUrl});

  factory _$MessageSenderImpl.fromJson(Map<String, dynamic> json) =>
      _$$MessageSenderImplFromJson(json);

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'MessageSender(id: $id, displayName: $displayName, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MessageSenderImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, displayName, profilePhotoUrl);

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      __$$MessageSenderImplCopyWithImpl<_$MessageSenderImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MessageSenderImplToJson(
      this,
    );
  }
}

abstract class _MessageSender implements MessageSender {
  const factory _MessageSender(
      {required final String id,
      required final String displayName,
      final String? profilePhotoUrl}) = _$MessageSenderImpl;

  factory _MessageSender.fromJson(Map<String, dynamic> json) =
      _$MessageSenderImpl.fromJson;

  @override
  String get id;
  @override
  String get displayName;
  @override
  String? get profilePhotoUrl;

  /// Create a copy of MessageSender
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MessageSenderImplCopyWith<_$MessageSenderImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
