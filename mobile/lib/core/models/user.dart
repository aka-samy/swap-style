import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String displayName,
    String? email,
    String? profilePhotoUrl,
    String? bio,
    required bool emailVerified,
    required bool phoneVerified,
    required DateTime createdAt,
    UserStats? stats,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

@freezed
class UserStats with _$UserStats {
  const factory UserStats({
    @Default(0) int itemCount,
    double? averageRating,
    @Default(0) int ratingCount,
  }) = _UserStats;

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);
}

@freezed
class WishlistEntry with _$WishlistEntry {
  const factory WishlistEntry({
    required String id,
    required String userId,
    required String category,
    String? size,
    String? brand,
    String? notes,
    required DateTime createdAt,
  }) = _WishlistEntry;

  factory WishlistEntry.fromJson(Map<String, dynamic> json) =>
      _$WishlistEntryFromJson(json);
}
