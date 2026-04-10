import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterState {
  final String? size;
  final String? category;
  final double? shoeSizeEu;
  final double radiusKm;

  const FilterState({
    this.size,
    this.category,
    this.shoeSizeEu,
    this.radiusKm = 50,
  });

  FilterState copyWith({
    String? size,
    String? category,
    double? shoeSizeEu,
    double? radiusKm,
    bool clearSize = false,
    bool clearCategory = false,
    bool clearShoeSizeEu = false,
  }) {
    return FilterState(
      size: clearSize ? null : (size ?? this.size),
      category: clearCategory ? null : (category ?? this.category),
      shoeSizeEu: clearShoeSizeEu ? null : (shoeSizeEu ?? this.shoeSizeEu),
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  bool get hasActiveFilters =>
      size != null || category != null || shoeSizeEu != null || radiusKm != 50;
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState()) {
    _loadPersistedFilters();
  }

  Future<void> _loadPersistedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final persistedSize = prefs.getString('filter_size');
      final normalizedSize = persistedSize == null
          ? null
          : switch (persistedSize.toLowerCase()) {
              'xs' => 'XS',
              's' => 'S',
              'm' => 'M',
              'l' => 'L',
              'xl' => 'XL',
              'xxl' => 'XXL',
              'one_size' => 'ONE_SIZE',
              _ => persistedSize,
            };

      final persistedCategory = prefs.getString('filter_category');
      final normalizedCategory = persistedCategory == null
          ? null
          : switch (persistedCategory.toLowerCase()) {
              'shirt' => 'Shirt',
              'hoodie' => 'Hoodie',
              'pants' => 'Pants',
              'shoes' => 'Shoes',
              'jacket' => 'Jacket',
              'dress' => 'Dress',
              'accessories' => 'Accessories',
              'other' => 'Other',
              _ => persistedCategory,
            };

      state = FilterState(
        size: normalizedSize,
        category: normalizedCategory,
        shoeSizeEu: prefs.getDouble('filter_shoe_size_eu'),
        radiusKm: prefs.getDouble('filter_radius') ?? 50,
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (state.size != null) {
        await prefs.setString('filter_size', state.size!);
      } else {
        await prefs.remove('filter_size');
      }
      if (state.category != null) {
        await prefs.setString('filter_category', state.category!);
      } else {
        await prefs.remove('filter_category');
      }
      if (state.shoeSizeEu != null) {
        await prefs.setDouble('filter_shoe_size_eu', state.shoeSizeEu!);
      } else {
        await prefs.remove('filter_shoe_size_eu');
      }
      await prefs.setDouble('filter_radius', state.radiusKm);
    } catch (_) {}
  }

  void setSize(String? size) {
    state = state.copyWith(size: size, clearSize: size == null);
    _persist();
  }

  void setCategory(String? category) {
    state = state.copyWith(
      category: category,
      clearCategory: category == null,
      clearShoeSizeEu: category != 'Shoes',
    );
    _persist();
  }

  void setShoeSizeEu(double? shoeSizeEu) {
    state = state.copyWith(
      shoeSizeEu: shoeSizeEu,
      clearShoeSizeEu: shoeSizeEu == null,
    );
    _persist();
  }

  void setRadius(double radius) {
    state = state.copyWith(radiusKm: radius);
    _persist();
  }

  void reset() {
    state = const FilterState();
    _persist();
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, FilterState>(
  (_) => FilterNotifier(),
);
