import '../../../core/api/api_client.dart';

class DiscoveryRepository {
  final ApiClient _client;

  DiscoveryRepository(this._client);

  static const _validSizes = {
    'XS',
    'S',
    'M',
    'L',
    'XL',
    'XXL',
    'ONE_SIZE',
  };

  static const _validCategories = {
    'shirt': 'Shirt',
    'hoodie': 'Hoodie',
    'pants': 'Pants',
    'shoes': 'Shoes',
    'jacket': 'Jacket',
    'dress': 'Dress',
    'accessories': 'Accessories',
    'other': 'Other',
  };

  String? _normalizeSize(String? size) {
    if (size == null) return null;
    final trimmed = size.trim();
    if (trimmed.isEmpty) return null;

    final normalized = trimmed.toUpperCase().replaceAll(' ', '_');
    return _validSizes.contains(normalized) ? normalized : null;
  }

  String? _normalizeCategory(String? category) {
    if (category == null) return null;
    final key = category.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _validCategories[key];
  }

  Future<FeedResult> getFeed({
    required double latitude,
    required double longitude,
    int page = 1,
    int limit = 20,
    double radiusKm = 50,
    String? size,
    String? category,
    double? shoeSizeEu,
  }) async {
    final safeLatitude = latitude.isFinite ? latitude : 30.0444;
    final safeLongitude = longitude.isFinite ? longitude : 31.2357;
    final safePage = page < 1 ? 1 : page;
    final safeLimit = limit.clamp(1, 50);
    final safeRadius = radiusKm.isFinite && radiusKm >= 1 ? radiusKm : 50.0;

    final normalizedCategory = _normalizeCategory(category);
    final normalizedSize = _normalizeSize(size);
    final normalizedShoeSize =
        normalizedCategory == 'Shoes' && shoeSizeEu != null && shoeSizeEu.isFinite
        ? shoeSizeEu
        : null;

    final response = await _client.dio.get('/discovery/feed', queryParameters: {
      'latitude': safeLatitude,
      'longitude': safeLongitude,
      'page': safePage,
      'limit': safeLimit,
      'radiusKm': safeRadius,
      if (normalizedSize != null) 'size': normalizedSize,
      if (normalizedCategory != null) 'category': normalizedCategory,
      if (normalizedShoeSize != null) 'shoeSizeEu': normalizedShoeSize,
    });
    return FeedResult.fromJson(response.data);
  }

  Future<SwipeResult> swipe({
    required String itemId,
    required String action,
  }) async {
    final response = await _client.dio.post('/discovery/swipe', data: {
      'itemId': itemId,
      'action': action,
    });
    return SwipeResult.fromJson(response.data);
  }
}

class FeedItem {
  final String id;
  final String ownerId;
  final String ownerName;
  final String? ownerPhotoUrl;
  final bool ownerVerified;
  final String category;
  final String brand;
  final String size;
  final double? shoeSizeEu;
  final String condition;
  final bool isVerified;
  final double distanceKm;
  final List<FeedItemPhoto> photos;

  FeedItem({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    this.ownerPhotoUrl,
    required this.ownerVerified,
    required this.category,
    required this.brand,
    required this.size,
    this.shoeSizeEu,
    required this.condition,
    required this.isVerified,
    required this.distanceKm,
    required this.photos,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      id: json['id'],
      ownerId: json['ownerId'],
      ownerName: json['ownerName'],
      ownerPhotoUrl: json['ownerPhotoUrl'],
      ownerVerified: json['ownerVerified'] ?? false,
      category: json['category'],
      brand: json['brand'],
      size: json['size'],
      shoeSizeEu: (json['shoeSizeEu'] as num?)?.toDouble(),
      condition: json['condition'],
      isVerified: json['isVerified'] ?? false,
      distanceKm: (json['distanceKm'] as num).toDouble(),
      photos: (json['photos'] as List)
          .map((p) => FeedItemPhoto.fromJson(p))
          .toList(),
    );
  }
}

class FeedItemPhoto {
  final String url;
  final String? thumbnailUrl;

  FeedItemPhoto({required this.url, this.thumbnailUrl});

  factory FeedItemPhoto.fromJson(Map<String, dynamic> json) {
    return FeedItemPhoto(
      url: json['url'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}

class FeedResult {
  final List<FeedItem> data;
  final int page;
  final int limit;
  final bool hasMore;

  FeedResult({
    required this.data,
    required this.page,
    required this.limit,
    required this.hasMore,
  });

  factory FeedResult.fromJson(Map<String, dynamic> json) {
    return FeedResult(
      data: (json['data'] as List).map((e) => FeedItem.fromJson(e)).toList(),
      page: json['meta']['page'],
      limit: json['meta']['limit'],
      hasMore: json['meta']['hasMore'],
    );
  }
}

class SwipeResult {
  final bool matched;
  final SwipeMatchInfo? match;

  SwipeResult({required this.matched, this.match});

  factory SwipeResult.fromJson(Map<String, dynamic> json) {
    return SwipeResult(
      matched: json['matched'],
      match: json['match'] != null
          ? SwipeMatchInfo.fromJson(json['match'])
          : null,
    );
  }
}

class SwipeMatchInfo {
  final String id;
  final SwipeMatchUser otherUser;
  final SwipeMatchItem myItem;
  final SwipeMatchItem theirItem;

  SwipeMatchInfo({
    required this.id,
    required this.otherUser,
    required this.myItem,
    required this.theirItem,
  });

  factory SwipeMatchInfo.fromJson(Map<String, dynamic> json) {
    return SwipeMatchInfo(
      id: json['id'],
      otherUser: SwipeMatchUser.fromJson(json['otherUser']),
      myItem: SwipeMatchItem.fromJson(json['myItem']),
      theirItem: SwipeMatchItem.fromJson(json['theirItem']),
    );
  }
}

class SwipeMatchUser {
  final String id;
  final String name;
  final String? profilePhotoUrl;

  SwipeMatchUser({required this.id, required this.name, this.profilePhotoUrl});

  factory SwipeMatchUser.fromJson(Map<String, dynamic> json) {
    return SwipeMatchUser(
      id: json['id'],
      name: json['name'],
      profilePhotoUrl: json['profilePhotoUrl'],
    );
  }
}

class SwipeMatchItem {
  final String id;
  final String brand;
  final String? thumbnailUrl;

  SwipeMatchItem({required this.id, required this.brand, this.thumbnailUrl});

  factory SwipeMatchItem.fromJson(Map<String, dynamic> json) {
    return SwipeMatchItem(
      id: json['id'],
      brand: json['brand'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}
