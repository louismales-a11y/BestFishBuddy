import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/catch.dart';
import '../services/database_service.dart';
import '../services/theme_provider.dart';
import 'add_catch_screen.dart';
import '../main.dart';

class _StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const _StaggeredFadeSlide({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 60).clamp(0, 600)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class CatchesScreen extends StatefulWidget {
  const CatchesScreen({super.key});

  @override
  State<CatchesScreen> createState() => _CatchesScreenState();
}

class _CatchesScreenState extends State<CatchesScreen> {
  List<Catch> _catches = [];
  bool _loading = true;
  String _recordType = 'weight';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  String _sortBy = 'date_desc'; // date_desc, date_asc, species, weight, angler

  List<Catch> get _filteredCatches {
    var list = _catches.toList();
    // Filter
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((c) =>
        c.species.toLowerCase().contains(q) ||
        c.angler.toLowerCase().contains(q) ||
        c.location.toLowerCase().contains(q) ||
        c.lure.toLowerCase().contains(q)
      ).toList();
    }
    // Sort
    switch (_sortBy) {
      case 'date_asc': list.sort((a, b) => a.caughtAt.compareTo(b.caughtAt)); break;
      case 'species': list.sort((a, b) => a.species.compareTo(b.species)); break;
      case 'weight': list.sort((a, b) => (b.weight ?? 0).compareTo(a.weight ?? 0)); break;
      case 'angler': list.sort((a, b) => a.angler.compareTo(b.angler)); break;
      default: list.sort((a, b) => b.caughtAt.compareTo(a.caughtAt)); // date_desc
    }
    return list;
  }

  Map<String, List<Catch>> get _groupedCatches {
    final grouped = <String, List<Catch>>{};
    for (final c in _filteredCatches) {
      final day = DateFormat('EEEE, MMMM d, yyyy').format(c.caughtAt);
      grouped.putIfAbsent(day, () => []).add(c);
    }
    return grouped;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCatches();
  }

  Future<void> _loadCatches() async {
    setState(() => _loading = true);
    final catches = await DatabaseService.instance.getCatches();
    setState(() {
      _catches = catches;
      _loading = false;
    });
  }

  Future<void> _deleteCatch(Catch c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text('Delete Catch'),
          ],
        ),
        content: Text('Remove the ${c.species} caught by ${c.angler}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && c.id != null) {
      await DatabaseService.instance.deleteCatch(c.id!);
      _loadCatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _filteredCatches.isEmpty
              ? _emptyState()
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search species, angler...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () { _searchCtrl.clear(); setState(() => _searchQuery = ''); })
                              : null,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    // Sort chips
                    SizedBox(
                      height: 32,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        children: [
                          _sortChip('Newest', 'date_desc'),
                          _sortChip('Oldest', 'date_asc'),
                          _sortChip('Species', 'species'),
                          _sortChip('Weight', 'weight'),
                          _sortChip('Angler', 'angler'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadCatches,
                        child: ListView.builder(
                          padding: const EdgeInsets.only(bottom: 88),
                          itemCount: 1 + _groupedCatches.entries.length + _filteredCatches.length,
                          itemBuilder: (ctx, i) {
                            if (i == 0) return _recordsHeader();
                            // Build date headers + cards from grouped data
                            int idx = 0;
                            for (final entry in _groupedCatches.entries) {
                              if (i == 1 + idx) return _dateHeader(entry.key);
                              idx++;
                              for (var j = 0; j < entry.value.length; j++) {
                                if (i == 1 + idx) {
                                  return _StaggeredFadeSlide(
                                    index: j,
                                    child: _catchCard(entry.value[j], j),
                                  );
                                }
                                idx++;
                              }
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            PageTransition(page: const AddCatchScreen()),
          );
          _loadCatches();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // ─── Empty State ────────────────────────────────────────────────────────────
  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.asset('assets/logo.png', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No catches yet!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add your first catch',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ─── Records Header ────────────────────────────────────────────────────────
  Widget _recordsHeader() {
    final totalCatches = _catches.length;
    final speciesCount = _catches.map((c) => c.species.toLowerCase()).toSet().length;

    // Find biggest by selected record type
    Catch? biggest;
    if (_recordType == 'weight') {
      final withVal = _catches.where((c) => c.weight != null).toList();
      withVal.sort((a, b) => b.weight!.compareTo(a.weight!));
      biggest = withVal.isNotEmpty ? withVal.first : null;
    } else {
      final withVal = _catches.where((c) => c.length != null).toList();
      withVal.sort((a, b) => b.length!.compareTo(a.length!));
      biggest = withVal.isNotEmpty ? withVal.first : null;
    }

    final anglerCounts = <String, int>{};
    for (final c in _catches) {
      anglerCounts[c.angler] = (anglerCounts[c.angler] ?? 0) + 1;
    }
    String? topAngler;
    int? topAnglerCount;
    for (final e in anglerCounts.entries) {
      if (topAngler == null || e.value > topAnglerCount!) {
        topAngler = e.key;
        topAnglerCount = e.value;
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // ── Trophy / Biggest Fish ───────────────────────────────────────────────
        if (biggest != null)
          Container(
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: SweepGradient(
                colors: [
                  AppColors.tertiary.withValues(alpha: 0.2),
                  AppColors.tertiary.withValues(alpha: 0.05),
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.secondary.withValues(alpha: 0.1),
                  AppColors.tertiary.withValues(alpha: 0.2),
                ],
              ),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.3),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Trophy icon with glow
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.tertiary.withValues(alpha: 0.3),
                          AppColors.tertiary.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      color: AppColors.tertiary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'BIGGEST CATCH',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.tertiary,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.auto_awesome, size: 12, color: AppColors.tertiary.withValues(alpha: 0.6)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${biggest.species} — ${_recordType == 'weight' ? biggest.weightDisplay : biggest.lengthDisplay}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : colorScheme.onSurface,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'caught by ${biggest.angler} on ${DateFormat('MMM d').format(biggest.caughtAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _recordTypeChip('weight', '⚖️ Weight'),
                            const SizedBox(width: 6),
                            _recordTypeChip('length', '📏 Length'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Trophy badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.tertiary,
                          AppColors.tertiary.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.tertiary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Icon(Icons.star, color: Colors.black, size: 22),
                  ),
                ],
              ),
            ),
          ),

        // ── Stats Row ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
          child: Row(
            children: [
              _statTile(
                icon: Icons.set_meal,
                label: 'Catches',
                value: '$totalCatches',
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _statTile(
                icon: Icons.category,
                label: 'Species',
                value: '$speciesCount',
                color: AppColors.secondary,
              ),
              const SizedBox(width: 8),
              if (topAngler != null)
                _statTile(
                  icon: Icons.person,
                  label: 'Top Angler',
                  value: '$topAngler ($topAnglerCount)',
                  color: AppColors.tertiary,
                  flex: 2,
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    int flex = 1,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.08),
              color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
            width: 1.0,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : colorScheme.onSurface,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateHeader(String date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Text(date.toUpperCase(),
        style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: isDark ? 0.5 : 0.4),
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _sortChip(String label, String value) {
    final selected = _sortBy == value;
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => setState(() => _sortBy = value),
      child: Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary.withValues(alpha: 0.3) : cs.onSurface.withValues(alpha: 0.15)),
        ),
        child: Text(label,
          style: TextStyle(
            fontSize: 11, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.primary : cs.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _recordTypeChip(String type, String label) {
    final selected = _recordType == type;
    return GestureDetector(
      onTap: () => setState(() => _recordType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.tertiary.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.tertiary.withValues(alpha: 0.4)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.tertiary : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ─── Catch Card ─────────────────────────────────────────────────────────────
  Widget _catchCard(Catch c, int index) {
    final dateStr = DateFormat('MMM d, yyyy • h:mm a').format(c.caughtAt);
    final photos = c.photoPaths ?? [];
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(context, PageTransition(page: AddCatchScreen(existingCatch: c)));
          _loadCatches();
        },
        onLongPress: () => _deleteCatch(c),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(width: 56, height: 56,
                  child: photos.isNotEmpty
                      ? Image.file(File(photos.first), fit: BoxFit.cover, errorBuilder: (_, __, ___) => _photoPlaceholder())
                      : _photoPlaceholder()),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(children: [
                      Expanded(child: Text(c.species, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: colorScheme.onSurface), overflow: TextOverflow.ellipsis)),
                      Flexible(child: Text(c.angler, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: colorScheme.onSurface.withValues(alpha: 0.5)), overflow: TextOverflow.ellipsis)),
                    ]),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(children: [
                        if (c.location.isNotEmpty) ...[Icon(Icons.location_on, size: 13, color: colorScheme.onSurface.withValues(alpha: 0.4)), const SizedBox(width: 2), Text(c.location, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))), const SizedBox(width: 12)],
                        if (c.weight != null) ...[Icon(Icons.monitor_weight, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)), const SizedBox(width: 2), Text(c.weightDisplay, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5))), const SizedBox(width: 12)],
                        if (c.length != null) ...[Icon(Icons.straighten, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)), const SizedBox(width: 2), Text(c.lengthDisplay, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5)))],
                        if (c.weatherTemp != null) ...[Icon(Icons.wb_sunny, size: 12, color: colorScheme.onSurface.withValues(alpha: 0.4)), const SizedBox(width: 2), Text(c.weatherDisplay, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withValues(alpha: 0.5)))],
                      ]),
                    ),
                    const SizedBox(height: 2),
                    Row(children: [
                      Icon(Icons.access_time, size: 11, color: colorScheme.onSurface.withValues(alpha: 0.35)),
                      const SizedBox(width: 3),
                      Text(dateStr, style: TextStyle(fontSize: 11, color: colorScheme.onSurface.withValues(alpha: 0.35))),
                    ]),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => _shareCatch(c),
                child: Icon(Icons.share_outlined, size: 18, color: Colors.grey.shade400),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareCatch(Catch c) async {
    final buf = StringBuffer();
    buf.writeln('🎣 ${c.species} caught by ${c.angler}!');
    if (c.weight != null) buf.writeln('⚖️ ${c.weightDisplay}');
    if (c.length != null) buf.writeln('📏 ${c.lengthDisplay}');
    if (c.location.isNotEmpty) buf.writeln('📍 ${c.location}');
    if (c.lure.isNotEmpty) buf.writeln('🪤 Lure: ${c.lure}');
    if (c.weatherTemp != null) buf.writeln('🌤️ ${c.weatherDisplay}');
    buf.writeln('📅 ${DateFormat('MMM d, yyyy  h:mm a').format(c.caughtAt)}');
    buf.writeln('');
    buf.writeln('Logged with Best Fish Buddy 🐟');
    await Share.share(buf.toString());
  }

  Widget _photoPlaceholder() {
    return Container(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
      child: Icon(Icons.set_meal, size: 24, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2)),
    );
  }
}
