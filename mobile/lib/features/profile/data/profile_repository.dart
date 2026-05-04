import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/item.dart';
import '../../../core/models/user.dart';

class ProfileRepository {
  final ApiClient _client;

  ProfileRepository(this._client);

  Future<User> getMyProfile() async {
    final response = await _client.dio.get('/users/me');
    return User.fromJson(response.data);
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    final response = await _client.dio.patch('/users/me', data: data);
    return User.fromJson(response.data);
  }

  Future<User> getPublicProfile(String userId) async {
    final response = await _client.dio.get('/users/$userId');
    return User.fromJson(response.data);
  }

  Future<List<Item>> getPublicCloset(
    String userId, {
    int page = 1,
    int limit = 40,
  }) async {
    final response = await _client.dio.get(
      '/users/$userId/closet',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    final payload = response.data;
    final rawList = payload is List
        ? payload
        : (payload as Map<String, dynamic>)['data'] as List<dynamic>? ??
            <dynamic>[];

    return rawList
        .whereType<Map<String, dynamic>>()
        .map(Item.fromJson)
        .toList();
  }

  Future<String> uploadProfilePhoto(String filePath) async {
    // 1. Get presigned upload URL
    final file = File(filePath);
    final contentType = filePath.endsWith('.png') ? 'image/png' : 'image/jpeg';
    final presignResponse = await _client.dio.post(
      '/users/me/profile-photo',
      data: {'contentType': contentType},
    );
    final uploadUrl = presignResponse.data['uploadUrl'] as String;
    final publicUrl = presignResponse.data['publicUrl'] as String;

    // 2. Upload file to presigned URL
    final bytes = await file.readAsBytes();
    final isLocalUpload = uploadUrl.contains('192.168.1.50') || uploadUrl.contains('localhost');
    
    if (isLocalUpload) {
      // Local server - use JSON with base64
      final base64Encoded = base64Encode(bytes);
      await Dio().post(
        uploadUrl.replaceAll('/upload-url', '/upload-simple'),
        data: {'imageData': base64Encoded, 'contentType': contentType},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
    } else {
      // R2 presigned URL - use PUT
      await Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      ).put(
        uploadUrl,
        data: bytes,
        options: Options(
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length,
          },
        ),
      );
    }

    // 3. Update profile with new photo URL
    await _client.dio.patch('/users/me', data: {'profilePhotoUrl': publicUrl});
    return publicUrl;
  }

  Future<List<WishlistEntry>> getWishlist() async {
    final response = await _client.dio.get('/users/me/wishlist');
    return (response.data as List)
        .map((e) => WishlistEntry.fromJson(e))
        .toList();
  }

  Future<WishlistEntry> addWishlistEntry(Map<String, dynamic> data) async {
    final response = await _client.dio.post('/users/me/wishlist', data: data);
    return WishlistEntry.fromJson(response.data);
  }

  Future<void> removeWishlistEntry(String id) async {
    await _client.dio.delete('/users/me/wishlist/$id');
  }

  Future<void> reportUser(String userId, String reason, String? details) async {
    await _client.dio.post('/users/$userId/report', data: {
      'targetUserId': userId,
      'reason': reason,
      if (details != null && details.trim().isNotEmpty) 'details': details.trim(),
    });
  }

  Future<void> blockUser(String userId) async {
    await _client.dio.post('/users/$userId/block');
  }

  Future<void> unblockUser(String userId) async {
    await _client.dio.delete('/users/$userId/block');
  }

  Future<List<String>> getBlocks() async {
    final response = await _client.dio.get('/users/blocks');
    final rawList = response.data as List;
    return rawList.map((e) => e['blockedId'].toString()).toList();
  }
}
