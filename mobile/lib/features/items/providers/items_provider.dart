import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../../core/api/api_error_mapper.dart';
import '../../../core/models/item.dart';
import '../data/items_repository.dart';

class ItemsState {
  final List<Item> items;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final int totalItems;

  const ItemsState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.totalItems = 0,
  });

  ItemsState copyWith({
    List<Item>? items,
    bool? isLoading,
    String? error,
    int? currentPage,
    int? totalItems,
  }) {
    return ItemsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentPage: currentPage ?? this.currentPage,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}

class ItemsNotifier extends StateNotifier<ItemsState> {
  final ItemsRepository _repository;

  ItemsNotifier(this._repository) : super(const ItemsState());

  Future<void> loadMyItems({int page = 1}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final result = await _repository.getMyItems(page: page);
      state = state.copyWith(
        items: page == 1 ? result.data : [...state.items, ...result.data],
        isLoading: false,
        currentPage: result.page,
        totalItems: result.total,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not load closet. Please try again.',
        ),
      );
    }
  }

  Future<Item?> createItem({
    required String category,
    required String brand,
    required String size,
    double? shoeSizeEu,
    required String condition,
    String? notes,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final item = await _repository.createItem(
        category: category,
        brand: brand,
        size: size,
        shoeSizeEu: shoeSizeEu,
        condition: condition,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
      );
      state = state.copyWith(
        items: [item, ...state.items],
        totalItems: state.totalItems + 1,
      );
      return item;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not create item. Please try again.',
        ),
      );
      return null;
    }
  }

  Future<bool> updateItem(String id, Map<String, dynamic> data) async {
    try {
      final updated = await _repository.updateItem(id, data);
      final items = state.items.map((i) => i.id == id ? updated : i).toList();
      state = state.copyWith(items: items);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not update item. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
      state = state.copyWith(
        items: state.items.where((i) => i.id != id).toList(),
        totalItems: state.totalItems > 0 ? state.totalItems - 1 : 0,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not delete item. Please try again.',
        ),
      );
      return false;
    }
  }

  /// Upload a photo for an item using presigned URL flow
  Future<bool> uploadPhoto(String itemId, File file) async {
    try {
      final contentType = _mimeType(file.path);
      final urlInfo = await _repository.getUploadUrl(itemId, contentType);
      final bytes = await file.readAsBytes();
      await _repository.uploadPhoto(urlInfo.uploadUrl, bytes, contentType);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Photo upload failed. Please try again.',
        ),
      );
      return false;
    }
  }

  Future<bool> deletePhoto(String itemId, String photoId) async {
    try {
      await _repository.deletePhoto(itemId, photoId);
      final updatedItems = state.items.map((item) {
        if (item.id == itemId) {
          final updatedPhotos = item.photos.where((p) => p.id != photoId).toList();
          return item.copyWith(photos: updatedPhotos);
        }
        return item;
      }).toList();
      state = state.copyWith(items: updatedItems);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: ApiErrorMapper.toUserMessage(
          e,
          fallback: 'Could not delete photo. Please try again.',
        ),
      );
      return false;
    }
  }

  String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

final itemsRepositoryProvider = Provider<ItemsRepository>((ref) {
  return ItemsRepository(ref.watch(apiClientProvider));
});

final itemsProvider =
    StateNotifierProvider<ItemsNotifier, ItemsState>((ref) {
  return ItemsNotifier(ref.watch(itemsRepositoryProvider));
});
