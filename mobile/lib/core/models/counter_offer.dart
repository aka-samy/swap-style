import 'package:freezed_annotation/freezed_annotation.dart';
import 'item.dart';

part 'counter_offer.freezed.dart';
part 'counter_offer.g.dart';

enum CounterOfferStatus { pending, accepted, declined, superseded }

@freezed
class CounterOffer with _$CounterOffer {
  const factory CounterOffer({
    required String id,
    required String matchId,
    required String proposerId,
    required CounterOfferStatus status,
    @Default(0) double monetaryAmount,
    String? message,
    required int round,
    required DateTime createdAt,
    @Default([]) List<CounterOfferItem> items,
  }) = _CounterOffer;

  factory CounterOffer.fromJson(Map<String, dynamic> json) =>
      _$CounterOfferFromJson(json);
}

@freezed
class CounterOfferItem with _$CounterOfferItem {
  const factory CounterOfferItem({
    required String id,
    required String counterOfferId,
    required String itemId,
    Item? item,
  }) = _CounterOfferItem;

  factory CounterOfferItem.fromJson(Map<String, dynamic> json) =>
      _$CounterOfferItemFromJson(json);
}
