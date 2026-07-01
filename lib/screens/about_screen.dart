import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/help_text.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = 'v${info.version}');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
        actions: [helpButton(context, 'about')],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // App icon & name
          Center(
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset('assets/logo.png',
                      width: 80, height: 80, fit: BoxFit.cover),
                ),
                const SizedBox(height: 12),
                Text('Best Fish Buddy',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800)),
                if (_version.isNotEmpty)
                  Text(_version,
                      style: TextStyle(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Description
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Your hands-free fishing companion.\n'
                'Track catches by voice, snap selfies with your fish, '
                'and never lose a fishing memory.\n\n'
                '🗣️ Voice tally & recording\n'
                '📍 GPS & weather auto-fetch\n'
                '🤳 Selfie camera with countdown\n'
                '🌙 Solunar best fishing times\n'
                '🗺️ Interactive catch map',
                style: TextStyle(height: 1.6, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Built with
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Built with',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _bullets([
                    'Flutter & Dart',
                    'SQLite (sqflite)',
                    'OpenStreetMap (flutter_map)',
                    'OpenWeatherMap API',
                    'Google Places API',
                    'Speech-to-text (speech_to_text)',
                  ]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sign off
          Center(
            child: Text(
              'Tight Lines, Be Safe! 🎣',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _bullets(List<String> items) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ',
                        style: TextStyle(
                            color: t.colorScheme.primary,
                            fontWeight: FontWeight.w700)),
                    Expanded(child: Text(s, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
