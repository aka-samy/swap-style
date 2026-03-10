import 'package:freezed_annotation/freezed_annotation.dart';

part 'rating.g.dart';
part 'rating.freezed.dart';

@freezed
class Rating with _$Rating {
  const factory Rating({
    required String id,
    required String matchId,
    required String raterId,
    required String rateeId,
    required int score,
    String? comment,
    required DateTime createdAt,
    RaterSummary? rater,
  }) = _Rating;

  factory Rating.fromJson(Map<String, dynamic> json) => _$RatingFromJson(json);
}

@freezed
class RaterSummary with _$RaterSummary {
  const factory RaterSummary({
    required String id,
    required String displayName,
    String? profilePhotoUrl,
  }) = _RaterSummary;

  factory RaterSummary.fromJson(Map<String, dynamic> json) =>
      _$RaterSummaryFromJson(json);
}

@freezed
class RatingsPage with _$RatingsPage {
  const factory RatingsPage({
    required List<Rating> ratings,
    @Default(0) double average,
  }) = _RatingsPage;

  factory RatingsPage.fromJson(Map<String, dynamic> json) =>
      _$RatingsPageFromJson(json);
}
