import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Stores admin-edited price overrides locally.
/// Keys are item names, values are overridden prices.
class AdminPriceService {
  static const _key = 'admin_price_overrides';
  static AdminPriceService? _instance;
  static AdminPriceService get instance => _instance ??= AdminPriceService._();
  AdminPriceService._();

  Map<String, double> _overrides = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      _overrides = decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
    }
  }

  double getPrice(String itemName, double defaultPrice) {
    return _overrides[itemName] ?? defaultPrice;
  }

  Future<void> setPrice(String itemName, double price) async {
    _overrides[itemName] = price;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_overrides));
  }

  Map<String, double> get overrides => Map.unmodifiable(_overrides);
}