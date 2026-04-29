import 'dart:core' hide Match;

import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';

class MatchingRepository {
  final ApiClient _client;

  MatchingRepository(this._client);

  Future<PaginatedMatches> getMatches({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.dio.get('/matches', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    return PaginatedMatches.fromJson(response.data);
  }

  Future<Match> getMatch(String id) async {
    final response = await _client.dio.get('/matches/$id');
    return Match.fromJson(response.data);
  }

  Future<Match> confirmMatch(String id) async {
    final response = await _client.dio.post('/matches/$id/confirm');
    return Match.fromJson(response.data);
  }

  Future<Match> cancelMatch(String id) async {
    final response = await _client.dio.post('/matches/$id/cancel');
    return Match.fromJson(response.data);
  }

  Future<Match> openChatForItem(
    String itemId, {
    String? initialMessage,
  }) async {
    final response = await _client.dio.post('/matches/open-chat', data: {
      'itemId': itemId,
      if (initialMessage != null && initialMessage.trim().isNotEmpty)
        'initialMessage': initialMessage.trim(),
    });
    return Match.fromJson(response.data);
  }
}

class PaginatedMatches {
  final List<Match> data;
  final int page;
  final int limit;
  final int total;

  PaginatedMatches({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedMatches.fromJson(Map<String, dynamic> json) {
    return PaginatedMatches(
      data: (json['data'] as List).map((e) => Match.fromJson(e)).toList(),
      page: json['meta']['page'],
      limit: json['meta']['limit'],
      total: json['meta']['total'],
    );
  }
}
