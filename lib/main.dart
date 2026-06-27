import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screens/catches_screen.dart';
import 'screens/counter_screen.dart';
import 'screens/map_screen.dart';
import 'screens/how_to_use_screen.dart';
import 'screens/about_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/gallery_screen.dart';
import 'services/theme_provider.dart';
import 'models/theme_presets.dart';
import 'widgets/water_background.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    AppColors.applyPreset(themeProvider.preset);

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
          const Text('Best Fish Buddy'),
        ]),
        actions: [
          Consumer<ThemeProvider>(builder: (_, tp, __) => IconButton(
            icon: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
              child: tp.isDark ? const Icon(Icons.light_mode, key: ValueKey('light')) : const Icon(Icons.dark_mode, key: ValueKey('dark'))),
            onPressed: tp.toggle,
            tooltip: tp.isDark ? 'Switch to light' : 'Switch to dark',
          )),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              if (v == 'stats') Navigator.push(context, MaterialPageRoute(builder: (_) => const StatsScreen()));
              if (v == 'gallery') Navigator.push(context, MaterialPageRoute(builder: (_) => const GalleryScreen()));
              if (v == 'theme') showThemeSelector(context);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'stats', child: ListTile(leading: Icon(Icons.bar_chart), title: Text('Statistics'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'gallery', child: ListTile(leading: Icon(Icons.photo_library), title: Text('Photo Gallery'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              const PopupMenuItem(value: 'theme', child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('Choose Theme'), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
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
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                indicatorSize: TabBarIndicatorSize.tab, dividerHeight: 0,
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
