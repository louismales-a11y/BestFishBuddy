import 'package:flutter/material.dart';
import '../models/fish_info.dart';
import '../main.dart';

class EncyclopediaScreen extends StatelessWidget {
  const EncyclopediaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Species Encyclopedia')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: fishEncyclopedia.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final f = fishEncyclopedia[i];
          return ExpansionTile(
            leading: Text(f.icon, style: const TextStyle(fontSize: 28)),
            title: Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(f.scientific, style: TextStyle(fontSize: 12, color: cs.onSurface.withValues(alpha: 0.5), fontStyle: FontStyle.italic)),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            children: [
              Text(f.description, style: TextStyle(fontSize: 14, color: cs.onSurface.withValues(alpha: 0.7))),
              const SizedBox(height: 12),
              _infoRow('Habitat', f.habitat, Icons.location_on, cs),
              _infoRow('Typical Size', '${f.typicalLength} / ${f.typicalWeight}', Icons.straighten, cs),
              _infoRow('Record', f.record, Icons.emoji_events, cs),
              _infoRow('Best Season', f.season, Icons.calendar_today, cs),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(String label, String value, IconData icon, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        SizedBox(width: 90, child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.6)))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, color: cs.onSurface))),
      ]),
    );
  }
}
