import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_error_mapper.dart';
import '../data/discovery_repository.dart';

class DiscoveryState {
  final List<FeedItem> cards;
  final bool isLoading;
  final bool hasMore;
  final String? error;
  final int currentPage;

  const DiscoveryState({
    this.cards = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 1,
  });

  DiscoveryState copyWith({
    List<FeedItem>? cards,
    bool? isLoading,
    bool? hasMore,
    String? error,
    int? currentPage,
  }) {
    return DiscoveryState(
      cards: cards ?? this.cards,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class DiscoveryNotifier extends StateNotifier<DiscoveryState> {
  final DiscoveryRepository _repository;

  DiscoveryNotifier(this._repository) : super(const DiscoveryState());

  Future<void> loadFeed({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    String? size,
    String? category,
    double? shoeSizeEu,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getFeed(
        latitude: latitude,
        longitude: longitude,
        page: 1,
        radiusKm: radiusKm,
        size: size,
        category: category,
        shoeSizeEu: shoeSizeEu,
      );
      state = state.copyWith(
        cards: result.data,
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: 1,
      );
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load discovery feed',
        ),
      );
    }
  }

  Future<void> loadMore({
    required double latitude,
    required double longitude,
    double radiusKm = 50,
    String? size,
    String? category,
    double? shoeSizeEu,
  }) async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = state.currentPage + 1;
    state = state.copyWith(isLoading: true);
    try {
      final result = await _repository.getFeed(
        latitude: latitude,
        longitude: longitude,
        page: nextPage,
        radiusKm: radiusKm,
        size: size,
        category: category,
        shoeSizeEu: shoeSizeEu,
      );
      state = state.copyWith(
        cards: [...state.cards, ...result.data],
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load more items',
        ),
      );
    }
  }

  Future<SwipeResult?> swipe(String itemId, String action) async {
    try {
      final result = await _repository.swipe(itemId: itemId, action: action);
      // Remove the swiped card from the stack
      state = state.copyWith(
        cards: state.cards.where((c) => c.id != itemId).toList(),
      );
      return result;
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not send your swipe. Please try again.',
        ),
      );
      return null;
    }
  }

  /// Re-insert a card at the front (visual undo only)
  void undoSwipe(FeedItem item) {
    state = state.copyWith(cards: [item, ...state.cards]);
  }
}

final discoveryRepositoryProvider = Provider<DiscoveryRepository>((ref) {
  return DiscoveryRepository(ref.watch(apiClientProvider));
});

final discoveryProvider =
    StateNotifierProvider<DiscoveryNotifier, DiscoveryState>((ref) {
  return DiscoveryNotifier(ref.watch(discoveryRepositoryProvider));
});
