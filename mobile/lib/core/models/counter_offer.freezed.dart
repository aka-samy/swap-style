// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'counter_offer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CounterOffer _$CounterOfferFromJson(Map<String, dynamic> json) {
  return _CounterOffer.fromJson(json);
}

/// @nodoc
mixin _$CounterOffer {
  String get id => throw _privateConstructorUsedError;
  String get matchId => throw _privateConstructorUsedError;
  String get proposerId => throw _privateConstructorUsedError;
  CounterOfferStatus get status => throw _privateConstructorUsedError;
  double get monetaryAmount => throw _privateConstructorUsedError;
  String? get message => throw _privateConstructorUsedError;
  int get round => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  List<CounterOfferItem> get items => throw _privateConstructorUsedError;

  /// Serializes this CounterOffer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CounterOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterOfferCopyWith<CounterOffer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterOfferCopyWith<$Res> {
  factory $CounterOfferCopyWith(
          CounterOffer value, $Res Function(CounterOffer) then) =
      _$CounterOfferCopyWithImpl<$Res, CounterOffer>;
  @useResult
  $Res call(
      {String id,
      String matchId,
      String proposerId,
      CounterOfferStatus status,
      double monetaryAmount,
      String? message,
      int round,
      DateTime createdAt,
      List<CounterOfferItem> items});
}

/// @nodoc
class _$CounterOfferCopyWithImpl<$Res, $Val extends CounterOffer>
    implements $CounterOfferCopyWith<$Res> {
  _$CounterOfferCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? proposerId = null,
    Object? status = null,
    Object? monetaryAmount = null,
    Object? message = freezed,
    Object? round = null,
    Object? createdAt = null,
    Object? items = null,
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
      proposerId: null == proposerId
          ? _value.proposerId
          : proposerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CounterOfferStatus,
      monetaryAmount: null == monetaryAmount
          ? _value.monetaryAmount
          : monetaryAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value.items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CounterOfferItem>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CounterOfferImplCopyWith<$Res>
    implements $CounterOfferCopyWith<$Res> {
  factory _$$CounterOfferImplCopyWith(
          _$CounterOfferImpl value, $Res Function(_$CounterOfferImpl) then) =
      __$$CounterOfferImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String matchId,
      String proposerId,
      CounterOfferStatus status,
      double monetaryAmount,
      String? message,
      int round,
      DateTime createdAt,
      List<CounterOfferItem> items});
}

/// @nodoc
class __$$CounterOfferImplCopyWithImpl<$Res>
    extends _$CounterOfferCopyWithImpl<$Res, _$CounterOfferImpl>
    implements _$$CounterOfferImplCopyWith<$Res> {
  __$$CounterOfferImplCopyWithImpl(
      _$CounterOfferImpl _value, $Res Function(_$CounterOfferImpl) _then)
      : super(_value, _then);

  /// Create a copy of CounterOffer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? matchId = null,
    Object? proposerId = null,
    Object? status = null,
    Object? monetaryAmount = null,
    Object? message = freezed,
    Object? round = null,
    Object? createdAt = null,
    Object? items = null,
  }) {
    return _then(_$CounterOfferImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      matchId: null == matchId
          ? _value.matchId
          : matchId // ignore: cast_nullable_to_non_nullable
              as String,
      proposerId: null == proposerId
          ? _value.proposerId
          : proposerId // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as CounterOfferStatus,
      monetaryAmount: null == monetaryAmount
          ? _value.monetaryAmount
          : monetaryAmount // ignore: cast_nullable_to_non_nullable
              as double,
      message: freezed == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String?,
      round: null == round
          ? _value.round
          : round // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      items: null == items
          ? _value._items
          : items // ignore: cast_nullable_to_non_nullable
              as List<CounterOfferItem>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CounterOfferImpl implements _CounterOffer {
  const _$CounterOfferImpl(
      {required this.id,
      required this.matchId,
      required this.proposerId,
      required this.status,
      this.monetaryAmount = 0,
      this.message,
      required this.round,
      required this.createdAt,
      final List<CounterOfferItem> items = const []})
      : _items = items;

  factory _$CounterOfferImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounterOfferImplFromJson(json);

  @override
  final String id;
  @override
  final String matchId;
  @override
  final String proposerId;
  @override
  final CounterOfferStatus status;
  @override
  @JsonKey()
  final double monetaryAmount;
  @override
  final String? message;
  @override
  final int round;
  @override
  final DateTime createdAt;
  final List<CounterOfferItem> _items;
  @override
  @JsonKey()
  List<CounterOfferItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CounterOffer(id: $id, matchId: $matchId, proposerId: $proposerId, status: $status, monetaryAmount: $monetaryAmount, message: $message, round: $round, createdAt: $createdAt, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterOfferImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.matchId, matchId) || other.matchId == matchId) &&
            (identical(other.proposerId, proposerId) ||
                other.proposerId == proposerId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.monetaryAmount, monetaryAmount) ||
                other.monetaryAmount == monetaryAmount) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.round, round) || other.round == round) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      matchId,
      proposerId,
      status,
      monetaryAmount,
      message,
      round,
      createdAt,
      const DeepCollectionEquality().hash(_items));

  /// Create a copy of CounterOffer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterOfferImplCopyWith<_$CounterOfferImpl> get copyWith =>
      __$$CounterOfferImplCopyWithImpl<_$CounterOfferImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CounterOfferImplToJson(
      this,
    );
  }
}

abstract class _CounterOffer implements CounterOffer {
  const factory _CounterOffer(
      {required final String id,
      required final String matchId,
      required final String proposerId,
      required final CounterOfferStatus status,
      final double monetaryAmount,
      final String? message,
      required final int round,
      required final DateTime createdAt,
      final List<CounterOfferItem> items}) = _$CounterOfferImpl;

  factory _CounterOffer.fromJson(Map<String, dynamic> json) =
      _$CounterOfferImpl.fromJson;

  @override
  String get id;
  @override
  String get matchId;
  @override
  String get proposerId;
  @override
  CounterOfferStatus get status;
  @override
  double get monetaryAmount;
  @override
  String? get message;
  @override
  int get round;
  @override
  DateTime get createdAt;
  @override
  List<CounterOfferItem> get items;

  /// Create a copy of CounterOffer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterOfferImplCopyWith<_$CounterOfferImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CounterOfferItem _$CounterOfferItemFromJson(Map<String, dynamic> json) {
  return _CounterOfferItem.fromJson(json);
}

/// @nodoc
mixin _$CounterOfferItem {
  String get id => throw _privateConstructorUsedError;
  String get counterOfferId => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  Item? get item => throw _privateConstructorUsedError;

  /// Serializes this CounterOfferItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CounterOfferItemCopyWith<CounterOfferItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CounterOfferItemCopyWith<$Res> {
  factory $CounterOfferItemCopyWith(
          CounterOfferItem value, $Res Function(CounterOfferItem) then) =
      _$CounterOfferItemCopyWithImpl<$Res, CounterOfferItem>;
  @useResult
  $Res call({String id, String counterOfferId, String itemId, Item? item});

  $ItemCopyWith<$Res>? get item;
}

/// @nodoc
class _$CounterOfferItemCopyWithImpl<$Res, $Val extends CounterOfferItem>
    implements $CounterOfferItemCopyWith<$Res> {
  _$CounterOfferItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? counterOfferId = null,
    Object? itemId = null,
    Object? item = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      counterOfferId: null == counterOfferId
          ? _value.counterOfferId
          : counterOfferId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as Item?,
    ) as $Val);
  }

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ItemCopyWith<$Res>? get item {
    if (_value.item == null) {
      return null;
    }

    return $ItemCopyWith<$Res>(_value.item!, (value) {
      return _then(_value.copyWith(item: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CounterOfferItemImplCopyWith<$Res>
    implements $CounterOfferItemCopyWith<$Res> {
  factory _$$CounterOfferItemImplCopyWith(_$CounterOfferItemImpl value,
          $Res Function(_$CounterOfferItemImpl) then) =
      __$$CounterOfferItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String counterOfferId, String itemId, Item? item});

  @override
  $ItemCopyWith<$Res>? get item;
}

/// @nodoc
class __$$CounterOfferItemImplCopyWithImpl<$Res>
    extends _$CounterOfferItemCopyWithImpl<$Res, _$CounterOfferItemImpl>
    implements _$$CounterOfferItemImplCopyWith<$Res> {
  __$$CounterOfferItemImplCopyWithImpl(_$CounterOfferItemImpl _value,
      $Res Function(_$CounterOfferItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? counterOfferId = null,
    Object? itemId = null,
    Object? item = freezed,
  }) {
    return _then(_$CounterOfferItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      counterOfferId: null == counterOfferId
          ? _value.counterOfferId
          : counterOfferId // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      item: freezed == item
          ? _value.item
          : item // ignore: cast_nullable_to_non_nullable
              as Item?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CounterOfferItemImpl implements _CounterOfferItem {
  const _$CounterOfferItemImpl(
      {required this.id,
      required this.counterOfferId,
      required this.itemId,
      this.item});

  factory _$CounterOfferItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$CounterOfferItemImplFromJson(json);

  @override
  final String id;
  @override
  final String counterOfferId;
  @override
  final String itemId;
  @override
  final Item? item;

  @override
  String toString() {
    return 'CounterOfferItem(id: $id, counterOfferId: $counterOfferId, itemId: $itemId, item: $item)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CounterOfferItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.counterOfferId, counterOfferId) ||
                other.counterOfferId == counterOfferId) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.item, item) || other.item == item));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, counterOfferId, itemId, item);

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CounterOfferItemImplCopyWith<_$CounterOfferItemImpl> get copyWith =>
      __$$CounterOfferItemImplCopyWithImpl<_$CounterOfferItemImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CounterOfferItemImplToJson(
      this,
    );
  }
}

abstract class _CounterOfferItem implements CounterOfferItem {
  const factory _CounterOfferItem(
      {required final String id,
      required final String counterOfferId,
      required final String itemId,
      final Item? item}) = _$CounterOfferItemImpl;

  factory _CounterOfferItem.fromJson(Map<String, dynamic> json) =
      _$CounterOfferItemImpl.fromJson;

  @override
  String get id;
  @override
  String get counterOfferId;
  @override
  String get itemId;
  @override
  Item? get item;

  /// Create a copy of CounterOfferItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CounterOfferItemImplCopyWith<_$CounterOfferItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
