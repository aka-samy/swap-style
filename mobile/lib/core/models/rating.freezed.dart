// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'rating.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Rating _$RatingFromJson(Map<String, dynamic> json) {
  return _Rating.fromJson(json);
}

/// @nodoc
mixin _$Rating {
  String get id => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  String get raterId => throw _privateConstructorUsedError;
  String get rateeId => throw _privateConstructorUsedError;
  int get score => throw _privateConstructorUsedError;
  String? get comment => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  RaterSummary? get rater => throw _privateConstructorUsedError;

  /// Serializes this Rating to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatingCopyWith<Rating> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingCopyWith<$Res> {
  factory $RatingCopyWith(Rating value, $Res Function(Rating) then) =
      _$RatingCopyWithImpl<$Res, Rating>;
  @useResult
  $Res call(
      {String id,
      String matchId,
      String raterId,
      String rateeId,
      int score,
      String? comment,
      DateTime createdAt,
      RaterSummary? rater});

  $RaterSummaryCopyWith<$Res>? get rater;
}

/// @nodoc
class _$RatingCopyWithImpl<$Res, $Val extends Rating>
    implements $RatingCopyWith<$Res> {
  _$RatingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? raterId = null,
    Object? rateeId = null,
    Object? score = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? rater = freezed,
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
      raterId: null == raterId
          ? _value.raterId
          : raterId // ignore: cast_nullable_to_non_nullable
              as String,
      rateeId: null == rateeId
          ? _value.rateeId
          : rateeId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rater: freezed == rater
          ? _value.rater
          : rater // ignore: cast_nullable_to_non_nullable
              as RaterSummary?,
    ) as $Val);
  }

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RaterSummaryCopyWith<$Res>? get rater {
    if (_value.rater == null) {
      return null;
    }

    return $RaterSummaryCopyWith<$Res>(_value.rater!, (value) {
      return _then(_value.copyWith(rater: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RatingImplCopyWith<$Res> implements $RatingCopyWith<$Res> {
  factory _$$RatingImplCopyWith(
          _$RatingImpl value, $Res Function(_$RatingImpl) then) =
      __$$RatingImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String matchId,
      String raterId,
      String rateeId,
      int score,
      String? comment,
      DateTime createdAt,
      RaterSummary? rater});

  @override
  $RaterSummaryCopyWith<$Res>? get rater;
}

/// @nodoc
class __$$RatingImplCopyWithImpl<$Res>
    extends _$RatingCopyWithImpl<$Res, _$RatingImpl>
    implements _$$RatingImplCopyWith<$Res> {
  __$$RatingImplCopyWithImpl(
      _$RatingImpl _value, $Res Function(_$RatingImpl) _then)
      : super(_value, _then);

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? raterId = null,
    Object? rateeId = null,
    Object? score = null,
    Object? comment = freezed,
    Object? createdAt = null,
    Object? rater = freezed,
  }) {
    return _then(_$RatingImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      raterId: null == raterId
          ? _value.raterId
          : raterId // ignore: cast_nullable_to_non_nullable
              as String,
      rateeId: null == rateeId
          ? _value.rateeId
          : rateeId // ignore: cast_nullable_to_non_nullable
              as String,
      score: null == score
          ? _value.score
          : score // ignore: cast_nullable_to_non_nullable
              as int,
      comment: freezed == comment
          ? _value.comment
          : comment // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      rater: freezed == rater
          ? _value.rater
          : rater // ignore: cast_nullable_to_non_nullable
              as RaterSummary?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingImpl implements _Rating {
  const _$RatingImpl(
      {required this.id,
      required this.matchId,
      required this.raterId,
      required this.rateeId,
      required this.score,
      this.comment,
      required this.createdAt,
      this.rater});

  factory _$RatingImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingImplFromJson(json);

  @override
  final String id;
  @override
  final String matchId;
  @override
  final String raterId;
  @override
  final String rateeId;
  @override
  final int score;
  @override
  final String? comment;
  @override
  final DateTime createdAt;
  @override
  final RaterSummary? rater;

  @override
  String toString() {
    return 'Rating(id: $id, matchId: $matchId, raterId: $raterId, rateeId: $rateeId, score: $score, comment: $comment, createdAt: $createdAt, rater: $rater)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.raterId, raterId) || other.raterId == raterId) &&
            (identical(other.rateeId, rateeId) || other.rateeId == rateeId) &&
            (identical(other.score, score) || other.score == score) &&
            (identical(other.comment, comment) || other.comment == comment) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.rater, rater) || other.rater == rater));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, matchId, raterId, rateeId,
      score, comment, createdAt, rater);

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingImplCopyWith<_$RatingImpl> get copyWith =>
      __$$RatingImplCopyWithImpl<_$RatingImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingImplToJson(
      this,
    );
  }
}

abstract class _Rating implements Rating {
  const factory _Rating(
      {required final String id,
      required final String matchId,
      required final String raterId,
      required final String rateeId,
      required final int score,
      final String? comment,
      required final DateTime createdAt,
      final RaterSummary? rater}) = _$RatingImpl;

  factory _Rating.fromJson(Map<String, dynamic> json) = _$RatingImpl.fromJson;

  @override
  String get id;
  @override
  String get matchId;
  @override
  String get raterId;
  @override
  String get rateeId;
  @override
  int get score;
  @override
  String? get comment;
  @override
  DateTime get createdAt;
  @override
  RaterSummary? get rater;

  /// Create a copy of Rating
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatingImplCopyWith<_$RatingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RaterSummary _$RaterSummaryFromJson(Map<String, dynamic> json) {
  return _RaterSummary.fromJson(json);
}

/// @nodoc
mixin _$RaterSummary {
  String get id => throw _privateConstructorUsedError;
  String get displayName => throw _privateConstructorUsedError;
  String? get profilePhotoUrl => throw _privateConstructorUsedError;

  /// Serializes this RaterSummary to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RaterSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RaterSummaryCopyWith<RaterSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RaterSummaryCopyWith<$Res> {
  factory $RaterSummaryCopyWith(
          RaterSummary value, $Res Function(RaterSummary) then) =
      _$RaterSummaryCopyWithImpl<$Res, RaterSummary>;
  @useResult
  $Res call({String id, String displayName, String? profilePhotoUrl});
}

/// @nodoc
class _$RaterSummaryCopyWithImpl<$Res, $Val extends RaterSummary>
    implements $RaterSummaryCopyWith<$Res> {
  _$RaterSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RaterSummary
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
abstract class _$$RaterSummaryImplCopyWith<$Res>
    implements $RaterSummaryCopyWith<$Res> {
  factory _$$RaterSummaryImplCopyWith(
          _$RaterSummaryImpl value, $Res Function(_$RaterSummaryImpl) then) =
      __$$RaterSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String displayName, String? profilePhotoUrl});
}

/// @nodoc
class __$$RaterSummaryImplCopyWithImpl<$Res>
    extends _$RaterSummaryCopyWithImpl<$Res, _$RaterSummaryImpl>
    implements _$$RaterSummaryImplCopyWith<$Res> {
  __$$RaterSummaryImplCopyWithImpl(
      _$RaterSummaryImpl _value, $Res Function(_$RaterSummaryImpl) _then)
      : super(_value, _then);

  /// Create a copy of RaterSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? displayName = null,
    Object? profilePhotoUrl = freezed,
  }) {
    return _then(_$RaterSummaryImpl(
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
class _$RaterSummaryImpl implements _RaterSummary {
  const _$RaterSummaryImpl(
      {required this.id, required this.displayName, this.profilePhotoUrl});

  factory _$RaterSummaryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RaterSummaryImplFromJson(json);

  @override
  final String id;
  @override
  final String displayName;
  @override
  final String? profilePhotoUrl;

  @override
  String toString() {
    return 'RaterSummary(id: $id, displayName: $displayName, profilePhotoUrl: $profilePhotoUrl)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RaterSummaryImpl &&
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

  /// Create a copy of RaterSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RaterSummaryImplCopyWith<_$RaterSummaryImpl> get copyWith =>
      __$$RaterSummaryImplCopyWithImpl<_$RaterSummaryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RaterSummaryImplToJson(
      this,
    );
  }
}

abstract class _RaterSummary implements RaterSummary {
  const factory _RaterSummary(
      {required final String id,
      required final String displayName,
      final String? profilePhotoUrl}) = _$RaterSummaryImpl;

  factory _RaterSummary.fromJson(Map<String, dynamic> json) =
      _$RaterSummaryImpl.fromJson;

  @override
  String get id;
  @override
  String get displayName;
  @override
  String? get profilePhotoUrl;

  /// Create a copy of RaterSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RaterSummaryImplCopyWith<_$RaterSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RatingsPage _$RatingsPageFromJson(Map<String, dynamic> json) {
  return _RatingsPage.fromJson(json);
}

/// @nodoc
mixin _$RatingsPage {
  List<Rating> get ratings => throw _privateConstructorUsedError;
  double get average => throw _privateConstructorUsedError;

  /// Serializes this RatingsPage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RatingsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RatingsPageCopyWith<RatingsPage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RatingsPageCopyWith<$Res> {
  factory $RatingsPageCopyWith(
          RatingsPage value, $Res Function(RatingsPage) then) =
      _$RatingsPageCopyWithImpl<$Res, RatingsPage>;
  @useResult
  $Res call({List<Rating> ratings, double average});
}

/// @nodoc
class _$RatingsPageCopyWithImpl<$Res, $Val extends RatingsPage>
    implements $RatingsPageCopyWith<$Res> {
  _$RatingsPageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RatingsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratings = null,
    Object? average = null,
  }) {
    return _then(_value.copyWith(
      ratings: null == ratings
          ? _value.ratings
          : ratings // ignore: cast_nullable_to_non_nullable
              as List<Rating>,
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RatingsPageImplCopyWith<$Res>
    implements $RatingsPageCopyWith<$Res> {
  factory _$$RatingsPageImplCopyWith(
          _$RatingsPageImpl value, $Res Function(_$RatingsPageImpl) then) =
      __$$RatingsPageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Rating> ratings, double average});
}

/// @nodoc
class __$$RatingsPageImplCopyWithImpl<$Res>
    extends _$RatingsPageCopyWithImpl<$Res, _$RatingsPageImpl>
    implements _$$RatingsPageImplCopyWith<$Res> {
  __$$RatingsPageImplCopyWithImpl(
      _$RatingsPageImpl _value, $Res Function(_$RatingsPageImpl) _then)
      : super(_value, _then);

  /// Create a copy of RatingsPage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ratings = null,
    Object? average = null,
  }) {
    return _then(_$RatingsPageImpl(
      ratings: null == ratings
          ? _value._ratings
          : ratings // ignore: cast_nullable_to_non_nullable
              as List<Rating>,
      average: null == average
          ? _value.average
          : average // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RatingsPageImpl implements _RatingsPage {
  const _$RatingsPageImpl(
      {required final List<Rating> ratings, this.average = 0})
      : _ratings = ratings;

  factory _$RatingsPageImpl.fromJson(Map<String, dynamic> json) =>
      _$$RatingsPageImplFromJson(json);

  final List<Rating> _ratings;
  @override
  List<Rating> get ratings {
    if (_ratings is EqualUnmodifiableListView) return _ratings;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_ratings);
  }

  @override
  @JsonKey()
  final double average;

  @override
  String toString() {
    return 'RatingsPage(ratings: $ratings, average: $average)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RatingsPageImpl &&
            const DeepCollectionEquality().equals(other._ratings, _ratings) &&
            (identical(other.average, average) || other.average == average));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_ratings), average);

  /// Create a copy of RatingsPage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RatingsPageImplCopyWith<_$RatingsPageImpl> get copyWith =>
      __$$RatingsPageImplCopyWithImpl<_$RatingsPageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RatingsPageImplToJson(
      this,
    );
  }
}

abstract class _RatingsPage implements RatingsPage {
  const factory _RatingsPage(
      {required final List<Rating> ratings,
      final double average}) = _$RatingsPageImpl;

  factory _RatingsPage.fromJson(Map<String, dynamic> json) =
      _$RatingsPageImpl.fromJson;

  @override
  List<Rating> get ratings;
  @override
  double get average;

  /// Create a copy of RatingsPage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RatingsPageImplCopyWith<_$RatingsPageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
