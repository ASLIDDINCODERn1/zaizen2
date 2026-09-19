import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zaizen/l10n/app_strings.dart' show LanguageScope, AppStrings;
import 'package:zaizen/l10n/supported_languages.dart';


class LocaleProvider extends ChangeNotifier {
  static const _key = 'app_language_code';

  Locale _locale = const Locale('uz');
  AppStrings _strings = AppStrings.uz;
  bool _isLoaded = false;

  Locale get locale => _locale;
  AppStrings get strings => _strings;
  bool get isLoaded => _isLoaded;

  LocaleProvider() {
    LanguageScope.apply('uz');
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    var code = prefs.getString(_key) ?? 'uz';
    if (!isLanguageUnlocked(code)) code = 'uz';
    _apply(code);
    _isLoaded = true;
    notifyListeners();
  }

  void _apply(String languageCode) {
    final code = isLanguageUnlocked(languageCode) ? languageCode : 'uz';
    _locale = Locale(code);
    _strings = AppStrings.fromCode(code);
    LanguageScope.apply(code);
  }

  Future<void> setLocale(String languageCode) async {
    if (!isLanguageUnlocked(languageCode)) return;
    if (_locale.languageCode == languageCode) return;
    _apply(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }
}
