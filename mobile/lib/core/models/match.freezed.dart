// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Match _$MatchFromJson(Map<String, dynamic> json) {
  return _Match.fromJson(json);
}

/// @nodoc
mixin _$Match {
  String get id => throw _privateConstructorUsedError;
  String get userAId => throw _privateConstructorUsedError;
  String get userBId => throw _privateConstructorUsedError;
  String get itemAId => throw _privateConstructorUsedError;
  String get itemBId => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  bool get userAConfirmed => throw _privateConstructorUsedError;
  bool get userBConfirmed => throw _privateConstructorUsedError;
  DateTime? get completedAt => throw _privateConstructorUsedError;
  DateTime? get expiredAt => throw _privateConstructorUsedError;
  DateTime get lastActivityAt => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  MatchUser? get userA => throw _privateConstructorUsedError;
  MatchUser? get userB => throw _privateConstructorUsedError;
  MatchItem? get itemA => throw _privateConstructorUsedError;
  MatchItem? get itemB => throw _privateConstructorUsedError;

  /// Serializes this Match to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call(
      {String id,
      String userAId,
      String userBId,
      String itemAId,
      String itemBId,
      MatchStatus status,
      bool userAConfirmed,
      bool userBConfirmed,
      DateTime? completedAt,
      DateTime? expiredAt,
      DateTime lastActivityAt,
      DateTime createdAt,
      MatchUser? userA,
      MatchUser? userB,
      MatchItem? itemA,
      MatchItem? itemB});

  $MatchUserCopyWith<$Res>? get userA;
  $MatchUserCopyWith<$Res>? get userB;
  $MatchItemCopyWith<$Res>? get itemA;
  $MatchItemCopyWith<$Res>? get itemB;
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userAId = null,
    Object? userBId = null,
    Object? itemAId = null,
    Object? itemBId = null,
    Object? status = null,
    Object? userAConfirmed = null,
    Object? userBConfirmed = null,
    Object? completedAt = freezed,
    Object? expiredAt = freezed,
    Object? lastActivityAt = null,
    Object? createdAt = null,
    Object? userA = freezed,
    Object? userB = freezed,
    Object? itemA = freezed,
    Object? itemB = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userAId: null == userAId
          ? _value.userAId
          : userAId // ignore: cast_nullable_to_non_nullable
              as String,
      userBId: null == userBId
          ? _value.userBId
          : userBId // ignore: cast_nullable_to_non_nullable
              as String,
      itemAId: null == itemAId
          ? _value.itemAId
          : itemAId // ignore: cast_nullable_to_non_nullable
              as String,
      itemBId: null == itemBId
          ? _value.itemBId
          : itemBId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      userAConfirmed: null == userAConfirmed
          ? _value.userAConfirmed
          : userAConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      userBConfirmed: null == userBConfirmed
          ? _value.userBConfirmed
          : userBConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userA: freezed == userA
          ? _value.userA
          : userA // ignore: cast_nullable_to_non_nullable
              as MatchUser?,
      userB: freezed == userB
          ? _value.userB
          : userB // ignore: cast_nullable_to_non_nullable
              as MatchUser?,
      itemA: freezed == itemA
          ? _value.itemA
          : itemA // ignore: cast_nullable_to_non_nullable
              as MatchItem?,
      itemB: freezed == itemB
          ? _value.itemB
          : itemB // ignore: cast_nullable_to_non_nullable
              as MatchItem?,
    ) as $Val);
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchUserCopyWith<$Res>? get userA {
    if (_value.userA == null) {
      return null;
    }

    return $MatchUserCopyWith<$Res>(_value.userA!, (value) {
      return _then(_value.copyWith(userA: value) as $Val);
    });
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchUserCopyWith<$Res>? get userB {
    if (_value.userB == null) {
      return null;
    }

    return $MatchUserCopyWith<$Res>(_value.userB!, (value) {
      return _then(_value.copyWith(userB: value) as $Val);
    });
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchItemCopyWith<$Res>? get itemA {
    if (_value.itemA == null) {
      return null;
    }

    return $MatchItemCopyWith<$Res>(_value.itemA!, (value) {
      return _then(_value.copyWith(itemA: value) as $Val);
    });
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchItemCopyWith<$Res>? get itemB {
    if (_value.itemB == null) {
      return null;
    }

    return $MatchItemCopyWith<$Res>(_value.itemB!, (value) {
      return _then(_value.copyWith(itemB: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
          _$MatchImpl value, $Res Function(_$MatchImpl) then) =
      __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userAId,
      String userBId,
      String itemAId,
      String itemBId,
      MatchStatus status,
      bool userAConfirmed,
      bool userBConfirmed,
      DateTime? completedAt,
      DateTime? expiredAt,
      DateTime lastActivityAt,
      DateTime createdAt,
      MatchUser? userA,
      MatchUser? userB,
      MatchItem? itemA,
      MatchItem? itemB});

  @override
  $MatchUserCopyWith<$Res>? get userA;
  @override
  $MatchUserCopyWith<$Res>? get userB;
  @override
  $MatchItemCopyWith<$Res>? get itemA;
  @override
  $MatchItemCopyWith<$Res>? get itemB;
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
      _$MatchImpl _value, $Res Function(_$MatchImpl) _then)
      : super(_value, _then);

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userAId = null,
    Object? userBId = null,
    Object? itemAId = null,
    Object? itemBId = null,
    Object? status = null,
    Object? userAConfirmed = null,
    Object? userBConfirmed = null,
    Object? completedAt = freezed,
    Object? expiredAt = freezed,
    Object? lastActivityAt = null,
    Object? createdAt = null,
    Object? userA = freezed,
    Object? userB = freezed,
    Object? itemA = freezed,
    Object? itemB = freezed,
  }) {
    return _then(_$MatchImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userAId: null == userAId
          ? _value.userAId
          : userAId // ignore: cast_nullable_to_non_nullable
              as String,
      userBId: null == userBId
          ? _value.userBId
          : userBId // ignore: cast_nullable_to_non_nullable
              as String,
      itemAId: null == itemAId
          ? _value.itemAId
          : itemAId // ignore: cast_nullable_to_non_nullable
              as String,
      itemBId: null == itemBId
          ? _value.itemBId
          : itemBId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as MatchStatus,
      userAConfirmed: null == userAConfirmed
          ? _value.userAConfirmed
          : userAConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      userBConfirmed: null == userBConfirmed
          ? _value.userBConfirmed
          : userBConfirmed // ignore: cast_nullable_to_non_nullable
              as bool,
      completedAt: freezed == completedAt
          ? _value.completedAt
          : completedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      expiredAt: freezed == expiredAt
          ? _value.expiredAt
          : expiredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastActivityAt: null == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userA: freezed == userA
          ? _value.userA
          : userA // ignore: cast_nullable_to_non_nullable
              as MatchUser?,
      userB: freezed == userB
          ? _value.userB
          : userB // ignore: cast_nullable_to_non_nullable
              as MatchUser?,
      itemA: freezed == itemA
          ? _value.itemA
          : itemA // ignore: cast_nullable_to_non_nullable
              as MatchItem?,
      itemB: freezed == itemB
          ? _value.itemB
          : itemB // ignore: cast_nullable_to_non_nullable
              as MatchItem?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchImpl implements _Match {
  const _$MatchImpl(
      {required this.id,
      required this.userAId,
      required this.userBId,
      required this.itemAId,
      required this.itemBId,
      required this.status,
      required this.userAConfirmed,
      required this.userBConfirmed,
      this.completedAt,
      this.expiredAt,
      required this.lastActivityAt,
      required this.createdAt,
      this.userA,
      this.userB,
      this.itemA,
      this.itemB});

  factory _$MatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchImplFromJson(json);

  @override
  final String id;
  @override
  final String userAId;
  @override
  final String userBId;
  @override
  final String itemAId;
  @override
  final String itemBId;
  @override
  final MatchStatus status;
  @override
  final bool userAConfirmed;
  @override
  final bool userBConfirmed;
  @override
  final DateTime? completedAt;
  @override
  final DateTime? expiredAt;
  @override
  final DateTime lastActivityAt;
  @override
  final DateTime createdAt;
  @override
  final MatchUser? userA;
  @override
  final MatchUser? userB;
  @override
  final MatchItem? itemA;
  @override
  final MatchItem? itemB;

  @override
  String toString() {
    return 'Match(id: $id, userAId: $userAId, userBId: $userBId, itemAId: $itemAId, itemBId: $itemBId, status: $status, userAConfirmed: $userAConfirmed, userBConfirmed: $userBConfirmed, completedAt: $completedAt, expiredAt: $expiredAt, lastActivityAt: $lastActivityAt, createdAt: $createdAt, userA: $userA, userB: $userB, itemA: $itemA, itemB: $itemB)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userAId, userAId) || other.userAId == userAId) &&
            (identical(other.userBId, userBId) || other.userBId == userBId) &&
            (identical(other.itemAId, itemAId) || other.itemAId == itemAId) &&
            (identical(other.itemBId, itemBId) || other.itemBId == itemBId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.userAConfirmed, userAConfirmed) ||
                other.userAConfirmed == userAConfirmed) &&
            (identical(other.userBConfirmed, userBConfirmed) ||
                other.userBConfirmed == userBConfirmed) &&
            (identical(other.completedAt, completedAt) ||
                other.completedAt == completedAt) &&
            (identical(other.expiredAt, expiredAt) ||
                other.expiredAt == expiredAt) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.userA, userA) || other.userA == userA) &&
            (identical(other.userB, userB) || other.userB == userB) &&
            (identical(other.itemA, itemA) || other.itemA == itemA) &&
            (identical(other.itemB, itemB) || other.itemB == itemB));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userAId,
      userBId,
      itemAId,
      itemBId,
      status,
      userAConfirmed,
      userBConfirmed,
      completedAt,
      expiredAt,
      lastActivityAt,
      createdAt,
      userA,
      userB,
      itemA,
      itemB);

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchImplToJson(
      this,
    );
  }
}

abstract class _Match implements Match {
  const factory _Match(
      {required final String id,
      required final String userAId,
      required final String userBId,
      required final String itemAId,
      required final String itemBId,
      required final MatchStatus status,
      required final bool userAConfirmed,
      required final bool userBConfirmed,
      final DateTime? completedAt,
      final DateTime? expiredAt,
      required final DateTime lastActivityAt,
      required final DateTime createdAt,
      final MatchUser? userA,
      final MatchUser? userB,
      final MatchItem? itemA,
      final MatchItem? itemB}) = _$MatchImpl;

  factory _Match.fromJson(Map<String, dynamic> json) = _$MatchImpl.fromJson;

  @override
  String get id;
  @override
  String get userAId;
  @override
  String get userBId;
  @override
  String get itemAId;
  @override
  String get itemBId;
  @override
  MatchStatus get status;
  @override
  bool get userAConfirmed;
  @override
  bool get userBConfirmed;
  @override
  DateTime? get completedAt;
  @override
  DateTime? get expiredAt;
  @override
  DateTime get lastActivityAt;
  @override
  DateTime get createdAt;
  @override
  MatchUser? get userA;
  @override
  MatchUser? get userB;
  @override
  MatchItem? get itemA;
  @override
  MatchItem? get itemB;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchUser _$MatchUserFromJson(Map<String, dynamic> json) {
  return _MatchUser.fromJson(json);
}

/// @nodoc
mixin _$MatchUser {
  String get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;
  bool get emailVerified => throw _privateConstructorUsedError;

  /// Serializes this MatchUser to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchUserCopyWith<MatchUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchUserCopyWith<$Res> {
  factory $MatchUserCopyWith(MatchUser value, $Res Function(MatchUser) then) =
      _$MatchUserCopyWithImpl<$Res, MatchUser>;
  @useResult
  $Res call(
      {String id,
      String displayName,
      String? profilePhotoUrl,
      bool emailVerified});
}

/// @nodoc
class _$MatchUserCopyWithImpl<$Res, $Val extends MatchUser>
    implements $MatchUserCopyWith<$Res> {
  _$MatchUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? profilePhotoUrl = freezed,
    Object? emailVerified = null,
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
      emailVerified: null == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchUserImplCopyWith<$Res>
    implements $MatchUserCopyWith<$Res> {
  factory _$$MatchUserImplCopyWith(
          _$MatchUserImpl value, $Res Function(_$MatchUserImpl) then) =
      __$$MatchUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String displayName,
      String? profilePhotoUrl,
      bool emailVerified});
}

/// @nodoc
class __$$MatchUserImplCopyWithImpl<$Res>
    extends _$MatchUserCopyWithImpl<$Res, _$MatchUserImpl>
    implements _$$MatchUserImplCopyWith<$Res> {
  __$$MatchUserImplCopyWithImpl(
      _$MatchUserImpl _value, $Res Function(_$MatchUserImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchUser
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? profilePhotoUrl = freezed,
    Object? emailVerified = null,
  }) {
    return _then(_$MatchUserImpl(
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
      emailVerified: null == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchUserImpl implements _MatchUser {
  const _$MatchUserImpl(
      {required this.id,
      required this.displayName,
      this.profilePhotoUrl,
      this.emailVerified = false});

  factory _$MatchUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchUserImplFromJson(json);

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? profilePhotoUrl;
  @override
  @JsonKey()
  final bool emailVerified;

  @override
  String toString() {
    return 'MatchUser(id: $id, displayName: $displayName, profilePhotoUrl: $profilePhotoUrl, emailVerified: $emailVerified)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.profilePhotoUrl, profilePhotoUrl) ||
                other.profilePhotoUrl == profilePhotoUrl) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, displayName, profilePhotoUrl, emailVerified);

  /// Create a copy of MatchUser
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchUserImplCopyWith<_$MatchUserImpl> get copyWith =>
      __$$MatchUserImplCopyWithImpl<_$MatchUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchUserImplToJson(
      this,
    );
  }
}

abstract class _MatchUser implements MatchUser {
  const factory _MatchUser(
      {required final String id,
      required final String displayName,
      final String? profilePhotoUrl,
      final bool emailVerified}) = _$MatchUserImpl;

  factory _MatchUser.fromJson(Map<String, dynamic> json) =
      _$MatchUserImpl.fromJson;

  @override
  String get id;
  @override
  String get displayName;
  @override
  String? get profilePhotoUrl;
  @override
  bool get emailVerified;

  /// Create a copy of MatchUser
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchUserImplCopyWith<_$MatchUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchItem _$MatchItemFromJson(Map<String, dynamic> json) {
  return _MatchItem.fromJson(json);
}

/// @nodoc
mixin _$MatchItem {
  String get id => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get size => throw _privateConstructorUsedError;
  List<MatchItemPhoto> get photos => throw _privateConstructorUsedError;

  /// Serializes this MatchItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchItemCopyWith<MatchItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchItemCopyWith<$Res> {
  factory $MatchItemCopyWith(MatchItem value, $Res Function(MatchItem) then) =
      _$MatchItemCopyWithImpl<$Res, MatchItem>;
  @useResult
  $Res call(
      {String id,
      String brand,
      String? category,
      String? size,
      List<MatchItemPhoto> photos});
}

/// @nodoc
class _$MatchItemCopyWithImpl<$Res, $Val extends MatchItem>
    implements $MatchItemCopyWith<$Res> {
  _$MatchItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? category = freezed,
    Object? size = freezed,
    Object? photos = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<MatchItemPhoto>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchItemImplCopyWith<$Res>
    implements $MatchItemCopyWith<$Res> {
  factory _$$MatchItemImplCopyWith(
          _$MatchItemImpl value, $Res Function(_$MatchItemImpl) then) =
      __$$MatchItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String brand,
      String? category,
      String? size,
      List<MatchItemPhoto> photos});
}

/// @nodoc
class __$$MatchItemImplCopyWithImpl<$Res>
    extends _$MatchItemCopyWithImpl<$Res, _$MatchItemImpl>
    implements _$$MatchItemImplCopyWith<$Res> {
  __$$MatchItemImplCopyWithImpl(
      _$MatchItemImpl _value, $Res Function(_$MatchItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? brand = null,
    Object? category = freezed,
    Object? size = freezed,
    Object? photos = null,
  }) {
    return _then(_$MatchItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      category: freezed == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String?,
      size: freezed == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as String?,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<MatchItemPhoto>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchItemImpl implements _MatchItem {
  const _$MatchItemImpl(
      {required this.id,
      required this.brand,
      this.category,
      this.size,
      final List<MatchItemPhoto> photos = const []})
      : _photos = photos;

  factory _$MatchItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchItemImplFromJson(json);

  @override
  final String id;
  @override
  final String brand;
  @override
  final String? category;
  @override
  final String? size;
  final List<MatchItemPhoto> _photos;
  @override
  @JsonKey()
  List<MatchItemPhoto> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  String toString() {
    return 'MatchItem(id: $id, brand: $brand, category: $category, size: $size, photos: $photos)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.size, size) || other.size == size) &&
            const DeepCollectionEquality().equals(other._photos, _photos));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, brand, category, size,
      const DeepCollectionEquality().hash(_photos));

  /// Create a copy of MatchItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchItemImplCopyWith<_$MatchItemImpl> get copyWith =>
      __$$MatchItemImplCopyWithImpl<_$MatchItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchItemImplToJson(
      this,
    );
  }
}

abstract class _MatchItem implements MatchItem {
  const factory _MatchItem(
      {required final String id,
      required final String brand,
      final String? category,
      final String? size,
      final List<MatchItemPhoto> photos}) = _$MatchItemImpl;

  factory _MatchItem.fromJson(Map<String, dynamic> json) =
      _$MatchItemImpl.fromJson;

  @override
  String get id;
  @override
  String get brand;
  @override
  String? get category;
  @override
  String? get size;
  @override
  List<MatchItemPhoto> get photos;

  /// Create a copy of MatchItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchItemImplCopyWith<_$MatchItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchItemPhoto _$MatchItemPhotoFromJson(Map<String, dynamic> json) {
  return _MatchItemPhoto.fromJson(json);
}

/// @nodoc
mixin _$MatchItemPhoto {
  String get url => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;

  /// Serializes this MatchItemPhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchItemPhotoCopyWith<MatchItemPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchItemPhotoCopyWith<$Res> {
  factory $MatchItemPhotoCopyWith(
          MatchItemPhoto value, $Res Function(MatchItemPhoto) then) =
      _$MatchItemPhotoCopyWithImpl<$Res, MatchItemPhoto>;
  @useResult
  $Res call({String url, int sortOrder});
}

/// @nodoc
class _$MatchItemPhotoCopyWithImpl<$Res, $Val extends MatchItemPhoto>
    implements $MatchItemPhotoCopyWith<$Res> {
  _$MatchItemPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? sortOrder = null,
  }) {
    return _then(_value.copyWith(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MatchItemPhotoImplCopyWith<$Res>
    implements $MatchItemPhotoCopyWith<$Res> {
  factory _$$MatchItemPhotoImplCopyWith(_$MatchItemPhotoImpl value,
          $Res Function(_$MatchItemPhotoImpl) then) =
      __$$MatchItemPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String url, int sortOrder});
}

/// @nodoc
class __$$MatchItemPhotoImplCopyWithImpl<$Res>
    extends _$MatchItemPhotoCopyWithImpl<$Res, _$MatchItemPhotoImpl>
    implements _$$MatchItemPhotoImplCopyWith<$Res> {
  __$$MatchItemPhotoImplCopyWithImpl(
      _$MatchItemPhotoImpl _value, $Res Function(_$MatchItemPhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of MatchItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? url = null,
    Object? sortOrder = null,
  }) {
    return _then(_$MatchItemPhotoImpl(
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchItemPhotoImpl implements _MatchItemPhoto {
  const _$MatchItemPhotoImpl({required this.url, this.sortOrder = 0});

  factory _$MatchItemPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchItemPhotoImplFromJson(json);

  @override
  final String url;
  @override
  @JsonKey()
  final int sortOrder;

  @override
  String toString() {
    return 'MatchItemPhoto(url: $url, sortOrder: $sortOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchItemPhotoImpl &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, url, sortOrder);

  /// Create a copy of MatchItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchItemPhotoImplCopyWith<_$MatchItemPhotoImpl> get copyWith =>
      __$$MatchItemPhotoImplCopyWithImpl<_$MatchItemPhotoImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchItemPhotoImplToJson(
      this,
    );
  }
}

abstract class _MatchItemPhoto implements MatchItemPhoto {
  const factory _MatchItemPhoto(
      {required final String url, final int sortOrder}) = _$MatchItemPhotoImpl;

  factory _MatchItemPhoto.fromJson(Map<String, dynamic> json) =
      _$MatchItemPhotoImpl.fromJson;

  @override
  String get url;
  @override
  int get sortOrder;

  /// Create a copy of MatchItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchItemPhotoImplCopyWith<_$MatchItemPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
