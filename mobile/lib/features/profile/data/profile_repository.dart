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
    await Dio().put(
      uploadUrl,
      data: bytes,
      options: Options(
        headers: {
          'Content-Type': contentType,
          'Content-Length': bytes.length,
        },
      ),
    );

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
}
