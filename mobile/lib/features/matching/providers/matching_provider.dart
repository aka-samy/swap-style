import 'dart:core' hide Match;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/match.dart';
import '../data/matching_repository.dart';

class MatchingState {
  final List<Match> matches;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalMatches;

  const MatchingState({
    this.matches = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalMatches = 0,
  });

  MatchingState copyWith({
    List<Match>? matches,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalMatches,
  }) {
    return MatchingState(
      matches: matches ?? this.matches,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalMatches: totalMatches ?? this.totalMatches,
    );
  }
}

class MatchingNotifier extends StateNotifier<MatchingState> {
  final MatchingRepository _repository;

  MatchingNotifier(this._repository) : super(const MatchingState());

  Future<void> loadMatches({int page = 1, String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getMatches(page: page, status: status);
      state = state.copyWith(
        matches: page == 1 ? result.data : [...state.matches, ...result.data],
        isLoading: false,
        currentPage: result.page,
        totalMatches: result.total,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> confirmMatch(String matchId) async {
    try {
      final updated = await _repository.confirmMatch(matchId);
      state = state.copyWith(
        matches: state.matches.map((m) => m.id == matchId ? updated : m).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> cancelMatch(String matchId) async {
    try {
      final updated = await _repository.cancelMatch(matchId);
      state = state.copyWith(
        matches: state.matches.map((m) => m.id == matchId ? updated : m).toList(),
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final matchingRepositoryProvider = Provider<MatchingRepository>((ref) {
  return MatchingRepository(ref.watch(apiClientProvider));
});

final matchingProvider =
    StateNotifierProvider<MatchingNotifier, MatchingState>((ref) {
  return MatchingNotifier(ref.watch(matchingRepositoryProvider));
});
