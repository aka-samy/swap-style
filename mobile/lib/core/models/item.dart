import 'package:freezed_annotation/freezed_annotation.dart';

part 'item.freezed.dart';
part 'item.g.dart';

enum ItemCategory {
  @JsonValue('Shirt')
  shirt,
  @JsonValue('Hoodie')
  hoodie,
  @JsonValue('Pants')
  pants,
  @JsonValue('Shoes')
  shoes,
  @JsonValue('Jacket')
  jacket,
  @JsonValue('Dress')
  dress,
  @JsonValue('Accessories')
  accessories,
  @JsonValue('Other')
  other,
}

enum ItemSize {
  @JsonValue('XS')
  xs,
  @JsonValue('S')
  s,
  @JsonValue('M')
  m,
  @JsonValue('L')
  l,
  @JsonValue('XL')
  xl,
  @JsonValue('XXL')
  xxl,
  @JsonValue('ONE_SIZE')
  oneSize,
}

enum ItemCondition {
  @JsonValue('New')
  newItem,
  @JsonValue('LikeNew')
  likeNew,
  @JsonValue('Good')
  good,
  @JsonValue('Fair')
  fair,
}

enum ItemStatus { available, swapped, removed }

@freezed
class Item with _$Item {
  const factory Item({
    required String id,
    required String ownerId,
    required ItemCategory category,
    required String brand,
    required ItemSize size,
    required ItemCondition condition,
    String? notes,
    required double latitude,
    required double longitude,
    required ItemStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
    @Default([]) List<ItemPhoto> photos,
    ItemVerification? verification,
  }) = _Item;

  factory Item.fromJson(Map<String, dynamic> json) => _$ItemFromJson(json);
}

@freezed
class ItemPhoto with _$ItemPhoto {
  const factory ItemPhoto({
    required String id,
    required String itemId,
    required String url,
    String? thumbnailUrl,
    required int sortOrder,
    required DateTime createdAt,
  }) = _ItemPhoto;

  factory ItemPhoto.fromJson(Map<String, dynamic> json) =>
      _$ItemPhotoFromJson(json);
}

@freezed
class ItemVerification with _$ItemVerification {
  const factory ItemVerification({
    required String id,
    required String itemId,
    required bool washed,
    required bool noStains,
    required bool noTears,
    required bool noDefects,
    required bool photosAccurate,
    required DateTime verifiedAt,
  }) = _ItemVerification;

  factory ItemVerification.fromJson(Map<String, dynamic> json) =>
      _$ItemVerificationFromJson(json);
}
