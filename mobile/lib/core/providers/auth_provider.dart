import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import '../api/api_client.dart';
import '../api/api_error_mapper.dart';
import '../services/location_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated }
enum AppUserRole { user, admin }

class AuthState {
  final AuthStatus status;
  final String? userId;
  final String? token;
  final String? displayName;
  final String? error;
  final bool isLoading;
  final AppUserRole role;

  const AuthState({
    this.status = AuthStatus.initial,
    this.userId,
    this.token,
    this.displayName,
    this.error,
    this.isLoading = false,
    this.role = AppUserRole.user,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? userId,
    String? token,
    String? displayName,
    String? error,
    bool clearUserId = false,
    bool clearToken = false,
    bool clearDisplayName = false,
    bool clearError = false,
    bool? isLoading,
    AppUserRole? role,
  }) {
    return AuthState(
      status: status ?? this.status,
      userId: clearUserId ? null : (userId ?? this.userId),
      token: clearToken ? null : (token ?? this.token),
      displayName: clearDisplayName ? null : (displayName ?? this.displayName),
      error: clearError ? null : (error ?? this.error),
      isLoading: isLoading ?? this.isLoading,
      role: role ?? this.role,
    );
  }

  bool get isAdmin => role == AppUserRole.admin;
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final LocationService _locationService;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);

  AuthNotifier(this._apiClient, this._locationService) : super(const AuthState()) {
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await checkAuthStatus();
  }

  AppUserRole _roleFromBackend(dynamic roleValue) {
    final role = (roleValue as String?)?.toUpperCase();
    if (role == 'ADMIN') return AppUserRole.admin;
    return AppUserRole.user;
  }

  String _firebaseSignInMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Account does not exist';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid username or password';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Try again later';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      default:
        return e.message ?? 'Sign in failed. Please try again.';
    }
  }

  String _firebaseRegisterMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak (minimum 6 characters)';
      case 'invalid-email':
        return 'Invalid email address';
      case 'network-request-failed':
        return 'No internet connection. Please check your network and try again.';
      default:
        return e.message ?? 'Registration failed. Please try again.';
    }
  }

  String _authDioMessage(DioException e) {
    final statusCode = e.response?.statusCode;
    if (statusCode == 401 || statusCode == 404) {
      return 'Account does not exist';
    }
    if (statusCode != null && statusCode >= 500) {
      return 'Server error. Please try again in a moment.';
    }
    return ApiErrorMapper.toUserMessage(
      e,
      fallback: 'Could not complete sign in. Please try again.',
    );
  }

  Future<void> _registerBackendUser({
    required User firebaseUser,
    required String idToken,
    String? overrideName,
  }) async {
    final location = await _locationService.getCurrentLocation();
    final displayName =
        overrideName ??
        firebaseUser.displayName ??
        firebaseUser.email?.split('@').first ??
        'SwapStyle User';

    await _apiClient.dio.post('/auth/register', data: {
      'firebaseIdToken': idToken,
      'name': displayName,
      'latitude': location.latitude,
      'longitude': location.longitude,
    });
  }

  Future<bool> _hydrateBackendSession({
    required User firebaseUser,
    required String idToken,
    required bool allowAutoRegister,
    bool allowOfflineFallback = false,
  }) async {
    _apiClient.setAuthToken(idToken);

    try {
      final response = await _apiClient.dio.get('/users/me');
      final data = response.data as Map<String, dynamic>;

      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: data['id'] as String? ?? state.userId,
        token: idToken,
        displayName: (data['displayName'] as String?) ??
            firebaseUser.displayName ??
            firebaseUser.email,
        role: _roleFromBackend(data['role']),
        clearError: true,
      );
      return true;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      if (allowAutoRegister && (statusCode == 401 || statusCode == 404)) {
        try {
          await _registerBackendUser(firebaseUser: firebaseUser, idToken: idToken);
          final response = await _apiClient.dio.get('/users/me');
          final data = response.data as Map<String, dynamic>;
          state = state.copyWith(
            status: AuthStatus.authenticated,
            userId: data['id'] as String? ?? state.userId,
            token: idToken,
            displayName: (data['displayName'] as String?) ??
                firebaseUser.displayName ??
                firebaseUser.email,
            role: _roleFromBackend(data['role']),
            clearError: true,
          );
          return true;
        } on DioException catch (registerError) {
          state = state.copyWith(error: _authDioMessage(registerError));
          return false;
        }
      }

      if (allowOfflineFallback &&
          (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError)) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          token: idToken,
          displayName: firebaseUser.displayName ?? firebaseUser.email,
          clearError: true,
        );
        return true;
      }

      state = state.copyWith(error: _authDioMessage(e));
      return false;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not sync account details. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser != null) {
      try {
        final idToken = await firebaseUser.getIdToken();
        if (idToken != null) {
          final hydrated = await _hydrateBackendSession(
            firebaseUser: firebaseUser,
            idToken: idToken,
            allowAutoRegister: false,
            allowOfflineFallback: true,
          );
          if (hydrated) {
            state = state.copyWith(isLoading: false);
            return;
          }

          final accountMissing = state.error == 'Account does not exist';
          if (accountMissing) {
            await _firebaseAuth.signOut();
            _apiClient.clearAuthToken();
            state = const AuthState(status: AuthStatus.unauthenticated);
            return;
          }
        }
      } catch (e) {
        state = state.copyWith(
          error: ApiErrorMapper.toUserMessage(
            e,
            fallback: 'Could not restore session. Please sign in again.',
          ),
        );
      }
    }
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      clearUserId: true,
      clearToken: true,
      clearDisplayName: true,
      role: AppUserRole.user,
      isLoading: false,
    );
  }

  Future<bool> signIn({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;
      final idToken = await firebaseUser?.getIdToken();
      if (idToken == null) {
        state = state.copyWith(
          error: 'Failed to get authentication token',
          isLoading: false,
        );
        return false;
      }

      final ok = await _hydrateBackendSession(
        firebaseUser: firebaseUser!,
        idToken: idToken,
        allowAutoRegister: false,
      );

      if (!ok) {
        await _firebaseAuth.signOut();
        _apiClient.clearAuthToken();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUserId: true,
          clearToken: true,
          clearDisplayName: true,
          role: AppUserRole.user,
          isLoading: false,
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _firebaseSignInMessage(e), isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Sign in failed. Please try again.',
        ),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);

      final idToken = await credential.user?.getIdToken();
      if (idToken == null) {
        state = state.copyWith(
          error: 'Failed to get authentication token',
          isLoading: false,
        );
        return false;
      }

      final location = await _locationService.getCurrentLocation();

      final response = await _apiClient.dio.post('/auth/register', data: {
        'firebaseIdToken': idToken,
        'name': name,
        'latitude': location.latitude,
        'longitude': location.longitude,
      });
      final data = response.data as Map<String, dynamic>;
      final userId = data['id'] as String? ?? '';

      _apiClient.setAuthToken(idToken);
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: userId,
        token: idToken,
        displayName: name,
        role: AppUserRole.user,
        isLoading: false,
        clearError: true,
      );

      // Best effort: sync role/user data from backend profile.
      await _hydrateBackendSession(
        firebaseUser: credential.user!,
        idToken: idToken,
        allowAutoRegister: false,
      );
      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _firebaseRegisterMessage(e), isLoading: false);
      return false;
    } on DioException catch (e) {
      // Roll back freshly created Firebase account if backend registration fails,
      // otherwise the user can get stuck with an unusable auth state.
      try {
        await _firebaseAuth.currentUser?.delete();
      } catch (_) {
        await _firebaseAuth.signOut();
      }
      _apiClient.clearAuthToken();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUserId: true,
        clearToken: true,
        clearDisplayName: true,
        role: AppUserRole.user,
        error: _authDioMessage(e),
        isLoading: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Registration failed. Please try again.',
        ),
        isLoading: false,
      );
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        state = state.copyWith(
          error: 'Google sign in was cancelled',
          isLoading: false,
        );
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      final idToken = await firebaseUser?.getIdToken();
      if (firebaseUser == null || idToken == null) {
        state = state.copyWith(
          error: 'Google sign in failed. Please try again.',
          isLoading: false,
        );
        return false;
      }

      final ok = await _hydrateBackendSession(
        firebaseUser: firebaseUser,
        idToken: idToken,
        allowAutoRegister: true,
      );
      if (!ok) {
        await _firebaseAuth.signOut();
        _apiClient.clearAuthToken();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          clearUserId: true,
          clearToken: true,
          clearDisplayName: true,
          role: AppUserRole.user,
          isLoading: false,
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(error: _firebaseSignInMessage(e), isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Google sign in failed. Please try again.',
        ),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    await _firebaseAuth.signOut();
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
