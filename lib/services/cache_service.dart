import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple cache service for weather and other API data.
/// Allows the app to show last-known data when offline.
class CacheService {
  static final CacheService instance = CacheService._();
  CacheService._();

  Future<void> put(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cache_$key', json.encode({'data': value, 'ts': DateTime.now().toIso8601String()}));
  }

  Future<T?> get<T>(String key, {Duration maxAge = const Duration(hours: 1)}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cache_$key');
    if (raw == null) return null;
    try {
      final decoded = json.decode(raw) as Map;
      final ts = DateTime.parse(decoded['ts'] as String);
      if (DateTime.now().difference(ts) > maxAge) return null;
      return decoded['data'] as T;
    } catch (_) {
      return null;
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('cache_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
