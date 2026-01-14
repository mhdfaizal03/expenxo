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

  bool _generalNotifications = true;
  bool _transactionAlerts = true;
  bool _budgetReminders = false;
  bool _isPremium = false;

  bool get generalNotifications => _generalNotifications;
  bool get transactionAlerts => _transactionAlerts;
  bool get budgetReminders => _budgetReminders;
  bool get isPremium => _isPremium;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('isDark') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      _currencySymbol = prefs.getString('currencySymbol') ?? '\$';
      _currencyCode = prefs.getString('currencyCode') ?? 'USD';

      _generalNotifications = prefs.getBool('generalNotifications') ?? true;
      _transactionAlerts = prefs.getBool('transactionAlerts') ?? true;
      _budgetReminders = prefs.getBool('budgetReminders') ?? false;
      _isPremium = prefs.getBool('isPremium') ?? false;

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

  Future<void> setGeneralNotifications(bool value) async {
    _generalNotifications = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('generalNotifications', value);
    notifyListeners();
  }

  Future<void> setTransactionAlerts(bool value) async {
    _transactionAlerts = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('transactionAlerts', value);
    notifyListeners();
  }

  Future<void> setBudgetReminders(bool value) async {
    _budgetReminders = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('budgetReminders', value);
    notifyListeners();
  }

  Future<void> setPremiumStatus(bool value) async {
    _isPremium = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', value);
    notifyListeners();
  }
}
