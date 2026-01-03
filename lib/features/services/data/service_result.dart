import 'service_models.dart';

class ServicesResult {
  ServicesResult({
    required this.items,
    required this.fromCache,
    required this.lastUpdated,
  });

  final List<Service> items;
  final bool fromCache;
  final DateTime? lastUpdated;
}
