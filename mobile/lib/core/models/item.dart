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

extension ItemCategoryX on ItemCategory {
  String get apiValue {
    switch (this) {
      case ItemCategory.shirt:
        return 'Shirt';
      case ItemCategory.hoodie:
        return 'Hoodie';
      case ItemCategory.pants:
        return 'Pants';
      case ItemCategory.shoes:
        return 'Shoes';
      case ItemCategory.jacket:
        return 'Jacket';
      case ItemCategory.dress:
        return 'Dress';
      case ItemCategory.accessories:
        return 'Accessories';
      case ItemCategory.other:
        return 'Other';
    }
  }
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

extension ItemSizeX on ItemSize {
  String get apiValue {
    switch (this) {
      case ItemSize.xs:
        return 'XS';
      case ItemSize.s:
        return 'S';
      case ItemSize.m:
        return 'M';
      case ItemSize.l:
        return 'L';
      case ItemSize.xl:
        return 'XL';
      case ItemSize.xxl:
        return 'XXL';
      case ItemSize.oneSize:
        return 'ONE_SIZE';
    }
  }

  String get label {
    return this == ItemSize.oneSize ? 'ONE SIZE' : apiValue;
  }
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

extension ItemConditionX on ItemCondition {
  String get apiValue {
    switch (this) {
      case ItemCondition.newItem:
        return 'New';
      case ItemCondition.likeNew:
        return 'LikeNew';
      case ItemCondition.good:
        return 'Good';
      case ItemCondition.fair:
        return 'Fair';
    }
  }
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
    double? shoeSizeEu,
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
