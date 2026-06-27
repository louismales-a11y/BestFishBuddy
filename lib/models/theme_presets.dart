import 'package:flutter/material.dart';

/// A named color preset for the app theme.
class ThemePreset {
  final String name;
  final IconData icon;
  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color secondaryDark;
  final Color tertiary;
  final Color tertiaryDark;
  final Color cardDark;
  final Color navDark;
  final Color inputDark;

  const ThemePreset({
    required this.name,
    required this.icon,
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.secondaryDark,
    required this.tertiary,
    required this.tertiaryDark,
    this.cardDark = const Color(0xFF0E1422),
    this.navDark = const Color(0xFF0A0E1A),
    this.inputDark = const Color(0xFF161C2E),
  });
}

/// All available theme presets.
const List<ThemePreset> themePresets = [
  // ── 1. Cyberpunk (current) ─────────────────────────────────────────────────
  ThemePreset(
    name: 'Cyberpunk',
    icon: Icons.flash_on,
    primary: Color(0xFF00E5FF),
    primaryDark: Color(0xFF00B0FF),
    secondary: Color(0xFFE040FB),
    secondaryDark: Color(0xFFCC00FF),
    tertiary: Color(0xFF76FF03),
    tertiaryDark: Color(0xFF64DD17),
  ),

  // ── 2. Ocean Deep ──────────────────────────────────────────────────────────
  ThemePreset(
    name: 'Ocean Deep',
    icon: Icons.water_drop,
    primary: Color(0xFF00BCD4),
    primaryDark: Color(0xFF0097A7),
    secondary: Color(0xFF1E88E5),
    secondaryDark: Color(0xFF1565C0),
    tertiary: Color(0xFF26C6DA),
    tertiaryDark: Color(0xFF00ACC1),
    cardDark: Color(0xFF0D1B2A),
    navDark: Color(0xFF07131F),
    inputDark: Color(0xFF122A38),
  ),

  // ── 3. Sunset ──────────────────────────────────────────────────────────────
  ThemePreset(
    name: 'Sunset',
    icon: Icons.wb_sunny,
    primary: Color(0xFFFF6F00),
    primaryDark: Color(0xFFE65100),
    secondary: Color(0xFFE91E63),
    secondaryDark: Color(0xFFC2185B),
    tertiary: Color(0xFFFFD600),
    tertiaryDark: Color(0xFFFFC107),
    cardDark: Color(0xFF1E1422),
    navDark: Color(0xFF140E1A),
    inputDark: Color(0xFF2A1A30),
  ),

  // ── 4. Forest ──────────────────────────────────────────────────────────────
  ThemePreset(
    name: 'Forest',
    icon: Icons.forest,
    primary: Color(0xFF4CAF50),
    primaryDark: Color(0xFF388E3C),
    secondary: Color(0xFF8BC34A),
    secondaryDark: Color(0xFF689F38),
    tertiary: Color(0xFF795548),
    tertiaryDark: Color(0xFF5D4037),
    cardDark: Color(0xFF0D1F14),
    navDark: Color(0xFF08140E),
    inputDark: Color(0xFF142818),
  ),

  // ── 5. Midnight ────────────────────────────────────────────────────────────
  ThemePreset(
    name: 'Midnight',
    icon: Icons.nightlight_round,
    primary: Color(0xFF7C4DFF),
    primaryDark: Color(0xFF651FFF),
    secondary: Color(0xFF448AFF),
    secondaryDark: Color(0xFF2979FF),
    tertiary: Color(0xFF00E5FF),
    tertiaryDark: Color(0xFF00B8D4),
    cardDark: Color(0xFF12102A),
    navDark: Color(0xFF0A0A1A),
    inputDark: Color(0xFF1A1840),
  ),
];
