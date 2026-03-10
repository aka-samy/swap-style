import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/counter_offer.dart';
import '../data/counter_offers_repository.dart';

class CounterOfferState {
  final List<CounterOffer> offers;
  final bool isLoading;
  final String? error;

  const CounterOfferState({
    this.offers = const [],
    this.isLoading = false,
    this.error,
  });

  CounterOfferState copyWith({
    List<CounterOffer>? offers,
    bool? isLoading,
    String? error,
  }) =>
      CounterOfferState(
        offers: offers ?? this.offers,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class CounterOfferNotifier extends StateNotifier<CounterOfferState> {
  final CounterOffersRepository _repository;
  final String matchId;

  CounterOfferNotifier(this._repository, this.matchId)
      : super(const CounterOfferState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final offers = await _repository.listForMatch(matchId);
      state = state.copyWith(offers: offers, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<CounterOffer?> propose({
    required List<String> additionalItemIds,
    required double monetaryAmount,
    String? message,
  }) async {
    try {
      final offer = await _repository.propose(
        matchId,
        additionalItemIds: additionalItemIds,
        monetaryAmount: monetaryAmount,
        message: message,
      );
      state = state.copyWith(offers: [offer, ...state.offers]);
      return offer;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> accept(String offerId) async {
    try {
      final updated = await _repository.accept(offerId);
      state = state.copyWith(
        offers: state.offers.map((o) => o.id == offerId ? updated : o).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> decline(String offerId) async {
    try {
      final updated = await _repository.decline(offerId);
      state = state.copyWith(
        offers: state.offers.map((o) => o.id == offerId ? updated : o).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final counterOffersRepositoryProvider =
    Provider<CounterOffersRepository>((ref) {
  return CounterOffersRepository(ref.watch(apiClientProvider));
});

final counterOfferProvider = StateNotifierProvider.family<
    CounterOfferNotifier, CounterOfferState, String>((ref, matchId) {
  return CounterOfferNotifier(
    ref.watch(counterOffersRepositoryProvider),
    matchId,
  );
});
