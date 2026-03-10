// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchImpl _$$MatchImplFromJson(Map<String, dynamic> json) => _$MatchImpl(
      id: json['id'] as String,
      userAId: json['userAId'] as String,
      userBId: json['userBId'] as String,
      itemAId: json['itemAId'] as String,
      itemBId: json['itemBId'] as String,
      status: $enumDecode(_$MatchStatusEnumMap, json['status']),
      userAConfirmed: json['userAConfirmed'] as bool,
      userBConfirmed: json['userBConfirmed'] as bool,
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      expiredAt: json['expiredAt'] == null
          ? null
          : DateTime.parse(json['expiredAt'] as String),
      lastActivityAt: DateTime.parse(json['lastActivityAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      userA: json['userA'] == null
          ? null
          : MatchUser.fromJson(json['userA'] as Map<String, dynamic>),
      userB: json['userB'] == null
          ? null
          : MatchUser.fromJson(json['userB'] as Map<String, dynamic>),
      itemA: json['itemA'] == null
          ? null
          : MatchItem.fromJson(json['itemA'] as Map<String, dynamic>),
      itemB: json['itemB'] == null
          ? null
          : MatchItem.fromJson(json['itemB'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$MatchImplToJson(_$MatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userAId': instance.userAId,
      'userBId': instance.userBId,
      'itemAId': instance.itemAId,
      'itemBId': instance.itemBId,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'userAConfirmed': instance.userAConfirmed,
      'userBConfirmed': instance.userBConfirmed,
      'completedAt': instance.completedAt?.toIso8601String(),
      'expiredAt': instance.expiredAt?.toIso8601String(),
      'lastActivityAt': instance.lastActivityAt.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
      'userA': instance.userA,
      'userB': instance.userB,
      'itemA': instance.itemA,
      'itemB': instance.itemB,
    };

const _$MatchStatusEnumMap = {
  MatchStatus.pending: 'pending',
  MatchStatus.negotiating: 'negotiating',
  MatchStatus.agreed: 'agreed',
  MatchStatus.awaitingConfirmation: 'awaiting_confirmation',
  MatchStatus.completed: 'completed',
  MatchStatus.canceled: 'canceled',
  MatchStatus.expired: 'expired',
};

_$MatchUserImpl _$$MatchUserImplFromJson(Map<String, dynamic> json) =>
    _$MatchUserImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
    );

Map<String, dynamic> _$$MatchUserImplToJson(_$MatchUserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'profilePhotoUrl': instance.profilePhotoUrl,
      'emailVerified': instance.emailVerified,
    };

_$MatchItemImpl _$$MatchItemImplFromJson(Map<String, dynamic> json) =>
    _$MatchItemImpl(
      id: json['id'] as String,
      brand: json['brand'] as String,
      category: json['category'] as String?,
      size: json['size'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => MatchItemPhoto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$MatchItemImplToJson(_$MatchItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'brand': instance.brand,
      'category': instance.category,
      'size': instance.size,
      'photos': instance.photos,
    };

_$MatchItemPhotoImpl _$$MatchItemPhotoImplFromJson(Map<String, dynamic> json) =>
    _$MatchItemPhotoImpl(
      url: json['url'] as String,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$MatchItemPhotoImplToJson(
        _$MatchItemPhotoImpl instance) =>
    <String, dynamic>{
      'url': instance.url,
      'sortOrder': instance.sortOrder,
    };
