import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_presets.dart';

class ThemeProvider extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _presetKey = 'theme_preset';

  ThemeMode _themeMode = ThemeMode.light;
  int _presetIndex = 0;

  ThemeMode get themeMode => _themeMode;
  int get presetIndex => _presetIndex;
  ThemePreset get preset => themePresets[_presetIndex];

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final mode = prefs.getString(_modeKey) ?? 'light';
    _themeMode = mode == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _presetIndex = prefs.getInt(_presetKey) ?? 0;
    if (_presetIndex < 0 || _presetIndex >= themePresets.length) {
      _presetIndex = 0;
    }
    notifyListeners();
  }

  Future<void> toggle() async {
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, isDark ? 'dark' : 'light');
  }

  Future<void> setDark(bool dark) async {
    _themeMode = dark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, dark ? 'dark' : 'light');
  }

  Future<void> setPreset(int index) async {
    if (index < 0 || index >= themePresets.length) return;
    _presetIndex = index;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_presetKey, index);
  }
}
