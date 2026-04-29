import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';
import '../../../core/models/item.dart';

class ItemsRepository {
  final ApiClient _client;

  ItemsRepository(this._client);

  Future<Item> createItem({
    required String category,
    required String brand,
    required String size,
    double? shoeSizeEu,
    required String condition,
    String? notes,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.dio.post('/items', data: {
      'category': category,
      'brand': brand,
      'size': size,
      if (shoeSizeEu != null) 'shoeSizeEu': shoeSizeEu,
      'condition': condition,
      if (notes != null) 'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    });
    return Item.fromJson(response.data);
  }

  Future<PaginatedItems> getMyItems({int page = 1, int limit = 20}) async {
    final response = await _client.dio.get('/items/me', queryParameters: {
      'page': page,
      'limit': limit,
    });
    return PaginatedItems.fromJson(response.data);
  }

  Future<Item> getItem(String id) async {
    final response = await _client.dio.get('/items/$id');
    return Item.fromJson(response.data);
  }

  Future<Item> updateItem(String id, Map<String, dynamic> data) async {
    final response = await _client.dio.patch('/items/$id', data: data);
    return Item.fromJson(response.data);
  }

  Future<void> deleteItem(String id) async {
    await _client.dio.delete('/items/$id');
  }

  Future<ItemStats> getItemStats(String id) async {
    final response = await _client.dio.get('/items/$id/stats');
    return ItemStats.fromJson(response.data as Map<String, dynamic>);
  }

  Future<PresignedUploadUrl> getUploadUrl(String itemId, String contentType) async {
    final response = await _client.dio.post('/items/$itemId/photos/upload-url', data: {
      'contentType': contentType,
    });
    return PresignedUploadUrl.fromJson(response.data);
  }

  Future<void> uploadPhoto(String uploadUrl, List<int> bytes, String contentType) async {
    await Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    ).put(
      uploadUrl,
      data: bytes,
      options: Options(headers: {'Content-Type': contentType}),
    );
  }

  Future<void> deletePhoto(String itemId, String photoId) async {
    await _client.dio.delete('/items/$itemId/photos/$photoId');
  }
}

class PaginatedItems {
  final List<Item> data;
  final int page;
  final int limit;
  final int total;

  PaginatedItems({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  factory PaginatedItems.fromJson(Map<String, dynamic> json) {
    return PaginatedItems(
      data: (json['data'] as List).map((e) => Item.fromJson(e)).toList(),
      page: json['meta']['page'],
      limit: json['meta']['limit'],
      total: json['meta']['total'],
    );
  }
}

class PresignedUploadUrl {
  final String uploadUrl;
  final String publicUrl;
  final String key;

  PresignedUploadUrl({
    required this.uploadUrl,
    required this.publicUrl,
    required this.key,
  });

  factory PresignedUploadUrl.fromJson(Map<String, dynamic> json) {
    return PresignedUploadUrl(
      uploadUrl: json['uploadUrl'],
      publicUrl: json['publicUrl'],
      key: json['key'],
    );
  }
}

class ItemStats {
  final String itemId;
  final int likesCount;
  final int totalMatches;
  final int activeMatches;

  ItemStats({
    required this.itemId,
    required this.likesCount,
    required this.totalMatches,
    required this.activeMatches,
  });

  factory ItemStats.fromJson(Map<String, dynamic> json) {
    return ItemStats(
      itemId: json['itemId'] as String,
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      totalMatches: (json['totalMatches'] as num?)?.toInt() ?? 0,
      activeMatches: (json['activeMatches'] as num?)?.toInt() ?? 0,
    );
  }
}
