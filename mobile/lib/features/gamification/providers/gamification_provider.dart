import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/gamification.dart';

// ─── Repository ─────────────────────────────────────────

class GamificationRepository {
  GamificationRepository(this._client);
  final ApiClient _client;

  Future<GamificationStats> getMyStats() async {
    final resp = await _client.dio.get('/gamification/stats');
    return GamificationStats.fromJson(resp.data as Map<String, dynamic>);
  }

  Future<List<Badge>> getBadgeCatalog() async {
    final resp = await _client.dio.get('/gamification/badges');
    return (resp.data as List)
        .map((e) => Badge.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

// ─── Providers ──────────────────────────────────────────

final gamificationRepositoryProvider =
    Provider<GamificationRepository>((ref) {
  return GamificationRepository(ref.watch(apiClientProvider));
});

final gamificationStatsProvider =
    FutureProvider.autoDispose<GamificationStats>((ref) async {
  return ref.watch(gamificationRepositoryProvider).getMyStats();
});

final badgeCatalogProvider =
    FutureProvider.autoDispose<List<Badge>>((ref) async {
  return ref.watch(gamificationRepositoryProvider).getBadgeCatalog();
});
