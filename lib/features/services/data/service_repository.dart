import 'package:booking_app/features/services/data/sevice_cache.dart';

import 'service_api.dart';
import 'service_models.dart';

class ServiceRepository {
  ServiceRepository(this._api, this._cache);

  final ServiceApi _api;
  final ServiceCache _cache;

  Future<List<Service>> fetchServices({bool forceRefresh = false}) async {
    // ✅ رجّع من الكاش إذا موجود ومش عامل فورس
    final cached = _cache.cachedList;
    if (!forceRefresh && cached != null) {
      return cached.map((e) => Service.fromJson(e)).toList();
    }

    // ✅ حمّل من API
    final list = await _api.getServicesList();

    // ✅ تأكد النوع Map
    final mapped = list
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList();

    // ✅ خزّن بالكاش
    _cache.save(mapped);

    return mapped.map(Service.fromJson).toList();
  }

  Future<DateTime?> cacheUpdatedAt() async => _cache.updatedAt;

  Future<void> clearCache() async => _cache.clear();
}
