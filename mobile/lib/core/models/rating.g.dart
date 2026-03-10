// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rating.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RatingImpl _$$RatingImplFromJson(Map<String, dynamic> json) => _$RatingImpl(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      raterId: json['raterId'] as String,
      rateeId: json['rateeId'] as String,
      score: (json['score'] as num).toInt(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      rater: json['rater'] == null
          ? null
          : RaterSummary.fromJson(json['rater'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$RatingImplToJson(_$RatingImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'matchId': instance.matchId,
      'raterId': instance.raterId,
      'rateeId': instance.rateeId,
      'score': instance.score,
      'comment': instance.comment,
      'createdAt': instance.createdAt.toIso8601String(),
      'rater': instance.rater,
    };

_$RaterSummaryImpl _$$RaterSummaryImplFromJson(Map<String, dynamic> json) =>
    _$RaterSummaryImpl(
      id: json['id'] as String,
      displayName: json['displayName'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );

Map<String, dynamic> _$$RaterSummaryImplToJson(_$RaterSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displayName': instance.displayName,
      'profilePhotoUrl': instance.profilePhotoUrl,
    };

_$RatingsPageImpl _$$RatingsPageImplFromJson(Map<String, dynamic> json) =>
    _$RatingsPageImpl(
      ratings: (json['ratings'] as List<dynamic>)
          .map((e) => Rating.fromJson(e as Map<String, dynamic>))
          .toList(),
      average: (json['average'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$$RatingsPageImplToJson(_$RatingsPageImpl instance) =>
    <String, dynamic>{
      'ratings': instance.ratings,
      'average': instance.average,
    };
