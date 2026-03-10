import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilterState {
  final String? size;
  final String? category;
  final double radiusKm;

  const FilterState({
    this.size,
    this.category,
    this.radiusKm = 50,
  });

  FilterState copyWith({
    String? size,
    String? category,
    double? radiusKm,
    bool clearSize = false,
    bool clearCategory = false,
  }) {
    return FilterState(
      size: clearSize ? null : (size ?? this.size),
      category: clearCategory ? null : (category ?? this.category),
      radiusKm: radiusKm ?? this.radiusKm,
    );
  }

  bool get hasActiveFilters =>
      size != null || category != null || radiusKm != 50;
}

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState()) {
    _loadPersistedFilters();
  }

  Future<void> _loadPersistedFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      state = FilterState(
        size: prefs.getString('filter_size'),
        category: prefs.getString('filter_category'),
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
      await prefs.setDouble('filter_radius', state.radiusKm);
    } catch (_) {}
  }

  void setSize(String? size) {
    state = state.copyWith(size: size, clearSize: size == null);
    _persist();
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category, clearCategory: category == null);
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
