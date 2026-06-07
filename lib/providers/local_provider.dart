import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProvider with ChangeNotifier {
  static const String _localeKey = 'ui_language';
  Locale _locale = const Locale('es');

  LocalProvider() {
    _loadLocale();
  }

  Locale get locale => _locale;

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString(_localeKey);
      if (lang != null) {
        _locale = Locale(lang);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error loading locale: $e");
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      debugPrint("Error saving locale: $e");
    }
  }
}
