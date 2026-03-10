import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';
import '../services/location_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? token;
  final String? displayName;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.token,
    this.displayName,
    this.error,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? token,
    String? displayName,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      token: token ?? this.token,
      displayName: displayName ?? this.displayName,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final LocationService _locationService;

  AuthNotifier(this._apiClient, this._locationService) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    // No persisted session — mark unauthenticated so router shows sign-in
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(error: null);
    try {
      final response = await _apiClient.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken'] as String? ?? '';
      final userId = data['id'] as String? ?? '';
      final name = data['name'] as String? ?? email;
      _apiClient.setAuthToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        token: token,
        displayName: name,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);
    try {
      final location = await _locationService.getCurrentLocation();
      final response = await _apiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
      final data = response.data as Map<String, dynamic>;
      final token = data['accessToken'] as String? ?? '';
      final userId = data['id'] as String? ?? '';
      _apiClient.setAuthToken(token);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        token: token,
        displayName: name,
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    _apiClient.clearAuthToken();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiClientProvider),
    ref.watch(locationServiceProvider),
  );
});
