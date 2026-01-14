import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  String _currencySymbol = '\$';
  String _currencyCode = 'USD';

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;

  PreferencesProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _currencySymbol = prefs.getString('currencySymbol') ?? '\$';
      _currencyCode = prefs.getString('currencyCode') ?? 'USD';
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading preferences: $e");
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    notifyListeners();
  }

  Future<void> setCurrency(String symbol, String code) async {
    _currencySymbol = symbol;
    _currencyCode = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currencySymbol', symbol);
    await prefs.setString('currencyCode', code);
    notifyListeners();
  }
}
