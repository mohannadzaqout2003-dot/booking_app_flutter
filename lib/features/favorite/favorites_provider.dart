import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
  FavoritesController.new,
);

class FavoritesController extends AsyncNotifier<Set<String>> {
  static const _key = 'favorite_service_ids';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? <String>[];
    return list.toSet();
  }

  Future<void> toggle(String serviceId) async {
    final prefs = await SharedPreferences.getInstance();
    final current = Set<String>.from(state.value ?? <String>{});

    if (current.contains(serviceId)) {
      current.remove(serviceId);
    } else {
      current.add(serviceId);
    }

    state = AsyncData(current);
    await prefs.setStringList(_key, current.toList());
  }

  bool isFav(String serviceId) {
    final current = state.value ?? <String>{};
    return current.contains(serviceId);
  }
}
