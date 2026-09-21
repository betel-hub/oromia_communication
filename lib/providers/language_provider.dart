import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _languageKey = 'app_language';

// Supported locales — note: Flutter's built-in Material widgets don't support 'ti',
// so we fall back to 'en' for MaterialLocalizations on the 'ti' locale
const supportedLanguageCodes = ['en', 'am', 'om', 'ti'];

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
    if (code != null && supportedLanguageCodes.contains(code)) {
      state = Locale(code);
    }
  }

  Future<void> setLanguage(String code) async {
    if (!supportedLanguageCodes.contains(code)) return;
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, code);
  }
}