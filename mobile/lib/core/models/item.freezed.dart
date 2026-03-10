// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Item _$ItemFromJson(Map<String, dynamic> json) {
  return _Item.fromJson(json);
}

/// @nodoc
mixin _$Item {
  String get id => throw _privateConstructorUsedError;
  String get ownerId => throw _privateConstructorUsedError;
  ItemCategory get category => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  ItemSize get size => throw _privateConstructorUsedError;
  ItemCondition get condition => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  ItemStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;
  List<ItemPhoto> get photos => throw _privateConstructorUsedError;
  ItemVerification? get verification => throw _privateConstructorUsedError;

  /// Serializes this Item to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemCopyWith<Item> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemCopyWith<$Res> {
  factory $ItemCopyWith(Item value, $Res Function(Item) then) =
      _$ItemCopyWithImpl<$Res, Item>;
  @useResult
  $Res call(
      {String id,
      String ownerId,
      ItemCategory category,
      String brand,
      ItemSize size,
      ItemCondition condition,
      String? notes,
      double latitude,
      double longitude,
      ItemStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      List<ItemPhoto> photos,
      ItemVerification? verification});

  $ItemVerificationCopyWith<$Res>? get verification;
}

/// @nodoc
class _$ItemCopyWithImpl<$Res, $Val extends Item>
    implements $ItemCopyWith<$Res> {
  _$ItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? category = null,
    Object? brand = null,
    Object? size = null,
    Object? condition = null,
    Object? notes = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? photos = null,
    Object? verification = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ItemCategory,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as ItemSize,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ItemCondition,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ItemStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      photos: null == photos
          ? _value.photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ItemPhoto>,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as ItemVerification?,
    ) as $Val);
  }

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ItemVerificationCopyWith<$Res>? get verification {
    if (_value.verification == null) {
      return null;
    }

    return $ItemVerificationCopyWith<$Res>(_value.verification!, (value) {
      return _then(_value.copyWith(verification: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ItemImplCopyWith<$Res> implements $ItemCopyWith<$Res> {
  factory _$$ItemImplCopyWith(
          _$ItemImpl value, $Res Function(_$ItemImpl) then) =
      __$$ItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String ownerId,
      ItemCategory category,
      String brand,
      ItemSize size,
      ItemCondition condition,
      String? notes,
      double latitude,
      double longitude,
      ItemStatus status,
      DateTime createdAt,
      DateTime updatedAt,
      List<ItemPhoto> photos,
      ItemVerification? verification});

  @override
  $ItemVerificationCopyWith<$Res>? get verification;
}

/// @nodoc
class __$$ItemImplCopyWithImpl<$Res>
    extends _$ItemCopyWithImpl<$Res, _$ItemImpl>
    implements _$$ItemImplCopyWith<$Res> {
  __$$ItemImplCopyWithImpl(_$ItemImpl _value, $Res Function(_$ItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? category = null,
    Object? brand = null,
    Object? size = null,
    Object? condition = null,
    Object? notes = freezed,
    Object? latitude = null,
    Object? longitude = null,
    Object? status = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? photos = null,
    Object? verification = freezed,
  }) {
    return _then(_$ItemImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as ItemCategory,
      brand: null == brand
          ? _value.brand
          : brand // ignore: cast_nullable_to_non_nullable
              as String,
      size: null == size
          ? _value.size
          : size // ignore: cast_nullable_to_non_nullable
              as ItemSize,
      condition: null == condition
          ? _value.condition
          : condition // ignore: cast_nullable_to_non_nullable
              as ItemCondition,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as ItemStatus,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      photos: null == photos
          ? _value._photos
          : photos // ignore: cast_nullable_to_non_nullable
              as List<ItemPhoto>,
      verification: freezed == verification
          ? _value.verification
          : verification // ignore: cast_nullable_to_non_nullable
              as ItemVerification?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemImpl implements _Item {
  const _$ItemImpl(
      {required this.id,
      required this.ownerId,
      required this.category,
      required this.brand,
      required this.size,
      required this.condition,
      this.notes,
      required this.latitude,
      required this.longitude,
      required this.status,
      required this.createdAt,
      required this.updatedAt,
      final List<ItemPhoto> photos = const [],
      this.verification})
      : _photos = photos;

  factory _$ItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemImplFromJson(json);

  @override
  final String id;
  @override
  final String ownerId;
  @override
  final ItemCategory category;
  @override
  final String brand;
  @override
  final ItemSize size;
  @override
  final ItemCondition condition;
  @override
  final String? notes;
  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final ItemStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  final List<ItemPhoto> _photos;
  @override
  @JsonKey()
  List<ItemPhoto> get photos {
    if (_photos is EqualUnmodifiableListView) return _photos;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photos);
  }

  @override
  final ItemVerification? verification;

  @override
  String toString() {
    return 'Item(id: $id, ownerId: $ownerId, category: $category, brand: $brand, size: $size, condition: $condition, notes: $notes, latitude: $latitude, longitude: $longitude, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, photos: $photos, verification: $verification)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.condition, condition) ||
                other.condition == condition) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(other._photos, _photos) &&
            (identical(other.verification, verification) ||
                other.verification == verification));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      ownerId,
      category,
      brand,
      size,
      condition,
      notes,
      latitude,
      longitude,
      status,
      createdAt,
      updatedAt,
      const DeepCollectionEquality().hash(_photos),
      verification);

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      __$$ItemImplCopyWithImpl<_$ItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemImplToJson(
      this,
    );
  }
}

abstract class _Item implements Item {
  const factory _Item(
      {required final String id,
      required final String ownerId,
      required final ItemCategory category,
      required final String brand,
      required final ItemSize size,
      required final ItemCondition condition,
      final String? notes,
      required final double latitude,
      required final double longitude,
      required final ItemStatus status,
      required final DateTime createdAt,
      required final DateTime updatedAt,
      final List<ItemPhoto> photos,
      final ItemVerification? verification}) = _$ItemImpl;

  factory _Item.fromJson(Map<String, dynamic> json) = _$ItemImpl.fromJson;

  @override
  String get id;
  @override
  String get ownerId;
  @override
  ItemCategory get category;
  @override
  String get brand;
  @override
  ItemSize get size;
  @override
  ItemCondition get condition;
  @override
  String? get notes;
  @override
  double get latitude;
  @override
  double get longitude;
  @override
  ItemStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;
  @override
  List<ItemPhoto> get photos;
  @override
  ItemVerification? get verification;

  /// Create a copy of Item
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemImplCopyWith<_$ItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemPhoto _$ItemPhotoFromJson(Map<String, dynamic> json) {
  return _ItemPhoto.fromJson(json);
}

/// @nodoc
mixin _$ItemPhoto {
  String get id => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  int get sortOrder => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ItemPhoto to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemPhotoCopyWith<ItemPhoto> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemPhotoCopyWith<$Res> {
  factory $ItemPhotoCopyWith(ItemPhoto value, $Res Function(ItemPhoto) then) =
      _$ItemPhotoCopyWithImpl<$Res, ItemPhoto>;
  @useResult
  $Res call(
      {String id,
      String itemId,
      String url,
      String? thumbnailUrl,
      int sortOrder,
      DateTime createdAt});
}

/// @nodoc
class _$ItemPhotoCopyWithImpl<$Res, $Val extends ItemPhoto>
    implements $ItemPhotoCopyWith<$Res> {
  _$ItemPhotoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemPhotoImplCopyWith<$Res>
    implements $ItemPhotoCopyWith<$Res> {
  factory _$$ItemPhotoImplCopyWith(
          _$ItemPhotoImpl value, $Res Function(_$ItemPhotoImpl) then) =
      __$$ItemPhotoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String itemId,
      String url,
      String? thumbnailUrl,
      int sortOrder,
      DateTime createdAt});
}

/// @nodoc
class __$$ItemPhotoImplCopyWithImpl<$Res>
    extends _$ItemPhotoCopyWithImpl<$Res, _$ItemPhotoImpl>
    implements _$$ItemPhotoImplCopyWith<$Res> {
  __$$ItemPhotoImplCopyWithImpl(
      _$ItemPhotoImpl _value, $Res Function(_$ItemPhotoImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? url = null,
    Object? thumbnailUrl = freezed,
    Object? sortOrder = null,
    Object? createdAt = null,
  }) {
    return _then(_$ItemPhotoImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      thumbnailUrl: freezed == thumbnailUrl
          ? _value.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      sortOrder: null == sortOrder
          ? _value.sortOrder
          : sortOrder // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemPhotoImpl implements _ItemPhoto {
  const _$ItemPhotoImpl(
      {required this.id,
      required this.itemId,
      required this.url,
      this.thumbnailUrl,
      required this.sortOrder,
      required this.createdAt});

  factory _$ItemPhotoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemPhotoImplFromJson(json);

  @override
  final String id;
  @override
  final String itemId;
  @override
  final String url;
  @override
  final String? thumbnailUrl;
  @override
  final int sortOrder;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ItemPhoto(id: $id, itemId: $itemId, url: $url, thumbnailUrl: $thumbnailUrl, sortOrder: $sortOrder, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemPhotoImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.sortOrder, sortOrder) ||
                other.sortOrder == sortOrder) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, itemId, url, thumbnailUrl, sortOrder, createdAt);

  /// Create a copy of ItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemPhotoImplCopyWith<_$ItemPhotoImpl> get copyWith =>
      __$$ItemPhotoImplCopyWithImpl<_$ItemPhotoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemPhotoImplToJson(
      this,
    );
  }
}

abstract class _ItemPhoto implements ItemPhoto {
  const factory _ItemPhoto(
      {required final String id,
      required final String itemId,
      required final String url,
      final String? thumbnailUrl,
      required final int sortOrder,
      required final DateTime createdAt}) = _$ItemPhotoImpl;

  factory _ItemPhoto.fromJson(Map<String, dynamic> json) =
      _$ItemPhotoImpl.fromJson;

  @override
  String get id;
  @override
  String get itemId;
  @override
  String get url;
  @override
  String? get thumbnailUrl;
  @override
  int get sortOrder;
  @override
  DateTime get createdAt;

  /// Create a copy of ItemPhoto
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemPhotoImplCopyWith<_$ItemPhotoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ItemVerification _$ItemVerificationFromJson(Map<String, dynamic> json) {
  return _ItemVerification.fromJson(json);
}

/// @nodoc
mixin _$ItemVerification {
  String get id => throw _privateConstructorUsedError;
  String get itemId => throw _privateConstructorUsedError;
  bool get washed => throw _privateConstructorUsedError;
  bool get noStains => throw _privateConstructorUsedError;
  bool get noTears => throw _privateConstructorUsedError;
  bool get noDefects => throw _privateConstructorUsedError;
  bool get photosAccurate => throw _privateConstructorUsedError;
  DateTime get verifiedAt => throw _privateConstructorUsedError;

  /// Serializes this ItemVerification to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ItemVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ItemVerificationCopyWith<ItemVerification> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ItemVerificationCopyWith<$Res> {
  factory $ItemVerificationCopyWith(
          ItemVerification value, $Res Function(ItemVerification) then) =
      _$ItemVerificationCopyWithImpl<$Res, ItemVerification>;
  @useResult
  $Res call(
      {String id,
      String itemId,
      bool washed,
      bool noStains,
      bool noTears,
      bool noDefects,
      bool photosAccurate,
      DateTime verifiedAt});
}

/// @nodoc
class _$ItemVerificationCopyWithImpl<$Res, $Val extends ItemVerification>
    implements $ItemVerificationCopyWith<$Res> {
  _$ItemVerificationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ItemVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? washed = null,
    Object? noStains = null,
    Object? noTears = null,
    Object? noDefects = null,
    Object? photosAccurate = null,
    Object? verifiedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      washed: null == washed
          ? _value.washed
          : washed // ignore: cast_nullable_to_non_nullable
              as bool,
      noStains: null == noStains
          ? _value.noStains
          : noStains // ignore: cast_nullable_to_non_nullable
              as bool,
      noTears: null == noTears
          ? _value.noTears
          : noTears // ignore: cast_nullable_to_non_nullable
              as bool,
      noDefects: null == noDefects
          ? _value.noDefects
          : noDefects // ignore: cast_nullable_to_non_nullable
              as bool,
      photosAccurate: null == photosAccurate
          ? _value.photosAccurate
          : photosAccurate // ignore: cast_nullable_to_non_nullable
              as bool,
      verifiedAt: null == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ItemVerificationImplCopyWith<$Res>
    implements $ItemVerificationCopyWith<$Res> {
  factory _$$ItemVerificationImplCopyWith(_$ItemVerificationImpl value,
          $Res Function(_$ItemVerificationImpl) then) =
      __$$ItemVerificationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String itemId,
      bool washed,
      bool noStains,
      bool noTears,
      bool noDefects,
      bool photosAccurate,
      DateTime verifiedAt});
}

/// @nodoc
class __$$ItemVerificationImplCopyWithImpl<$Res>
    extends _$ItemVerificationCopyWithImpl<$Res, _$ItemVerificationImpl>
    implements _$$ItemVerificationImplCopyWith<$Res> {
  __$$ItemVerificationImplCopyWithImpl(_$ItemVerificationImpl _value,
      $Res Function(_$ItemVerificationImpl) _then)
      : super(_value, _then);

  /// Create a copy of ItemVerification
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? itemId = null,
    Object? washed = null,
    Object? noStains = null,
    Object? noTears = null,
    Object? noDefects = null,
    Object? photosAccurate = null,
    Object? verifiedAt = null,
  }) {
    return _then(_$ItemVerificationImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      itemId: null == itemId
          ? _value.itemId
          : itemId // ignore: cast_nullable_to_non_nullable
              as String,
      washed: null == washed
          ? _value.washed
          : washed // ignore: cast_nullable_to_non_nullable
              as bool,
      noStains: null == noStains
          ? _value.noStains
          : noStains // ignore: cast_nullable_to_non_nullable
              as bool,
      noTears: null == noTears
          ? _value.noTears
          : noTears // ignore: cast_nullable_to_non_nullable
              as bool,
      noDefects: null == noDefects
          ? _value.noDefects
          : noDefects // ignore: cast_nullable_to_non_nullable
              as bool,
      photosAccurate: null == photosAccurate
          ? _value.photosAccurate
          : photosAccurate // ignore: cast_nullable_to_non_nullable
              as bool,
      verifiedAt: null == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ItemVerificationImpl implements _ItemVerification {
  const _$ItemVerificationImpl(
      {required this.id,
      required this.itemId,
      required this.washed,
      required this.noStains,
      required this.noTears,
      required this.noDefects,
      required this.photosAccurate,
      required this.verifiedAt});

  factory _$ItemVerificationImpl.fromJson(Map<String, dynamic> json) =>
      _$$ItemVerificationImplFromJson(json);

  @override
  final String id;
  @override
  final String itemId;
  @override
  final bool washed;
  @override
  final bool noStains;
  @override
  final bool noTears;
  @override
  final bool noDefects;
  @override
  final bool photosAccurate;
  @override
  final DateTime verifiedAt;

  @override
  String toString() {
    return 'ItemVerification(id: $id, itemId: $itemId, washed: $washed, noStains: $noStains, noTears: $noTears, noDefects: $noDefects, photosAccurate: $photosAccurate, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ItemVerificationImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.itemId, itemId) || other.itemId == itemId) &&
            (identical(other.washed, washed) || other.washed == washed) &&
            (identical(other.noStains, noStains) ||
                other.noStains == noStains) &&
            (identical(other.noTears, noTears) || other.noTears == noTears) &&
            (identical(other.noDefects, noDefects) ||
                other.noDefects == noDefects) &&
            (identical(other.photosAccurate, photosAccurate) ||
                other.photosAccurate == photosAccurate) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, itemId, washed, noStains,
      noTears, noDefects, photosAccurate, verifiedAt);

  /// Create a copy of ItemVerification
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ItemVerificationImplCopyWith<_$ItemVerificationImpl> get copyWith =>
      __$$ItemVerificationImplCopyWithImpl<_$ItemVerificationImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ItemVerificationImplToJson(
      this,
    );
  }
}

abstract class _ItemVerification implements ItemVerification {
  const factory _ItemVerification(
      {required final String id,
      required final String itemId,
      required final bool washed,
      required final bool noStains,
      required final bool noTears,
      required final bool noDefects,
      required final bool photosAccurate,
      required final DateTime verifiedAt}) = _$ItemVerificationImpl;

  factory _ItemVerification.fromJson(Map<String, dynamic> json) =
      _$ItemVerificationImpl.fromJson;

  @override
  String get id;
  @override
  String get itemId;
  @override
  bool get washed;
  @override
  bool get noStains;
  @override
  bool get noTears;
  @override
  bool get noDefects;
  @override
  bool get photosAccurate;
  @override
  DateTime get verifiedAt;

  /// Create a copy of ItemVerification
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ItemVerificationImplCopyWith<_$ItemVerificationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
