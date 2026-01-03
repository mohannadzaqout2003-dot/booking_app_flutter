import 'package:booking_app/core/dio_provider.dart';
import 'package:booking_app/features/services/data/sevice_cache.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/service_api.dart';
import 'data/service_repository.dart';
import 'data/service_models.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final serviceCacheProvider = Provider<ServiceCache>((ref) => ServiceCache());

final serviceApiProvider =
    Provider<ServiceApi>((ref) => ServiceApi(ref.watch(dioProvider)));

final serviceRepoProvider = Provider<ServiceRepository>(
  (ref) => ServiceRepository(
    ref.watch(serviceApiProvider),
    ref.watch(serviceCacheProvider),
  ),
);

final servicesProvider = FutureProvider<List<Service>>((ref) async {
  return ref.watch(serviceRepoProvider).fetchServices();
});

final servicesLastUpdatedProvider = Provider<DateTime?>((ref) {
  return ref.watch(serviceCacheProvider).updatedAt;
});
