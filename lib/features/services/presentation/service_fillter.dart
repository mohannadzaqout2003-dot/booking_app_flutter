import 'package:flutter_riverpod/legacy.dart';

enum ServiceSort {
  recommended,
  priceLowToHigh,
  priceHighToLow,
  ratingHighToLow,
}

class ServicesFilterState {
  final String query;
  final String category; 
  final num minPrice;
  final num maxPrice;
  final ServiceSort sort;

  const ServicesFilterState({
    this.query = '',
    this.category = 'All',
    this.minPrice = 0,
    this.maxPrice = 100000,
    this.sort = ServiceSort.recommended,
  });

  ServicesFilterState copyWith({
    String? query,
    String? category,
    num? minPrice,
    num? maxPrice,
    ServiceSort? sort,
  }) {
    return ServicesFilterState(
      query: query ?? this.query,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sort: sort ?? this.sort,
    );
  }
}

class ServicesFilterController extends StateNotifier<ServicesFilterState> {
  ServicesFilterController() : super(const ServicesFilterState());

  void setQuery(String q) => state = state.copyWith(query: q);
  void setCategory(String c) => state = state.copyWith(category: c);

  void setPriceRange(double min, double max) {
    final fixedMin = min < 0 ? 0 : min;
    final fixedMax = max < fixedMin ? fixedMin : max;
    state = state.copyWith(minPrice: fixedMin, maxPrice: fixedMax);
  }

  void setSort(ServiceSort s) => state = state.copyWith(sort: s);

  void reset() => state = const ServicesFilterState();
}

final servicesFilterProvider =
    StateNotifierProvider<ServicesFilterController, ServicesFilterState>(
  (ref) => ServicesFilterController(),
);
