// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      email: json['email'] as String?,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      bio: json['bio'] as String?,
      emailVerified: json['emailVerified'] as bool,
      phoneVerified: json['phoneVerified'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      stats: json['stats'] == null
          ? null
          : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'email': instance.email,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'bio': instance.bio,
      'emailVerified': instance.emailVerified,
      'phoneVerified': instance.phoneVerified,
      'createdAt': instance.createdAt.toIso8601String(),
      'stats': instance.stats,
    };

_$UserStatsImpl _$$UserStatsImplFromJson(Map<String, dynamic> json) =>
    _$UserStatsImpl(
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble(),
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$UserStatsImplToJson(_$UserStatsImpl instance) =>
    <String, dynamic>{
      'itemCount': instance.itemCount,
      'averageRating': instance.averageRating,
      'ratingCount': instance.ratingCount,
    };

_$WishlistEntryImpl _$$WishlistEntryImplFromJson(Map<String, dynamic> json) =>
    _$WishlistEntryImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      size: json['size'] as String?,
      brand: json['brand'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$WishlistEntryImplToJson(_$WishlistEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'category': instance.category,
      'size': instance.size,
      'brand': instance.brand,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
    };
