import 'package:freezed_annotation/freezed_annotation.dart';

part 'gamification.g.dart';
part 'gamification.freezed.dart';

@freezed
class Streak with _$Streak {
  const factory Streak({
    required String id,
    required String userId,
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActivityAt,
    required DateTime updatedAt,
  }) = _Streak;

  factory Streak.fromJson(Map<String, dynamic> json) =>
      _$StreakFromJson(json);
}

@freezed
class Badge with _$Badge {
  const factory Badge({
    required String id,
    required String slug,
    required String name,
    required String description,
    required String iconUrl,
    required DateTime awardedAt,
  }) = _Badge;

  factory Badge.fromJson(Map<String, dynamic> json) => _$BadgeFromJson(json);
}

@freezed
class GamificationStats with _$GamificationStats {
  const factory GamificationStats({
    Streak? streak,
    @Default([]) List<Badge> badges,
  }) = _GamificationStats;

  factory GamificationStats.fromJson(Map<String, dynamic> json) =>
      _$GamificationStatsFromJson(json);
}
