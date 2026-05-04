import '../../../core/api/api_client.dart';
import '../../../core/models/counter_offer.dart';

class CounterOffersRepository {
  final ApiClient _client;
  CounterOffersRepository(this._client);

  Future<CounterOffer> propose(
    String matchId, {
    required List<String> additionalItemIds,
    required double monetaryAmount,
    String? message,
  }) async {
    final response = await _client.dio.post(
      '/matches/$matchId/counter-offers',
      data: {
        'items': additionalItemIds.map((id) => {'itemId': id}).toList(),
        'monetaryAmount': monetaryAmount,
        if (message != null) 'message': message,
      },
    );
    return CounterOffer.fromJson(response.data);
  }

  Future<List<CounterOffer>> listForMatch(String matchId) async {
    final response = await _client.dio.get('/matches/$matchId/counter-offers');
    return (response.data as List)
        .map((e) => CounterOffer.fromJson(e))
        .toList();
  }

  Future<CounterOffer> accept(String offerId) async {
    final response = await _client.dio.post('/counter-offers/$offerId/accept');
    return CounterOffer.fromJson(response.data);
  }

  Future<CounterOffer> decline(String offerId) async {
    final response = await _client.dio.post('/counter-offers/$offerId/decline');
    return CounterOffer.fromJson(response.data);
  }
}
