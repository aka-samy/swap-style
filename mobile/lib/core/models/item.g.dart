// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ItemImpl _$$ItemImplFromJson(Map<String, dynamic> json) => _$ItemImpl(
      id: json['id'] as String,
      ownerId: json['ownerId'] as String,
      category: $enumDecode(_$ItemCategoryEnumMap, json['category']),
      brand: json['brand'] as String,
      size: $enumDecode(_$ItemSizeEnumMap, json['size']),
      condition: $enumDecode(_$ItemConditionEnumMap, json['condition']),
      notes: json['notes'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: $enumDecode(_$ItemStatusEnumMap, json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => ItemPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      verification: json['verification'] == null
          ? null
          : ItemVerification.fromJson(
              json['verification'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ItemImplToJson(_$ItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'category': _$ItemCategoryEnumMap[instance.category]!,
      'brand': instance.brand,
      'size': _$ItemSizeEnumMap[instance.size]!,
      'condition': _$ItemConditionEnumMap[instance.condition]!,
      'notes': instance.notes,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'status': _$ItemStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'photos': instance.photos,
      'verification': instance.verification,
    };

const _$ItemCategoryEnumMap = {
  ItemCategory.shirt: 'Shirt',
  ItemCategory.hoodie: 'Hoodie',
  ItemCategory.pants: 'Pants',
  ItemCategory.shoes: 'Shoes',
  ItemCategory.jacket: 'Jacket',
  ItemCategory.dress: 'Dress',
  ItemCategory.accessories: 'Accessories',
  ItemCategory.other: 'Other',
};

const _$ItemSizeEnumMap = {
  ItemSize.xs: 'XS',
  ItemSize.s: 'S',
  ItemSize.m: 'M',
  ItemSize.l: 'L',
  ItemSize.xl: 'XL',
  ItemSize.xxl: 'XXL',
  ItemSize.oneSize: 'ONE_SIZE',
};

const _$ItemConditionEnumMap = {
  ItemCondition.newItem: 'New',
  ItemCondition.likeNew: 'LikeNew',
  ItemCondition.good: 'Good',
  ItemCondition.fair: 'Fair',
};

const _$ItemStatusEnumMap = {
  ItemStatus.available: 'available',
  ItemStatus.swapped: 'swapped',
  ItemStatus.removed: 'removed',
};

_$ItemPhotoImpl _$$ItemPhotoImplFromJson(Map<String, dynamic> json) =>
    _$ItemPhotoImpl(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      url: json['url'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      sortOrder: (json['sortOrder'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ItemPhotoImplToJson(_$ItemPhotoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'url': instance.url,
      'thumbnailUrl': instance.thumbnailUrl,
      'sortOrder': instance.sortOrder,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$ItemVerificationImpl _$$ItemVerificationImplFromJson(
        Map<String, dynamic> json) =>
    _$ItemVerificationImpl(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      washed: json['washed'] as bool,
      noStains: json['noStains'] as bool,
      noTears: json['noTears'] as bool,
      noDefects: json['noDefects'] as bool,
      photosAccurate: json['photosAccurate'] as bool,
      verifiedAt: DateTime.parse(json['verifiedAt'] as String),
    );

Map<String, dynamic> _$$ItemVerificationImplToJson(
        _$ItemVerificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'itemId': instance.itemId,
      'washed': instance.washed,
      'noStains': instance.noStains,
      'noTears': instance.noTears,
      'noDefects': instance.noDefects,
      'photosAccurate': instance.photosAccurate,
      'verifiedAt': instance.verifiedAt.toIso8601String(),
    };
