import '../../../core/api/api_client.dart';

class AdminRepository {
  final ApiClient _client;

  AdminRepository(this._client);

  Future<Map<String, dynamic>> getDashboard() async {
    final response = await _client.dio.get('/admin/dashboard');
    return response.data as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getUsers({
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final response = await _client.dio.get('/admin/users', queryParameters: {
      'page': page,
      'limit': limit,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    });
    final payload = response.data as Map<String, dynamic>;
    final rows = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return rows
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> suspendUser(String userId, {int days = 7}) async {
    await _client.dio.patch('/admin/users/$userId/suspend', data: {
      'days': days,
    });
  }

  Future<void> unsuspendUser(String userId) async {
    await _client.dio.patch('/admin/users/$userId/suspend', data: {
      'clear': true,
    });
  }

  Future<void> updateUserRole(String userId, String role) async {
    await _client.dio.patch('/admin/users/$userId/role', data: {
      'role': role,
    });
  }

  Future<List<Map<String, dynamic>>> getReports({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.dio.get('/admin/reports', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    final payload = response.data as Map<String, dynamic>;
    final rows = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return rows
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> resolveReport(String reportId, String status) async {
    await _client.dio.patch('/admin/reports/$reportId', data: {
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getItems({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.dio.get('/admin/items', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    final payload = response.data as Map<String, dynamic>;
    final rows = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return rows
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> updateItemStatus(String itemId, String status) async {
    await _client.dio.patch('/admin/items/$itemId/status', data: {
      'status': status,
    });
  }

  Future<List<Map<String, dynamic>>> getMatches({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final response = await _client.dio.get('/admin/matches', queryParameters: {
      'page': page,
      'limit': limit,
      if (status != null) 'status': status,
    });
    final payload = response.data as Map<String, dynamic>;
    final rows = payload['data'] as List<dynamic>? ?? <dynamic>[];
    return rows
        .map((e) => Map<String, dynamic>.from(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getNotificationsHealth() async {
    final response = await _client.dio.get('/admin/notifications/health');
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getChatHealth() async {
    final response = await _client.dio.get('/admin/chat/health');
    return response.data as Map<String, dynamic>;
  }
}
