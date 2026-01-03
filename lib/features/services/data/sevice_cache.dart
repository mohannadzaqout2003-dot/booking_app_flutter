class ServiceCache {
  List<Map<String, dynamic>>? _cachedList;
  DateTime? _updatedAt;

  List<Map<String, dynamic>>? get cachedList => _cachedList;
  DateTime? get updatedAt => _updatedAt;

  void save(List<Map<String, dynamic>> list) {
    _cachedList = list;
    _updatedAt = DateTime.now();
  }

  Future<void> clear() async {
    _cachedList = null;
    _updatedAt = null;
  }
}
