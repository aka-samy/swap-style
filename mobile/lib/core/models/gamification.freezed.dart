// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gamification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Streak _$StreakFromJson(Map<String, dynamic> json) {
  return _Streak.fromJson(json);
}

/// @nodoc
mixin _$Streak {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  int get currentStreak => throw _privateConstructorUsedError;
  int get longestStreak => throw _privateConstructorUsedError;
  DateTime? get lastActivityAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this Streak to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StreakCopyWith<Streak> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StreakCopyWith<$Res> {
  factory $StreakCopyWith(Streak value, $Res Function(Streak) then) =
      _$StreakCopyWithImpl<$Res, Streak>;
  @useResult
  $Res call(
      {String id,
      String userId,
      int currentStreak,
      int longestStreak,
      DateTime? lastActivityAt,
      DateTime updatedAt});
}

/// @nodoc
class _$StreakCopyWithImpl<$Res, $Val extends Streak>
    implements $StreakCopyWith<$Res> {
  _$StreakCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastActivityAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$StreakImplCopyWith<$Res> implements $StreakCopyWith<$Res> {
  factory _$$StreakImplCopyWith(
          _$StreakImpl value, $Res Function(_$StreakImpl) then) =
      __$$StreakImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      int currentStreak,
      int longestStreak,
      DateTime? lastActivityAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$StreakImplCopyWithImpl<$Res>
    extends _$StreakCopyWithImpl<$Res, _$StreakImpl>
    implements _$$StreakImplCopyWith<$Res> {
  __$$StreakImplCopyWithImpl(
      _$StreakImpl _value, $Res Function(_$StreakImpl) _then)
      : super(_value, _then);

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? currentStreak = null,
    Object? longestStreak = null,
    Object? lastActivityAt = freezed,
    Object? updatedAt = null,
  }) {
    return _then(_$StreakImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      currentStreak: null == currentStreak
          ? _value.currentStreak
          : currentStreak // ignore: cast_nullable_to_non_nullable
              as int,
      longestStreak: null == longestStreak
          ? _value.longestStreak
          : longestStreak // ignore: cast_nullable_to_non_nullable
              as int,
      lastActivityAt: freezed == lastActivityAt
          ? _value.lastActivityAt
          : lastActivityAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$StreakImpl implements _Streak {
  const _$StreakImpl(
      {required this.id,
      required this.userId,
      required this.currentStreak,
      required this.longestStreak,
      this.lastActivityAt,
      required this.updatedAt});

  factory _$StreakImpl.fromJson(Map<String, dynamic> json) =>
      _$$StreakImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final int currentStreak;
  @override
  final int longestStreak;
  @override
  final DateTime? lastActivityAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'Streak(id: $id, userId: $userId, currentStreak: $currentStreak, longestStreak: $longestStreak, lastActivityAt: $lastActivityAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StreakImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.currentStreak, currentStreak) ||
                other.currentStreak == currentStreak) &&
            (identical(other.longestStreak, longestStreak) ||
                other.longestStreak == longestStreak) &&
            (identical(other.lastActivityAt, lastActivityAt) ||
                other.lastActivityAt == lastActivityAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, currentStreak,
      longestStreak, lastActivityAt, updatedAt);

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StreakImplCopyWith<_$StreakImpl> get copyWith =>
      __$$StreakImplCopyWithImpl<_$StreakImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$StreakImplToJson(
      this,
    );
  }
}

abstract class _Streak implements Streak {
  const factory _Streak(
      {required final String id,
      required final String userId,
      required final int currentStreak,
      required final int longestStreak,
      final DateTime? lastActivityAt,
      required final DateTime updatedAt}) = _$StreakImpl;

  factory _Streak.fromJson(Map<String, dynamic> json) = _$StreakImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  int get currentStreak;
  @override
  int get longestStreak;
  @override
  DateTime? get lastActivityAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of Streak
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StreakImplCopyWith<_$StreakImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Badge _$BadgeFromJson(Map<String, dynamic> json) {
  return _Badge.fromJson(json);
}

/// @nodoc
mixin _$Badge {
  String get id => throw _privateConstructorUsedError;
  String get slug => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get iconUrl => throw _privateConstructorUsedError;
  DateTime get awardedAt => throw _privateConstructorUsedError;

  /// Serializes this Badge to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BadgeCopyWith<Badge> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BadgeCopyWith<$Res> {
  factory $BadgeCopyWith(Badge value, $Res Function(Badge) then) =
      _$BadgeCopyWithImpl<$Res, Badge>;
  @useResult
  $Res call(
      {String id,
      String slug,
      String name,
      String description,
      String iconUrl,
      DateTime awardedAt});
}

/// @nodoc
class _$BadgeCopyWithImpl<$Res, $Val extends Badge>
    implements $BadgeCopyWith<$Res> {
  _$BadgeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? name = null,
    Object? description = null,
    Object? iconUrl = null,
    Object? awardedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      iconUrl: null == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      awardedAt: null == awardedAt
          ? _value.awardedAt
          : awardedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BadgeImplCopyWith<$Res> implements $BadgeCopyWith<$Res> {
  factory _$$BadgeImplCopyWith(
          _$BadgeImpl value, $Res Function(_$BadgeImpl) then) =
      __$$BadgeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String slug,
      String name,
      String description,
      String iconUrl,
      DateTime awardedAt});
}

/// @nodoc
class __$$BadgeImplCopyWithImpl<$Res>
    extends _$BadgeCopyWithImpl<$Res, _$BadgeImpl>
    implements _$$BadgeImplCopyWith<$Res> {
  __$$BadgeImplCopyWithImpl(
      _$BadgeImpl _value, $Res Function(_$BadgeImpl) _then)
      : super(_value, _then);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? slug = null,
    Object? name = null,
    Object? description = null,
    Object? iconUrl = null,
    Object? awardedAt = null,
  }) {
    return _then(_$BadgeImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      slug: null == slug
          ? _value.slug
          : slug // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      iconUrl: null == iconUrl
          ? _value.iconUrl
          : iconUrl // ignore: cast_nullable_to_non_nullable
              as String,
      awardedAt: null == awardedAt
          ? _value.awardedAt
          : awardedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BadgeImpl implements _Badge {
  const _$BadgeImpl(
      {required this.id,
      required this.slug,
      required this.name,
      required this.description,
      required this.iconUrl,
      required this.awardedAt});

  factory _$BadgeImpl.fromJson(Map<String, dynamic> json) =>
      _$$BadgeImplFromJson(json);

  @override
  final String id;
  @override
  final String slug;
  @override
  final String name;
  @override
  final String description;
  @override
  final String iconUrl;
  @override
  final DateTime awardedAt;

  @override
  String toString() {
    return 'Badge(id: $id, slug: $slug, name: $name, description: $description, iconUrl: $iconUrl, awardedAt: $awardedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BadgeImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.slug, slug) || other.slug == slug) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl) &&
            (identical(other.awardedAt, awardedAt) ||
                other.awardedAt == awardedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, slug, name, description, iconUrl, awardedAt);

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      __$$BadgeImplCopyWithImpl<_$BadgeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BadgeImplToJson(
      this,
    );
  }
}

abstract class _Badge implements Badge {
  const factory _Badge(
      {required final String id,
      required final String slug,
      required final String name,
      required final String description,
      required final String iconUrl,
      required final DateTime awardedAt}) = _$BadgeImpl;

  factory _Badge.fromJson(Map<String, dynamic> json) = _$BadgeImpl.fromJson;

  @override
  String get id;
  @override
  String get slug;
  @override
  String get name;
  @override
  String get description;
  @override
  String get iconUrl;
  @override
  DateTime get awardedAt;

  /// Create a copy of Badge
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BadgeImplCopyWith<_$BadgeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GamificationStats _$GamificationStatsFromJson(Map<String, dynamic> json) {
  return _GamificationStats.fromJson(json);
}

/// @nodoc
mixin _$GamificationStats {
  Streak? get streak => throw _privateConstructorUsedError;
  List<Badge> get badges => throw _privateConstructorUsedError;

  /// Serializes this GamificationStats to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamificationStatsCopyWith<GamificationStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamificationStatsCopyWith<$Res> {
  factory $GamificationStatsCopyWith(
          GamificationStats value, $Res Function(GamificationStats) then) =
      _$GamificationStatsCopyWithImpl<$Res, GamificationStats>;
  @useResult
  $Res call({Streak? streak, List<Badge> badges});

  $StreakCopyWith<$Res>? get streak;
}

/// @nodoc
class _$GamificationStatsCopyWithImpl<$Res, $Val extends GamificationStats>
    implements $GamificationStatsCopyWith<$Res> {
  _$GamificationStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = freezed,
    Object? badges = null,
  }) {
    return _then(_value.copyWith(
      streak: freezed == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as Streak?,
      badges: null == badges
          ? _value.badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<Badge>,
    ) as $Val);
  }

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $StreakCopyWith<$Res>? get streak {
    if (_value.streak == null) {
      return null;
    }

    return $StreakCopyWith<$Res>(_value.streak!, (value) {
      return _then(_value.copyWith(streak: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GamificationStatsImplCopyWith<$Res>
    implements $GamificationStatsCopyWith<$Res> {
  factory _$$GamificationStatsImplCopyWith(_$GamificationStatsImpl value,
          $Res Function(_$GamificationStatsImpl) then) =
      __$$GamificationStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Streak? streak, List<Badge> badges});

  @override
  $StreakCopyWith<$Res>? get streak;
}

/// @nodoc
class __$$GamificationStatsImplCopyWithImpl<$Res>
    extends _$GamificationStatsCopyWithImpl<$Res, _$GamificationStatsImpl>
    implements _$$GamificationStatsImplCopyWith<$Res> {
  __$$GamificationStatsImplCopyWithImpl(_$GamificationStatsImpl _value,
      $Res Function(_$GamificationStatsImpl) _then)
      : super(_value, _then);

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? streak = freezed,
    Object? badges = null,
  }) {
    return _then(_$GamificationStatsImpl(
      streak: freezed == streak
          ? _value.streak
          : streak // ignore: cast_nullable_to_non_nullable
              as Streak?,
      badges: null == badges
          ? _value._badges
          : badges // ignore: cast_nullable_to_non_nullable
              as List<Badge>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$GamificationStatsImpl implements _GamificationStats {
  const _$GamificationStatsImpl(
      {this.streak, final List<Badge> badges = const []})
      : _badges = badges;

  factory _$GamificationStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamificationStatsImplFromJson(json);

  @override
  final Streak? streak;
  final List<Badge> _badges;
  @override
  @JsonKey()
  List<Badge> get badges {
    if (_badges is EqualUnmodifiableListView) return _badges;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_badges);
  }

  @override
  String toString() {
    return 'GamificationStats(streak: $streak, badges: $badges)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamificationStatsImpl &&
            (identical(other.streak, streak) || other.streak == streak) &&
            const DeepCollectionEquality().equals(other._badges, _badges));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, streak, const DeepCollectionEquality().hash(_badges));

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamificationStatsImplCopyWith<_$GamificationStatsImpl> get copyWith =>
      __$$GamificationStatsImplCopyWithImpl<_$GamificationStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamificationStatsImplToJson(
      this,
    );
  }
}

abstract class _GamificationStats implements GamificationStats {
  const factory _GamificationStats(
      {final Streak? streak,
      final List<Badge> badges}) = _$GamificationStatsImpl;

  factory _GamificationStats.fromJson(Map<String, dynamic> json) =
      _$GamificationStatsImpl.fromJson;

  @override
  Streak? get streak;
  @override
  List<Badge> get badges;

  /// Create a copy of GamificationStats
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamificationStatsImplCopyWith<_$GamificationStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
