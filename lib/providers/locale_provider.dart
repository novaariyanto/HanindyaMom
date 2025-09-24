import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale_code';

  Locale? _locale; // null => ikuti sistem

  Locale? get locale => _locale;

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefKey);
    if (code == null || code.isEmpty) {
      _locale = null;
    } else {
      if (code == 'en') {
        _locale = const Locale('en', 'US');
      } else {
        _locale = const Locale('id', 'ID');
      }
    }
    notifyListeners();
  }

  Future<void> setLocale(String languageCode) async {
    if (languageCode == 'en') {
      _locale = const Locale('en', 'US');
    } else {
      _locale = const Locale('id', 'ID');
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, languageCode);
    notifyListeners();
  }
}


