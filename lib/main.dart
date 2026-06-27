import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_native_badge/flutter_native_badge.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/add_catch_screen.dart';
import 'screens/catches_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/map_screen.dart';
import 'screens/how_to_use_screen.dart';
import 'screens/about_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/encyclopedia_screen.dart';
import 'screens/login_screen.dart';
import 'screens/cloud_sync_screen.dart';
import 'screens/gallery_screen.dart';
import 'services/database_service.dart';
import 'services/firebase_sync.dart';
import 'services/theme_provider.dart';
import 'models/theme_presets.dart';
import 'widgets/water_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseSyncService.instance.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const BestCatchBuddyApp(),
    ),
  );
}

class AppColors {
  AppColors._();
  static Color error = const Color(0xFFFF1744);
  static Color surface = const Color(0xFFF0F4FF);
  static Color darkSurface = const Color(0xFF060A14);
  static Color cardLight = const Color(0xFFFFFFFF);
  static Color primary = const Color(0xFF00E5FF);
  static Color primaryDark = const Color(0xFF00B0FF);
  static Color secondary = const Color(0xFFE040FB);
  static Color secondaryDark = const Color(0xFFCC00FF);
  static Color tertiary = const Color(0xFF76FF03);
  static Color tertiaryDark = const Color(0xFF64DD17);
  static Color cardDark = const Color(0xFF0E1422);
  static Color navDark = const Color(0xFF0A0E1A);
  static Color inputDark = const Color(0xFF161C2E);
  static void applyPreset(ThemePreset p) {
    primary = p.primary; primaryDark = p.primaryDark;
    secondary = p.secondary; secondaryDark = p.secondaryDark;
    tertiary = p.tertiary; tertiaryDark = p.tertiaryDark;
    cardDark = p.cardDark; navDark = p.navDark; inputDark = p.inputDark;
  }
}

class BestCatchBuddyTheme {
  BestCatchBuddyTheme._();
  static ThemeData lightPreset(ThemePreset p) => _build(p, false);
  static ThemeData darkPreset(ThemePreset p) => _build(p, true);

  static ThemeData _build(ThemePreset p, bool dark) {
    final brightness = dark ? Brightness.dark : Brightness.light;
    final scaffoldBg = dark ? const Color(0xFF060A14) : const Color(0xFFF0F4FF);
    final cardBg = dark ? p.cardDark.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85);
    final appBarBg = dark ? p.navDark : const Color(0xFF0A0E1A);
    final inputBg = dark ? p.inputDark : Colors.white;
    final navBg = dark ? p.navDark : Colors.white;
    final onSurface = dark ? const Color(0xFFE0E6F0) : const Color(0xFF0A0E1A);
    final prim = dark ? p.primary : p.primaryDark;
    final iconCol = dark ? const Color(0xFFE0E6F0) : Colors.white;
    final onPrim = dark ? const Color(0xFF003544) : Colors.white;
    final colorScheme = ColorScheme(
      brightness: brightness, primary: prim, onPrimary: onPrim,
      secondary: dark ? p.secondary : p.secondaryDark,
      onSecondary: dark ? const Color(0xFF4A0072) : Colors.white,
      tertiary: dark ? p.tertiary : p.tertiaryDark, onTertiary: Colors.black,
      error: dark ? const Color(0xFFFF5252) : const Color(0xFFFF1744),
      onError: dark ? const Color(0xFF3E0014) : Colors.white,
      surface: cardBg, onSurface: onSurface,
    );
    return ThemeData(
      useMaterial3: true, colorScheme: colorScheme, scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(centerTitle: false, elevation: 0, scrolledUnderElevation: dark ? 0 : 2,
        backgroundColor: appBarBg, foregroundColor: iconCol,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: iconCol, letterSpacing: 1.2),
        iconTheme: IconThemeData(color: iconCol),
      ),
      cardTheme: CardThemeData(elevation: 1, shadowColor: Colors.black.withValues(alpha: dark ? 0.2 : 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias, color: cardBg, surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: prim, foregroundColor: onPrim, elevation: 3,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14)))),
      navigationBarTheme: NavigationBarThemeData(elevation: dark ? 8 : 0, shadowColor: dark ? Colors.black87 : Colors.transparent,
        backgroundColor: navBg, indicatorColor: p.primary.withValues(alpha: dark ? 0.12 : 0.08),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: prim, letterSpacing: 0.5);
          return const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.grey);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return IconThemeData(color: prim, size: 24);
          return const IconThemeData(color: Colors.grey, size: 22);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(filled: true, fillColor: inputBg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: prim, width: 2)),
        errorBorder: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide(color: Color(0xFFFF1744))),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: TextStyle(color: dark ? Colors.grey.shade400 : Colors.grey.shade600, letterSpacing: 0.5),
        prefixIconColor: Colors.grey.shade500,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(prim), foregroundColor: WidgetStatePropertyAll(onPrim),
        elevation: const WidgetStatePropertyAll(4), shadowColor: WidgetStatePropertyAll(p.primary.withValues(alpha: 0.3)),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12)))),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
      )),
      dialogTheme: DialogThemeData(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        backgroundColor: dark ? p.cardDark : null, elevation: 8),
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
        backgroundColor: dark ? p.inputDark : null),
      dividerTheme: DividerThemeData(color: Colors.grey.shade200, thickness: 1, space: 0),
    );
  }
}

class PageTransition extends PageRouteBuilder {
  final Widget page;
  PageTransition({required this.page}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.25, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic)),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

class BestCatchBuddyApp extends StatelessWidget {
  const BestCatchBuddyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    AppColors.applyPreset(themeProvider.preset);
    return MaterialApp(
      title: 'Best Fish Buddy',
      debugShowCheckedModeBanner: false,
      theme: BestCatchBuddyTheme.lightPreset(themeProvider.preset),
      darkTheme: BestCatchBuddyTheme.darkPreset(themeProvider.preset),
      themeMode: themeProvider.themeMode,
      home: const SplashScreen(),
    );
  }
}

// ─── Splash / Welcome Screen ─────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _version = '';

  @override
  void initState() { super.initState(); _loadVersion(); }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      if (mounted) setState(() => _version = '1.0.0');
    }
  }

  Future<void> _navigateToHome() async {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  Widget _linkButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.white70),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70,
            decoration: TextDecoration.underline, decorationColor: Colors.white38)),
          const SizedBox(width: 4),
          const Icon(Icons.open_in_new, size: 12, color: Colors.white38),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tp = context.watch<ThemeProvider>();
    return Scaffold(
      body: Container(
        width: double.infinity, height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
            Color(0xFF0A1628), Color(0xFF0D2137), Color(0xFF0A1A2E), Color(0xFF06101E),
          ]),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              Hero(
                tag: 'app_logo',
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(color: tp.preset.primary.withValues(alpha: 0.4), blurRadius: 30),
                      BoxShadow(color: tp.preset.primary.withValues(alpha: 0.2), blurRadius: 60),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Best Fish Buddy',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Color(0xFF76FF03), letterSpacing: 1.5)),
              const SizedBox(height: 6),
              const Text('For Bragging Rights!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Colors.white, letterSpacing: 3)),
              const SizedBox(height: 20),
              // Info links
              _linkButton('How to Use', Icons.menu_book, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToUseScreen()));
              }),
              const SizedBox(height: 10),
              _linkButton('About', Icons.info_outline, () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              }),
              const Spacer(),
              Text(_version.isNotEmpty ? 'v$_version' : '', style: const TextStyle(fontSize: 13, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _navigateToHome,
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('CONTINUE'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: tp.preset.primary, foregroundColor: const Color(0xFF003544),
                      elevation: 8, shadowColor: tp.preset.primary.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 2),
                    ),
                  ),
                ),
              ),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Theme Selector Bottom Sheet ──────────────────────────────────────────────
void _showSizeChart(BuildContext context) {
  final species = [
    ('Bass (Largemouth)', '30-50 cm', '1-5 kg'),
    ('Bass (Smallmouth)', '25-45 cm', '1-3 kg'),
    ('Bass (Striped)', '50-100 cm', '5-20 kg'),
    ('Bluegill', '15-25 cm', '0.1-0.5 kg'),
    ('Crappie', '20-30 cm', '0.2-0.5 kg'),
    ('Northern Pike', '50-100 cm', '2-10 kg'),
    ('Muskellunge', '70-130 cm', '5-20 kg'),
    ('Walleye', '30-60 cm', '1-4 kg'),
    ('Yellow Perch', '15-30 cm', '0.1-0.5 kg'),
    ('Rainbow Trout', '25-50 cm', '0.5-3 kg'),
    ('Brook Trout', '20-40 cm', '0.2-2 kg'),
    ('Lake Trout', '40-80 cm', '2-10 kg'),
    ('Atlantic Salmon', '50-90 cm', '3-10 kg'),
    ('Chinook Salmon', '60-100 cm', '5-20 kg'),
    ('Coho Salmon', '45-70 cm', '3-8 kg'),
    ('Catfish (Channel)', '30-60 cm', '1-5 kg'),
    ('Carp', '40-80 cm', '2-10 kg'),
    ('Cod', '50-100 cm', '3-15 kg'),
    ('Halibut', '80-200 cm', '10-100 kg'),
    ('Tuna (Bluefin)', '150-300 cm', '100-400 kg'),
  ];

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Fish Size Chart'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: species.map((s) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(children: [
                Expanded(flex: 3, child: Text(s.$1, style: const TextStyle(fontSize: 13))),
                Expanded(flex: 2, child: Text(s.$2, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
                Expanded(flex: 2, child: Text(s.$3, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              ]),
            )).toList(),
          ),
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
    ),
  );
}

Future<void> _exportCsv(BuildContext context) async {
  try {
    final catches = await DatabaseService.instance.getCatches();
    if (catches.isEmpty) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No catches to export')));
      return;
    }
    final rows = <List<String>>[
      ['Species', 'Angler', 'Weight', 'Unit', 'Length', 'Length Unit', 'Location', 'Lure', 'Notes', 'Trip', 'Temperature', 'Conditions', 'Date'],
    ];
    for (final c in catches) {
      rows.add([
        c.species, c.angler,
        c.weight?.toStringAsFixed(2) ?? '', c.weightUnit,
        c.length?.toStringAsFixed(1) ?? '', c.lengthUnit,
        c.location, c.lure, c.notes ?? '', c.tripName ?? '',
        c.weatherTemp?.round().toString() ?? '', c.weatherCondition ?? '',
        DateFormat('yyyy-MM-dd HH:mm').format(c.caughtAt),
      ]);
    }
    final csv = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/BestFishBuddy_export.csv');
    await file.writeAsString(csv);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Exported to ${file.path}')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: $e'), backgroundColor: Colors.red));
    }
  }
}

void showThemeSelector(BuildContext context) {
  final tp = context.read<ThemeProvider>();
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const Text('Choose Theme', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            ...List.generate(themePresets.length, (i) {
              final p = themePresets[i];
              final selected = tp.presetIndex == i;
              return ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [p.primary, p.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(12),
                    border: selected ? Border.all(color: Colors.white, width: 2) : null,
                  ),
                  child: Icon(p.icon, color: Colors.white, size: 20),
                ),
                title: Text(p.name, style: TextStyle(fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                trailing: selected ? Icon(Icons.check_circle, color: p.primary) : null,
                onTap: () { tp.setPreset(i); Navigator.pop(ctx); },
              );
            }),
            const Divider(height: 1),
            SwitchListTile(
              title: const Text('Auto Dark Mode'),
              subtitle: const Text('Dark 8PM–7AM, Light 7AM–8PM'),
              value: tp.autoDark,
              activeColor: tp.preset.primary,
              onChanged: (v) { tp.setAutoDark(v); if (v) Navigator.pop(ctx); },
              secondary: Icon(tp.autoDark ? Icons.nightlight_round : Icons.light_mode, color: tp.preset.primary),
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Home / Navigation Shell ──────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _updateBadge();
  }

  Future<void> _updateBadge() async {
    try {
      final count = await DatabaseService.instance.getCatchCount();
      if (count > 0) {
        await FlutterNativeBadge.setBadgeCount(count);
      } else {
        await FlutterNativeBadge.clearBadgeCount();
      }
    } catch (_) {}
  }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    AppColors.applyPreset(themeProvider.preset);

    // Home screen quick actions
    try {
      final qa = QuickActions();
      qa.setShortcutItems([
        const ShortcutItem(type: 'add_catch', localizedTitle: 'Add Catch', icon: 'ic_launcher'),
      ]);
      qa.initialize((type) {
        if (type == 'add_catch' && context.mounted) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AddCatchScreen()));
        }
      });
    } catch (_) {}

    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Container(width: 30, height: 30,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
            child: ClipRRect(borderRadius: BorderRadius.circular(7),
              child: Image.asset('assets/logo.png', fit: BoxFit.cover)),
          ),
          const SizedBox(width: 10),
          Flexible(child: const Text('Best Fish Buddy', overflow: TextOverflow.ellipsis)),
        ]),
        actions: [
          // Cloud sync status
          IconButton(
            icon: Icon(
              FirebaseSyncService.instance.isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
              color: FirebaseSyncService.instance.isLoggedIn ? Colors.green : Colors.grey,
              size: 20,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CloudSyncScreen()),
            ),
            tooltip: FirebaseSyncService.instance.isLoggedIn ? 'Cloud sync active' : 'Cloud sync off',
          ),
          Consumer<ThemeProvider>(builder: (_, tp, __) => IconButton(
            icon: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
              child: tp.isDark ? const Icon(Icons.light_mode, key: ValueKey('light')) : const Icon(Icons.dark_mode, key: ValueKey('dark'))),
            onPressed: tp.toggle,
            tooltip: tp.isDark ? 'Switch to light' : 'Switch to dark',
          )),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'howto') Navigator.push(context, MaterialPageRoute(builder: (_) => const HowToUseScreen()));
              if (v == 'about') Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
              if (v == 'export') _exportCsv(context);
              if (v == 'size') _showSizeChart(context);
              if (v == 'encyclopedia') Navigator.push(context, MaterialPageRoute(builder: (_) => EncyclopediaScreen()));
              if (v == 'cloud') Navigator.push(context, MaterialPageRoute(builder: (_) => const CloudSyncScreen()));
              if (v == 'stats') Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              if (v == 'gallery') Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
              if (v == 'theme') showThemeSelector(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'gallery', child: ListTile(leading: Icon(Icons.photo_library), title: Text('Photo Gallery'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'stats', child: ListTile(leading: Icon(Icons.bar_chart), title: Text('Statistics'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'theme', child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Choose Theme'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'howto', child: ListTile(leading: Icon(Icons.menu_book), title: Text('How to Use'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.file_download), title: Text('Export CSV'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              PopupMenuItem(value: 'cloud', child: ListTile(
                leading: Icon(FirebaseSyncService.instance.isLoggedIn ? Icons.cloud_done : Icons.cloud_sync, color: FirebaseSyncService.instance.isLoggedIn ? Colors.green : null),
                title: Text(FirebaseSyncService.instance.isLoggedIn ? 'Signed in as ${FirebaseSyncService.instance.user!.email!.split('@').first}' : 'Cloud Sync'),
                dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'encyclopedia', child: ListTile(leading: Icon(Icons.menu_book), title: Text('Species Encyclopedia'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'size', child: ListTile(leading: Icon(Icons.straighten), title: Text('Fish Size Chart'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'about', child: ListTile(leading: Icon(Icons.info_outline), title: Text('About'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
            ],
          ),
        ],
      ),
      body: WaterBackground(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: (colorScheme.brightness == Brightness.dark ? AppColors.navDark : const Color(0xFF0A0E1A)).withValues(alpha: 0.8),
            ),
            child: Container(height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: colorScheme.brightness == Brightness.dark ? 0.06 : 0.06),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(22),
                ),
                indicatorSize: TabBarIndicatorSize.tab, dividerHeight: 0, isScrollable: true,
                labelColor: AppColors.primary,
                unselectedLabelColor: colorScheme.brightness == Brightness.dark ? Colors.grey.shade500 : Colors.white54,
                labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.set_meal, size: 18), SizedBox(width: 6), Text('CATCHES')])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.people, size: 18), SizedBox(width: 6), Text('COUNTER')])),
                  Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.map, size: 18), SizedBox(width: 6), Text('MAP')])),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [CatchesScreen(), CounterScreen(), MapScreen()],
            ),
          ),
        ]),
      ),
    );
  }
}
