import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../models/catch.dart';
import '../services/theme_provider.dart';
import '../services/database_service.dart';
import '../main.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<Catch> _catches = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final c = await DatabaseService.instance.getCatches();
    if (mounted) setState(() { _catches = c; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    // Compute stats
    final speciesCounts = <String, int>{};
    final anglerCounts = <String, int>{};
    final monthlyCounts = <String, int>{};
    double totalWeight = 0;
    int weightCount = 0;

    for (final c in _catches) {
      speciesCounts[c.species] = (speciesCounts[c.species] ?? 0) + 1;
      anglerCounts[c.angler] = (anglerCounts[c.angler] ?? 0) + 1;
      final m = '${c.caughtAt.month}/${c.caughtAt.year}';
      monthlyCounts[m] = (monthlyCounts[m] ?? 0) + 1;
      if (c.weight != null) { totalWeight += c.weight!; weightCount++; }
    }

    final sortedSpecies = speciesCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedAnglers = anglerCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final sortedMonthly = monthlyCounts.entries.toList()..sort((a, b) {
      final ap = a.key.split('/'); final bp = b.key.split('/');
      final ay = int.parse(ap[1]), am = int.parse(ap[0]), by = int.parse(bp[1]), bm = int.parse(bp[0]);
      return (ay == by ? am.compareTo(bm) : ay.compareTo(by));
    });

    final colors = [AppColors.primary, AppColors.secondary, AppColors.tertiary,
      Colors.orange, Colors.pink, Colors.cyan, Colors.amber, Colors.purple, Colors.teal, Colors.red];

    return Scaffold(
      appBar: AppBar(title: const Text('Catch Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          Row(children: [
            _statCard(cs, 'Total', '${_catches.length}', Icons.set_meal),
            const SizedBox(width: 8),
            _statCard(cs, 'Species', '${speciesCounts.length}', Icons.category),
            const SizedBox(width: 8),
            _statCard(cs, 'Anglers', '${anglerCounts.length}', Icons.people),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            _statCard(cs, 'Avg Weight', weightCount > 0 ? '${(totalWeight / weightCount).toStringAsFixed(1)} kg' : '--', Icons.monitor_weight),
            const SizedBox(width: 8),
            _statCard(cs, 'Biggest', _catches.where((c) => c.weight != null).fold<double?>(null, (max, c) => max == null || c.weight! > max ? c.weight : max)?.toString() ?? '--', Icons.emoji_events),
          ]),

          const SizedBox(height: 24),
          const Text('Catches by Species', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: PieChart(
            PieChartData(sections: sortedSpecies.take(8).map((e) =>
              PieChartSectionData(value: e.value.toDouble(), title: '${e.value}', color: colors[sortedSpecies.indexOf(e) % colors.length],
                radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white))
            ).toList(), sectionsSpace: 2, centerSpaceRadius: 30),
          )),
          // Legend
          Wrap(spacing: 12, runSpacing: 4, children: sortedSpecies.take(8).map((e) =>
            Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 10, height: 10, color: colors[sortedSpecies.indexOf(e) % colors.length]),
              const SizedBox(width: 4),
              Text('${e.key} (${e.value})', style: TextStyle(fontSize: 12, color: cs.onSurface)),
            ])
          ).toList()),

          const SizedBox(height: 24),
          const Text('Catches by Angler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(height: 200, child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: sortedAnglers.first.value.toDouble(),
              barGroups: sortedAnglers.map((e) => BarChartGroupData(x: sortedAnglers.indexOf(e),
                barRods: [BarChartRodData(toY: e.value.toDouble(), color: colors[sortedAnglers.indexOf(e) % colors.length], width: 20)]
              )).toList(),
              titlesData: FlTitlesData(show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                  Text(sortedAnglers[v.toInt()].key, style: TextStyle(fontSize: 10, color: cs.onSurface)))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          )),

          const SizedBox(height: 24),
          const Text('Monthly Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          SizedBox(height: 180, child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: sortedMonthly.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b),
              barGroups: sortedMonthly.map((e) => BarChartGroupData(x: sortedMonthly.indexOf(e),
                barRods: [BarChartRodData(toY: e.value.toDouble(), color: AppColors.primary, width: 16)]
              )).toList(),
              titlesData: FlTitlesData(show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) =>
                  Text(sortedMonthly[v.toInt()].key, style: TextStyle(fontSize: 9, color: cs.onSurface)))),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
            ),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _statCard(ColorScheme cs, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: cs.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cs.onSurface)),
          Text(label, style: TextStyle(fontSize: 10, color: cs.onSurface.withValues(alpha: 0.5))),
        ]),
      ),
    );
  }
}
