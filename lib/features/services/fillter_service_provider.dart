import 'package:booking_app/features/services/presentation/service_fillter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/service_models.dart';
import 'provider.dart';

String _norm(String s) => s.trim().toLowerCase();

final filteredServicesProvider = Provider<List<Service>>((ref) {
  final async = ref.watch(servicesProvider);
  final filter = ref.watch(servicesFilterProvider);

  final services = async.value ?? const <Service>[];

  final q = _norm(filter.query);
  final cat = _norm(filter.category);

  // 1) Filter
  final result = services.where((s) {
    final matchesCategory = (cat == 'all') ? true : _norm(s.category) == cat;

    final price = s.price;
    final matchesPrice = price >= filter.minPrice && price <= filter.maxPrice;

    if (q.isEmpty) {
      return matchesCategory && matchesPrice;
    }

    final hay = _norm('${s.title} ${s.description} ${s.category}');
    final matchesQuery = hay.contains(q);

    return matchesCategory && matchesPrice && matchesQuery;
  }).toList();

  // 2) Sort
  switch (filter.sort) {
    case ServiceSort.recommended:
      break;
    case ServiceSort.priceLowToHigh:
      result.sort((a, b) => a.price.compareTo(b.price));
      break;
    case ServiceSort.priceHighToLow:
      result.sort((a, b) => b.price.compareTo(a.price));
      break;
    case ServiceSort.ratingHighToLow:
      result.sort((a, b) => b.rating.compareTo(a.rating));
      break;
  }

  return result;
});

final serviceCategoriesProvider = Provider<List<String>>((ref) {
  final async = ref.watch(servicesProvider);
  final services = async.value ?? const <Service>[];

  final set = <String>{};
  for (final s in services) {
    final c = s.category.trim();
    if (c.isNotEmpty) set.add(c);
  }

  final cats = set.toList()..sort();
  return ['All', ...cats];
});

final servicesPriceBoundsProvider = Provider<({double min, double max})>((ref) {
  final async = ref.watch(servicesProvider);
  final services = async.value ?? const <Service>[];

  if (services.isEmpty) return (min: 0, max: 100);

  double minP = services.first.price;
  double maxP = services.first.price;

  for (final s in services) {
    if (s.price < minP) minP = s.price;
    if (s.price > maxP) maxP = s.price;
  }

  if (minP == maxP) maxP = minP + 1;

  return (min: minP, max: maxP);
});
