import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/theme_provider.dart';
import '../main.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    AppColors.applyPreset(tp.preset);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Logo
          Center(
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: tp.preset.primary.withValues(alpha: 0.3), blurRadius: 20)],
              ),
              child: ClipRRect(borderRadius: BorderRadius.circular(20),
                child: Image.asset('assets/logo.png', fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('Best Fish Buddy', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: tp.preset.tertiary))),
          const SizedBox(height: 4),
          Center(child: Text('For Bragging Rights!', style: TextStyle(fontSize: 13, color: cs.onSurface.withValues(alpha: 0.5)))),
          const SizedBox(height: 24),

          const Text('Built With', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _linkTile(context, tp, 'Flutter & Dart', 'https://flutter.dev'),
          _linkTile(context, tp, 'flutter_map + OpenStreetMap', 'https://openstreetmap.org'),
          _linkTile(context, tp, 'SQLite', 'https://sqlite.org'),
          _linkTile(context, tp, 'Provider', 'https://pub.dev/packages/provider'),
          _linkTile(context, tp, 'speech_to_text', 'https://pub.dev/packages/speech_to_text'),
          _linkTile(context, tp, 'geolocator', 'https://pub.dev/packages/geolocator'),
          _linkTile(context, tp, 'image_picker', 'https://pub.dev/packages/image_picker'),
          _linkTile(context, tp, 'url_launcher', 'https://pub.dev/packages/url_launcher'),

          const SizedBox(height: 24),
          const Text('Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _feedbackButton(context, tp, 'Report a Bug', Icons.bug_report, () => _sendEmail(context, 'Bug Report')),
          const SizedBox(height: 8),
          _feedbackButton(context, tp, 'Suggest a Feature', Icons.lightbulb_outline, () => _sendEmail(context, 'Feature Suggestion')),
        ],
      ),
    );
  }

  Widget _linkTile(BuildContext context, ThemeProvider tp, String label, String url) {
    final cs2 = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        child: Row(children: [
          Icon(Icons.open_in_new, size: 14, color: tp.preset.primary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: tp.preset.primary, decoration: TextDecoration.underline, decorationColor: tp.preset.primary.withValues(alpha: 0.3))),
          const Spacer(),
          Icon(Icons.chevron_right, size: 16, color: cs2.onSurface.withValues(alpha: 0.3)),
        ]),
      ),
    );
  }

  Widget _feedbackButton(BuildContext context, ThemeProvider tp, String label, IconData icon, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: tp.preset.primary,
          side: BorderSide(color: tp.preset.primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, String subject) async {
    final tp = context.read<ThemeProvider>();
    String appVersion = 'unknown';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version;
    } catch (_) {}
    final email = 'BestFishBuddy@gmail.com';
    final sub = Uri.encodeComponent('[Best Fish Buddy] $subject');
    final body = Uri.encodeComponent(
      '--- Diagnostic Info ---\n'
      'App Version: $appVersion\n'
      'Theme: ${tp.preset.name}\n'
      'Mode: ${tp.isDark ? "Dark" : "Light"}\n\n'
      '--- Please describe your issue below ---\n'
    );
    final uri = Uri.parse('mailto:$email?subject=$sub&body=$body');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('No email app found'),
            content: Text('Please email us at:\n$email\n\nSubject: [Best Fish Buddy] $subject'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
            ],
          ),
        );
      }
    }
  }
}
