import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _transactionsKey = 'cached_transactions';
  static const String _budgetsKey = 'cached_budgets';
  static const String _categoriesKey = 'cached_categories';
  static const String _notificationsKey = 'cached_notifications';

  Future<void> cacheTransactions(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(data);
    await prefs.setString(_transactionsKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> getCachedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_transactionsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> cacheBudgets(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(data);
    await prefs.setString(_budgetsKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> getCachedBudgets() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_budgetsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> cacheCategories(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(data);
    await prefs.setString(_categoriesKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> getCachedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_categoriesKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> cacheNotifications(List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(data);
    await prefs.setString(_notificationsKey, encodedData);
  }

  Future<List<Map<String, dynamic>>> getCachedNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString(_notificationsKey);
    if (encodedData == null) return [];
    final List<dynamic> decodedData = jsonDecode(encodedData);
    return decodedData.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_budgetsKey);
    await prefs.remove(_categoriesKey);
    await prefs.remove(_notificationsKey);
  }
}
