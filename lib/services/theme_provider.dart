import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_presets.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/theme_presets.dart';

class ThemeProvider extends ChangeNotifier {
  static const _modeKey = 'theme_mode';
  static const _presetKey = 'theme_preset';
  static const _autoKey = 'auto_dark';

  ThemeMode _themeMode = ThemeMode.light;
  int _presetIndex = 0;
  bool _autoDark = false;
  Timer? _autoTimer;

  ThemeMode get themeMode => _themeMode;
  int get presetIndex => _presetIndex;
  ThemePreset get preset => themePresets[_presetIndex];
  bool get autoDark => _autoDark;

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
    _autoDark = prefs.getBool(_autoKey) ?? false;
    if (_presetIndex < 0 || _presetIndex >= themePresets.length) _presetIndex = 0;
    if (_autoDark) _scheduleAutoDark();
    notifyListeners();
  }

  void _scheduleAutoDark() {
    _autoTimer?.cancel();
    final now = DateTime.now();
    // Simple schedule: dark mode 8PM-7AM, light mode 7AM-8PM
    final currentHour = now.hour;
    final shouldBeDark = currentHour < 7 || currentHour >= 20;
    if (shouldBeDark != isDark) {
      _themeMode = shouldBeDark ? ThemeMode.dark : ThemeMode.light;
    }
    // Re-check every 10 minutes
    _autoTimer = Timer(const Duration(minutes: 10), _scheduleAutoDark);
  }

  Future<void> setAutoDark(bool enabled) async {
    _autoDark = enabled;
    if (enabled) {
      _scheduleAutoDark();
    } else {
      _autoTimer?.cancel();
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoKey, enabled);
  }

  Future<void> toggle() async {
    if (_autoDark) {
      _autoDark = false;
      _autoTimer?.cancel();
    }
    _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, isDark ? 'dark' : 'light');
    await prefs.setBool(_autoKey, false);
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

  @override
  void dispose() {
    _autoTimer?.cancel();
    super.dispose();
  }
}
