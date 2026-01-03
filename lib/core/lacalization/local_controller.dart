import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('en'));

  Future<void> setLang(String code) async {
    final c = code.toLowerCase();
    state = Locale(c == 'ar' ? 'ar' : 'en');
  }

  void toggle() {
    state = state.languageCode == 'ar' ? const Locale('en') : const Locale('ar');
  }
}

final localeControllerProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});
