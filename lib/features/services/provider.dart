import 'package:booking_app/core/dio_provider.dart';
import 'package:booking_app/features/services/data/sevice_cache.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/service_api.dart';
import 'data/service_repository.dart';
import 'data/service_models.dart';

// ✅ Dio من core
final dioProvider = Provider<Dio>((ref) => createDio());

// ✅ Cache مستقل (ما يعتمد على repo نهائياً)
final serviceCacheProvider = Provider<ServiceCache>((ref) => ServiceCache());

// ✅ API
final serviceApiProvider =
    Provider<ServiceApi>((ref) => ServiceApi(ref.watch(dioProvider)));

// ✅ Repo يعتمد على api + cache (هيك بنكسر الـ circularity)
final serviceRepoProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(
    ref.watch(serviceApiProvider),
    ref.watch(serviceCacheProvider),
  ),
);

// ✅ Services
final servicesProvider = FutureProvider<List<Service>>((ref) async {
  return ref.watch(serviceRepoProvider).fetchServices();
});

// ✅ Last updated
final servicesLastUpdatedProvider = Provider<DateTime?>((ref) {
  // (مش Async) لأن الكاش in-memory
  return ref.watch(serviceCacheProvider).updatedAt;
});
