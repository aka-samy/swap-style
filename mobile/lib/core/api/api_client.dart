import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    final baseUrl = _resolveBaseUrl(
      const String.fromEnvironment('API_BASE_URL', defaultValue: ''),
    );

    if (kDebugMode) {
      debugPrint('ApiClient baseUrl: $baseUrl');
    }

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
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

  static String _resolveBaseUrl(String configured) {
    final configuredBaseUrl = configured.trim();

    if (configuredBaseUrl.isNotEmpty) {
      final parsed = Uri.tryParse(configuredBaseUrl);
      if (parsed != null && parsed.hasScheme && parsed.host.isNotEmpty) {
        if (parsed.port == 3000 && _isLikelyLocalHost(parsed.host)) {
          // Local backend moved to 3001; auto-correct stale local dart-defines.
          return parsed.replace(port: 3001).toString();
        }
        return configuredBaseUrl;
      }
    }

    return _defaultBaseUrl();
  }

  static String _defaultBaseUrl() {
    if (Platform.isAndroid) {
      return 'http://192.168.1.50:3001/api/v1';
    }

    if (Platform.isIOS) {
      return 'http://192.168.1.50:3001/api/v1';
    }

    return 'http://localhost:3001/api/v1';
  }

  static bool _isLikelyLocalHost(String host) {
    final normalized = host.toLowerCase();
    if (normalized == 'localhost' ||
        normalized == '127.0.0.1' ||
        normalized == '::1' ||
        normalized == '10.0.2.2') {
      return true;
    }

    final match = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$')
        .firstMatch(normalized);
    if (match == null) return false;

    final first = int.tryParse(match.group(1)!);
    final second = int.tryParse(match.group(2)!);
    if (first == null || second == null) return false;

    if (first == 10) return true;
    if (first == 192 && second == 168) return true;
    if (first == 172 && second >= 16 && second <= 31) return true;

    return false;
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
    final existingToken = _client.authToken;
    if (existingToken != null) {
      options.headers['Authorization'] = 'Bearer $existingToken';
    }

    // Auto-refresh token if we have a Firebase user but token might be stale
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && existingToken == null) {
      final token = await user.getIdToken();
      if (token != null) {
        _client.setAuthToken(token);
        options.headers['Authorization'] = 'Bearer $token';
      }
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
