import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          defaultValue: 'http://192.168.1.153:3000/api/v1',
        ),
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  Dio get dio => _dio;

  String? _authToken;

  /// Current JWT token (needed for Socket.IO auth)
  String? get authToken => _authToken;

  /// Server origin (without /api/v1 path) for Socket.IO connections
  String get serverUrl {
    final base = _dio.options.baseUrl;
    final uri = Uri.parse(base);
    return '${uri.scheme}://${uri.host}:${uri.port}';
  }

  void setAuthToken(String token) {
    _authToken = token;
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _authToken = null;
    _dio.options.headers.remove('Authorization');
  }
}

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Firebase Auth token will be injected here once auth is set up
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Handle token refresh or logout
    }
    handler.next(err);
  }
}
