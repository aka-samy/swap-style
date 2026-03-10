import '../../../core/api/api_client.dart';
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
