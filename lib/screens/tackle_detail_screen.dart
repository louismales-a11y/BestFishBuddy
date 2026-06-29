import 'dart:io';
import 'package:flutter/material.dart';
import '../models/tackle_item.dart';

class TackleDetailScreen extends StatelessWidget {
  final TackleItem item;

  const TackleDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomPad + 40),
        children: [
          // Photo
          if (item.photoPath != null && File(item.photoPath!).existsSync())
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(item.photoPath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (a, b, c) => _noPhoto(theme),
              ),
            )
          else
            _noPhoto(theme),
          const SizedBox(height: 16),

          // Type badge
          Chip(
            avatar: const Icon(Icons.category, size: 16),
            label: Text(item.type, style: const TextStyle(fontSize: 13)),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 20),

          // Target species
          if (item.targetSpecies.isNotEmpty) ...[
            Text('Target Species',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: item.targetSpecies.map((s) => Chip(
                    avatar: const Icon(Icons.set_meal, size: 14),
                    label: Text(s, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Tips
          if (item.tips.isNotEmpty) ...[
            Text('Fishing Tips',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline,
                      size: 20, color: theme.colorScheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item.tips,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.85),
                        )),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _noPhoto(ThemeData theme) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.set_meal,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 8),
          Text('No photo',
              style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
        ],
      ),
    );
  }
}
