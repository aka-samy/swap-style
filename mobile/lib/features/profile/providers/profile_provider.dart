import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_error_mapper.dart';
import '../../../core/models/user.dart';
import '../data/profile_repository.dart';

class ProfileState {
  final User? user;
  final List<WishlistEntry> wishlist;
  final bool isLoading;
  final String? error;

  const ProfileState({
    this.user,
    this.wishlist = const [],
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    User? user,
    List<WishlistEntry>? wishlist,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      user: user ?? this.user,
      wishlist: wishlist ?? this.wishlist,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState());

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repository.getMyProfile();
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load profile',
        ),
      );
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateProfile(data);
      // Preserve existing stats since PATCH response doesn't include them
      final merged = updated.copyWith(stats: state.user?.stats);
      state = state.copyWith(user: merged);
      return true;
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not update profile',
        ),
      );
      return false;
    }
  }

  Future<String?> uploadProfilePhoto(String filePath) async {
    try {
      final result = await _repository.uploadProfilePhoto(filePath);
      return result;
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not upload profile photo',
        ),
      );
      return null;
    }
  }

  Future<void> loadWishlist() async {
    try {
      final wishlist = await _repository.getWishlist();
      state = state.copyWith(wishlist: wishlist);
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load wishlist',
        ),
      );
    }
  }

  Future<bool> addWishlistEntry(Map<String, dynamic> data) async {
    try {
      final entry = await _repository.addWishlistEntry(data);
      state = state.copyWith(wishlist: [...state.wishlist, entry]);
      return true;
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not add wishlist item',
        ),
      );
      return false;
    }
  }

  Future<bool> removeWishlistEntry(String id) async {
    try {
      await _repository.removeWishlistEntry(id);
      state = state.copyWith(
        wishlist: state.wishlist.where((e) => e.id != id).toList(),
      );
      return true;
    } catch (e) {
      debugPrint(ApiErrorMapper.toDebugMessage(e));
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not remove wishlist item',
        ),
      );
      return false;
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(apiClientProvider));
});

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.watch(profileRepositoryProvider));
});
