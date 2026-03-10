import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

enum MatchStatus {
  pending,
  negotiating,
  agreed,
  @JsonValue('awaiting_confirmation')
  awaitingConfirmation,
  completed,
  canceled,
  expired,
}

@freezed
class Match with _$Match {
  const factory Match({
    required String id,
    required String userAId,
    required String userBId,
    required String itemAId,
    required String itemBId,
    required MatchStatus status,
    required bool userAConfirmed,
    required bool userBConfirmed,
    DateTime? completedAt,
    DateTime? expiredAt,
    required DateTime lastActivityAt,
    required DateTime createdAt,
    MatchUser? userA,
    MatchUser? userB,
    MatchItem? itemA,
    MatchItem? itemB,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);
}

@freezed
class MatchUser with _$MatchUser {
  const factory MatchUser({
    required String id,
    required String displayName,
    String? profilePhotoUrl,
    @Default(false) bool emailVerified,
  }) = _MatchUser;

  factory MatchUser.fromJson(Map<String, dynamic> json) =>
      _$MatchUserFromJson(json);
}

@freezed
class MatchItem with _$MatchItem {
  const factory MatchItem({
    required String id,
    required String brand,
    String? category,
    String? size,
    @Default([]) List<MatchItemPhoto> photos,
  }) = _MatchItem;

  factory MatchItem.fromJson(Map<String, dynamic> json) =>
      _$MatchItemFromJson(json);
}

@freezed
class MatchItemPhoto with _$MatchItemPhoto {
  const factory MatchItemPhoto({
    required String url,
    @Default(0) int sortOrder,
  }) = _MatchItemPhoto;

  factory MatchItemPhoto.fromJson(Map<String, dynamic> json) =>
      _$MatchItemPhotoFromJson(json);
}
