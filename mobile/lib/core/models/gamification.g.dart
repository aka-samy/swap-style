// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gamification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$StreakImpl _$$StreakImplFromJson(Map<String, dynamic> json) => _$StreakImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      currentStreak: (json['currentStreak'] as num).toInt(),
      longestStreak: (json['longestStreak'] as num).toInt(),
      lastActivityAt: json['lastActivityAt'] == null
          ? null
          : DateTime.parse(json['lastActivityAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$StreakImplToJson(_$StreakImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'currentStreak': instance.currentStreak,
      'longestStreak': instance.longestStreak,
      'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

_$BadgeImpl _$$BadgeImplFromJson(Map<String, dynamic> json) => _$BadgeImpl(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      awardedAt: DateTime.parse(json['awardedAt'] as String),
    );

Map<String, dynamic> _$$BadgeImplToJson(_$BadgeImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': instance.slug,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'awardedAt': instance.awardedAt.toIso8601String(),
    };

_$GamificationStatsImpl _$$GamificationStatsImplFromJson(
        Map<String, dynamic> json) =>
    _$GamificationStatsImpl(
      streak: json['streak'] == null
          ? null
          : Streak.fromJson(json['streak'] as Map<String, dynamic>),
      badges: (json['badges'] as List<dynamic>?)
              ?.map((e) => Badge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GamificationStatsImplToJson(
        _$GamificationStatsImpl instance) =>
    <String, dynamic>{
      'streak': instance.streak,
      'badges': instance.badges,
    };
