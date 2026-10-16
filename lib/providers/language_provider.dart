import '../core/network/api_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'app_language';

final languageProvider =
    StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_languageKey);
    if (code != null) {
      state = Locale(code);
    }
  }

  Future<void> setLanguage(String code) async {
  state = Locale(code);
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_languageKey, code);

  // Invalidate the network client's cached language so the next
  // API call picks up the new Accept-Language header immediately.
  ApiClient().invalidateLanguageCache();
}
}