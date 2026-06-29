import 'package:flutter/material.dart';
import '../data/tackle_database.dart';
import '../models/tackle_item.dart';
import '../services/database_service.dart';

/// Browse all common tackle types and add them to your personal tackle box.
class TackleCatalogScreen extends StatelessWidget {
  const TackleCatalogScreen({super.key});

  /// Group tackle types by category.
  static Map<String, List<TackleTypeInfo>> _grouped() {
    final map = <String, List<TackleTypeInfo>>{};
    for (final t in tackleTypeDatabase) {
      map.putIfAbsent(t.category, () => []);
      map[t.category]!.add(t);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped();
    return Scaffold(
      appBar: AppBar(title: const Text('Tackle Catalog')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: grouped.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Text(entry.key.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                      letterSpacing: 1.2,
                    )),
              ),
              ...entry.value.map((t) => _CatalogCard(info: t)),
              const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  final TackleTypeInfo info;

  const _CatalogCard({required this.info});

  Future<void> _addToBox(BuildContext context) async {
    final item = TackleItem(
      name: info.name,
      type: info.category,
      targetSpecies: List.from(info.targetSpecies),
      tips: info.tips,
    );
    await DatabaseService.instance.addTackleItem(item);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${info.name} added to your tackle box'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (ctx, scrollCtrl) => ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Text(info.icon, style: const TextStyle(fontSize: 48)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(info.name,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                        Chip(
                          label: Text(info.category,
                              style: const TextStyle(fontSize: 12)),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(info.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.75),
                  )),
              const SizedBox(height: 20),

              // Target species
              Text('Target Species',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: info.targetSpecies.map((s) => Chip(
                      avatar: const Icon(Icons.set_meal, size: 14),
                      label: Text(s, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    )).toList(),
              ),
              const SizedBox(height: 20),

              // Tips
              Text('How to Fish It',
                  style: theme.textTheme.titleSmall
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
                      child: Text(info.tips,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.85),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Add button
              SizedBox(
                height: 48,
                child: FilledButton.icon(
                  onPressed: () {
                    _addToBox(ctx);
                    Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add to My Tackle Box'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(info.icon, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 12),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(info.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(info.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5))),
                  ],
                ),
              ),
              // Quick add button
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _addToBox(context);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
                color: theme.colorScheme.primary,
                tooltip: 'Add to my tackle box',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
