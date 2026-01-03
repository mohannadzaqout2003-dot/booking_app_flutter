import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsProvider =
    AsyncNotifierProvider<AppSettingsController, AppSettingsState>(
      AppSettingsController.new,
    );

class AppSettingsState {
  final bool notificationsEnabled;

  const AppSettingsState({required this.notificationsEnabled});

  AppSettingsState copyWith({bool? notificationsEnabled}) {
    return AppSettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}

class AppSettingsController extends AsyncNotifier<AppSettingsState> {
  static const _kNotifications = 'settings_notifications_enabled';

  @override
  Future<AppSettingsState> build() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_kNotifications) ?? true;
    return AppSettingsState(notificationsEnabled: enabled);
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, value);
    state = AsyncData(state.value!.copyWith(notificationsEnabled: value));
  }
}
