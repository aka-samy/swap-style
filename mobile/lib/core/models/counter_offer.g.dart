// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'counter_offer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CounterOfferImpl _$$CounterOfferImplFromJson(Map<String, dynamic> json) =>
    _$CounterOfferImpl(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      proposerId: json['proposerId'] as String,
      status: $enumDecode(_$CounterOfferStatusEnumMap, json['status']),
      monetaryAmount: (json['monetaryAmount'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String?,
      round: (json['round'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => CounterOfferItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CounterOfferImplToJson(_$CounterOfferImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'proposerId': instance.proposerId,
      'status': _$CounterOfferStatusEnumMap[instance.status]!,
      'monetaryAmount': instance.monetaryAmount,
      'message': instance.message,
      'round': instance.round,
      'createdAt': instance.createdAt.toIso8601String(),
      'items': instance.items,
    };

const _$CounterOfferStatusEnumMap = {
  CounterOfferStatus.pending: 'pending',
  CounterOfferStatus.accepted: 'accepted',
  CounterOfferStatus.declined: 'declined',
  CounterOfferStatus.superseded: 'superseded',
};

_$CounterOfferItemImpl _$$CounterOfferItemImplFromJson(
        Map<String, dynamic> json) =>
    _$CounterOfferItemImpl(
      id: json['id'] as String,
      counterOfferId: json['counterOfferId'] as String,
      itemId: json['itemId'] as String,
      item: json['item'] == null
          ? null
          : Item.fromJson(json['item'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CounterOfferItemImplToJson(
        _$CounterOfferItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'counterOfferId': instance.counterOfferId,
      'itemId': instance.itemId,
      'item': instance.item,
    };
