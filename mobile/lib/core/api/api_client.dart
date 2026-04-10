import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://swap-style-production.up.railway.app/api/v1',
        ),
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor(this));
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;

  String? _authToken;

  String? get authToken => _authToken;

  String get serverUrl {
    final base = _dio.options.baseUrl;
    final uri = Uri.parse(base);
    return '${uri.scheme}://${uri.host}${uri.port != 80 && uri.port != 443 ? ':${uri.port}' : ''}';
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }

  /// Refresh the Firebase ID token and update the header
  Future<String?> refreshToken() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      final newToken = await user.getIdToken(true);
      if (newToken != null) setAuthToken(newToken);
      return newToken;
    } catch (_) {
      return null;
    }
  }
}

class AuthInterceptor extends Interceptor {
  final ApiClient _client;
  AuthInterceptor(this._client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Auto-refresh token if we have a Firebase user but token might be stale
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _client.authToken == null) {
      final token = await user.getIdToken();
      if (token != null) _client.setAuthToken(token);
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Try refreshing the token once
      final newToken = await _client.refreshToken();
      if (newToken != null) {
        // Retry the original request with the new token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        try {
          final response = await _client.dio.fetch(opts);
          return handler.resolve(response);
        } catch (retryError) {
          // If retry also fails, pass through
        }
      }
    }
    handler.next(err);
  }
}
