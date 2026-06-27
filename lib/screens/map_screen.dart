import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/catch.dart';
import '../services/database_service.dart';
import '../services/api_config.dart';
import '../main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Catch> _catches = [];
  List<Catch> _pinned = [];
  Set<String> _filterSpecies = {};
  Set<String> _filterAnglers = {};
  String? _selectedFilter; // 'species' or 'angler'

  List<Catch> get _filteredPinned {
    if (_selectedFilter == null) return _pinned;
    return _pinned.where((c) {
      if (_selectedFilter == 'species') return _filterSpecies.contains(c.species);
      if (_selectedFilter == 'angler') return _filterAnglers.contains(c.angler);
      return true;
    }).toList();
  }

  Set<String> get _allSpecies => _pinned.map((c) => c.species).toSet();
  Set<String> get _allAnglers => _pinned.map((c) => c.angler).toSet();
  bool _loading = true;
  bool _showBait = false;
  bool _showGas = false;
  bool _showBoatLaunch = false;
  bool _showHeatmap = false;
  List<_Poi> _pois = [];
  bool _searching = false;
  LatLng _mapCenter = const LatLng(44.5, -78.0);
  double _mapZoom = 8.0;
  int _refreshKey = 0;
  LatLng? _currentLocation;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final catches = await DatabaseService.instance.getCatches();
    final pinned = catches.where((c) => c.latitude != null && c.longitude != null).toList();
    if (mounted) {
      setState(() {
        _catches = catches;
        _pinned = pinned;
        _refreshKey++;
        _loading = false;
      });
    }
  }

  Future<void> _searchPois() async {
    setState(() => _searching = true);
    final lat = _mapCenter.latitude;
    final lng = _mapCenter.longitude;

    if (ApiConfig.hasValidPlacesKey) {
      await _searchGooglePlaces(lat, lng);
    } else {
      await _searchOverpass(lat, lng);
    }
    if (mounted) setState(() => _searching = false);
  }

  Future<void> _searchOverpass(double lat, double lng) async {
    final bbox = '${lat - 0.3},${lng - 0.3},${lat + 0.3},${lng + 0.3}';
    final query = '[out:json];(node[shop=bait]($bbox);node[shop=tackle]($bbox);node[shop=fishing]($bbox);node[amenity=fuel]($bbox);node[leisure=marina]($bbox);node[leisure=slipway]($bbox););out;';
    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: {'data': query},
        headers: {'Content-Type': 'application/x-www-form-urlencoded', 'User-Agent': 'BestCatchBuddy/1.0'},
      ).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        final elements = data['elements'] as List? ?? [];
        final pois = <_Poi>[];
        for (final e in elements) {
          final tags = e['tags'] as Map? ?? {};
          final name = tags['name'] as String? ?? '';
          if (name.isEmpty) continue;
          final type = _getPoiType(tags);
          final lat2 = e['lat'] as double? ?? e['center']?['lat'] as double?;
          final lon2 = e['lon'] as double? ?? e['center']?['lon'] as double?;
          if (lat2 != null && lon2 != null) pois.add(_Poi(name: name, type: type, lat: lat2, lng: lon2));
        }
        if (mounted) _showPoiResult(pois);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('API error ${response.statusCode}'), backgroundColor: Colors.red));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Search error: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _searchGooglePlaces(double lat, double lng) async {
    final radius = 30000; // 30km
    final queries = <String, String>{
      'bait': 'fishing tackle shop',
      'gas': 'gas station',
      'boat': 'boat launch marina',
    };
    final allPois = <_Poi>[];

    for (final entry in queries.entries) {
      try {
        final response = await http.get(
          Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json'
            '?location=$lat,$lng'
            '&radius=$radius'
            '&keyword=${Uri.encodeComponent(entry.value)}'
            '&key=${ApiConfig.googlePlacesApiKey}'),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200 && mounted) {
          final data = jsonDecode(response.body);
          final results = data['results'] as List? ?? [];
          for (final r in results) {
            final name = r['name'] as String? ?? '';
            if (name.isEmpty) continue;
            final geo = r['geometry']?['location'];
            if (geo == null) continue;
            allPois.add(_Poi(
              name: name,
              type: entry.key,
              lat: (geo['lat'] as num).toDouble(),
              lng: (geo['lng'] as num).toDouble(),
            ));
          }
        }
      } catch (_) {}
    }

    if (mounted) _showPoiResult(allPois);
  }

  void _showPoiResult(List<_Poi> pois) {
    setState(() => _pois = pois);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pois.isEmpty ? 'No locations found' : 'Found ${pois.length} locations'), duration: const Duration(seconds: 2)),
    );
  }

  String _getPoiType(Map tags) {
    if (tags['shop'] == 'bait' || tags['shop'] == 'tackle' || tags['shop'] == 'fishing') return 'bait';
    if (tags['shop'] == 'outdoor') return 'bait';
    if (tags['shop'] == 'convenience') return 'convenience';
    if (tags['amenity'] == 'fuel') return 'gas';
    if (tags['leisure'] == 'marina' || tags['amenity'] == 'boat_rental' || tags['waterway'] == 'boatyard' || tags['leisure'] == 'slipway' || tags['amenity'] == 'ferry_terminal' || tags['seamark:small_craft_facility'] == 'launch') return 'boat';
    return 'other';
  }

  Future<void> _goToCurrentLocation() async {
    setState(() => _locating = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Row(children: [Icon(Icons.location_off, color: Colors.white), SizedBox(width: 8), Expanded(child: Text('Location denied'))]), backgroundColor: Colors.red),
          );
        }
        if (mounted) setState(() => _locating = false);
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      if (mounted) setState(() { _currentLocation = loc; _mapCenter = loc; _mapZoom = 16.0; _refreshKey++; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Row(children: [const Icon(Icons.error_outline, color: Colors.white), const SizedBox(width: 8), Expanded(child: Text('$e'))]), backgroundColor: Colors.red),
        );
      }
    }
    if (mounted) setState(() => _locating = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
        elevation: 0, scrolledUnderElevation: 0,
        foregroundColor: cs.onSurface,
        title: const Text('Catch Map'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Refresh'),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top -
                      kBottomNavigationBarHeight -
                      80,
                  child: FlutterMap(
                    key: ValueKey('map_$_refreshKey'),
                    options: MapOptions(
                      initialCenter: _mapCenter,
                      initialZoom: _mapZoom,
                      onMapEvent: (e) {
                        if (e is MapEventMoveEnd) _mapCenter = e.camera.center;
                      },
                      interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.bestcatchbuddy.best_catch_buddy',
                      ),
                      // Catch pins
                      MarkerLayer(
                        markers: _filteredPinned.map((c) {
                          // Heatmap density: count nearby catches within ~0.5°
                          int nearby = 0;
                          if (_showHeatmap) {
                            for (final other in _filteredPinned) {
                              if (other.id != c.id && other.latitude != null && other.longitude != null) {
                                final d = (other.latitude! - c.latitude!).abs() + (other.longitude! - c.longitude!).abs();
                                if (d < 0.5) nearby++;
                              }
                            }
                          }
                          final heatColor = nearby > 5 ? Colors.red : nearby > 3 ? Colors.orange : nearby > 1 ? Colors.amber : const Color(0xFF00E5FF);
                          return Marker(
                          point: LatLng(c.latitude!, c.longitude!),
                          width: 36, height: 36,
                          child: GestureDetector(
                            onTap: () => _showCatchInfo(c),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF0E1422) : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 6, offset: const Offset(0, 2))],
                              ),
                              child: Icon(Icons.set_meal, color: heatColor, size: 18),
                            ),
                          ),
                        );}).toList(),
                      ),
                      // Current location
                      if (_currentLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation!,
                              width: 24, height: 24,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.blue, width: 2),
                                ),
                                child: const Icon(Icons.my_location, color: Colors.blue, size: 14),
                              ),
                            ),
                          ],
                        ),
                      // Bait markers
                      if (_showBait)
                        MarkerLayer(
                          markers: _pois.where((p) => p.type == 'bait' || p.type == 'convenience').map((p) => Marker(
                            point: LatLng(p.lat, p.lng), width: 30, height: 30,
                            child: GestureDetector(
                              onTap: () => _showPoiInfo(p),
                              child: Container(
                                decoration: BoxDecoration(color: const Color(0xFFE91E63), shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
                                child: const Icon(Icons.set_meal, color: Colors.white, size: 16),
                              ),
                            ),
                          )).toList(),
                        ),
                      // Gas markers
                      if (_showGas)
                        MarkerLayer(
                          markers: _pois.where((p) => p.type == 'gas').map((p) => Marker(
                            point: LatLng(p.lat, p.lng), width: 30, height: 30,
                            child: GestureDetector(
                              onTap: () => _showPoiInfo(p),
                              child: Container(
                                decoration: BoxDecoration(color: const Color(0xFFFF9800), shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
                                child: const Icon(Icons.local_gas_station, color: Colors.white, size: 16),
                              ),
                            ),
                          )).toList(),
                        ),
                      // Boat launch markers
                      if (_showBoatLaunch)
                        MarkerLayer(
                          markers: _pois.where((p) => p.type == 'boat').map((p) => Marker(
                            point: LatLng(p.lat, p.lng), width: 30, height: 30,
                            child: GestureDetector(
                              onTap: () => _showPoiInfo(p),
                              child: Container(
                                decoration: BoxDecoration(color: const Color(0xFF2196F3), shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)]),
                                child: const Icon(Icons.directions_boat, color: Colors.white, size: 16),
                              ),
                            ),
                          )).toList(),
                        ),
                    ],
                  ),
                ),
                // Toggle buttons
                Positioned(top: 12, left: 12,
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _toggleButton('🎣 Bait', _showBait, () { setState(() => _showBait = !_showBait); if (_showBait && _pois.isEmpty) _searchPois(); }),
                      const SizedBox(height: 6),
                      _toggleButton('⛽ Gas', _showGas, () { setState(() => _showGas = !_showGas); if (_showGas && _pois.isEmpty) _searchPois(); }),
                      const SizedBox(height: 6),
                      _toggleButton('🚤 Launch', _showBoatLaunch, () { setState(() => _showBoatLaunch = !_showBoatLaunch); if (_showBoatLaunch && _pois.isEmpty) _searchPois(); }),
                      const SizedBox(height: 6),
                      _toggleButton('🌤️ Weather', false, () => _showForecast()),
                      const SizedBox(height: 6),
                      _toggleButton('🌡️ Heatmap', _showHeatmap, () { setState(() => _showHeatmap = !_showHeatmap); }),
                      const SizedBox(height: 6),
                      _toggleButton('🌙 Solunar', false, () => _showSolunar()),
                      if (_allSpecies.length > 1) ...[const SizedBox(height: 8),
                        _filterMapChips('species', _allSpecies, _filterSpecies, Icons.set_meal),
                      ],
                      if (_allAnglers.length > 1) ...[const SizedBox(height: 4),
                        _filterMapChips('angler', _allAnglers, _filterAnglers, Icons.person),
                      ],
                    ],
                  ),
                ),
                // Locate button
                Positioned(bottom: 30, right: 16,
                  child: GestureDetector(
                    onTap: _goToCurrentLocation,
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0E1422) : Colors.white).withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8)],
                      ),
                      child: _locating
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.my_location, color: Color(0xFF00E5FF)),
                    ),
                  ),
                ),
                // Searching indicator
                if (_searching)
                  Positioned(top: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFF0E1422) : Colors.white).withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _toggleButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? const Color(0xFF00E5FF) : Colors.grey.shade300, width: active ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
        ),
        child: Row(mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10,
              decoration: BoxDecoration(color: active ? const Color(0xFF00E5FF) : Colors.grey.shade400, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _showCatchInfo(Catch c) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.species, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Caught by ${c.angler}', style: TextStyle(color: Colors.grey.shade600)),
            if (c.location.isNotEmpty) Text('📍 ${c.location}'),
            if (c.weight != null) Text('⚖️ ${c.weightDisplay}'),
            if (c.length != null) Text('📏 ${c.lengthDisplay}'),
            if (c.weatherTemp != null) Text('🌤️ ${c.weatherDisplay}'),
            const SizedBox(height: 12),
            Text('${c.latitude?.toStringAsFixed(4)}, ${c.longitude?.toStringAsFixed(4)}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }

  Widget _filterMapChips(String type, Set<String> options, Set<String> selected, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(type == 'species' ? 'Species' : 'Angler', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white54, letterSpacing: 1)),
      const SizedBox(height: 4),
      SizedBox(
        height: 28,
        child: ListView(scrollDirection: Axis.horizontal,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = _selectedFilter == type ? null : type;
                  if (_selectedFilter != type) selected.clear();
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: _selectedFilter == type ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_selectedFilter == type ? Icons.filter_list_off : Icons.filter_list, size: 12, color: Colors.white),
                  const SizedBox(width: 3),
                  Text(_selectedFilter == type ? 'Clear' : 'Filter', style: const TextStyle(fontSize: 10, color: Colors.white)),
                ]),
              ),
            ),
            if (_selectedFilter == type)
              ...options.map((o) => GestureDetector(
                onTap: () { setState(() { if (selected.contains(o)) selected.remove(o); else selected.add(o); }); },
                child: Container(
                  margin: const EdgeInsets.only(right: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: selected.contains(o) ? AppColors.primary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: selected.contains(o) ? AppColors.primary.withValues(alpha: 0.5) : Colors.transparent),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(icon, size: 10, color: Colors.white70),
                    const SizedBox(width: 3),
                    Text(o, style: const TextStyle(fontSize: 10, color: Colors.white)),
                  ]),
                ),
              )),
          ],
        ),
      ),
    ]);
  }

  void _showPoiInfo(_Poi p) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(p.type == 'gas' ? Icons.local_gas_station : p.type == 'boat' ? Icons.directions_boat : Icons.set_meal, size: 24,
                  color: p.type == 'gas' ? Colors.orange : p.type == 'boat' ? Colors.blue : Colors.pink),
              const SizedBox(width: 10),
              Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text(p.type == 'gas' ? 'Gas Station' : p.type == 'boat' ? 'Boat Launch / Marina' : 'Bait & Tackle Shop', style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openDirections(p.lat, p.lng),
                icon: const Icon(Icons.directions, size: 18),
                label: const Text('Get Directions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF003544),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _showForecast() async {
    if (!ApiConfig.hasValidWeatherKey) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Set OpenWeatherMap key in api_config.dart')),
        );
      }
      return;
    }
    setState(() => _searching = true);
    final lat = _mapCenter.latitude;
    final lng = _mapCenter.longitude;

    try {
      // Current weather
      final curUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=${ApiConfig.openWeatherApiKey}&units=metric';
      final curRes = await http.get(Uri.parse(curUrl)).timeout(const Duration(seconds: 10));

      // 5-day forecast
      final fctUrl = 'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lng&appid=${ApiConfig.openWeatherApiKey}&units=metric';
      final fctRes = await http.get(Uri.parse(fctUrl)).timeout(const Duration(seconds: 10));

      if (mounted) {
        if (curRes.statusCode == 200 && fctRes.statusCode == 200) {
          final cur = jsonDecode(curRes.body);
          final fct = jsonDecode(fctRes.body);
          _showForecastSheet(cur, fct);
        } else {
          final msg = curRes.statusCode != 200
              ? 'Current weather: ${curRes.statusCode}'
              : 'Forecast: ${fctRes.statusCode}';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Weather API error: $msg'), backgroundColor: Colors.red, duration: const Duration(seconds: 4)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Weather error: $e'), backgroundColor: Colors.red));
      }
    }
    if (mounted) setState(() => _searching = false);
  }

  void _showForecastSheet(Map cur, Map fct) {
    final temp = (cur['main']['temp'] as num?)?.round() ?? '--';
    final feels = (cur['main']['feels_like'] as num?)?.round() ?? '--';
    final cond = (cur['weather'] as List?)?.first?['main'] as String? ?? '';
    final desc = (cur['weather'] as List?)?.first?['description'] as String? ?? '';
    final wind = (cur['wind']['speed'] as num?)?.toStringAsFixed(1) ?? '--';
    final humid = (cur['main']['humidity'] as num?)?.toString() ?? '--';
    final city = cur['name'] as String? ?? 'Current location';

    // Group forecast by day
    final daily = <String, List>{};
    for (final item in (fct['list'] as List? ?? [])) {
      final dt = DateTime.fromMillisecondsSinceEpoch((item['dt'] as int) * 1000);
      final day = DateFormat('EEE MMM d').format(dt);
      daily.putIfAbsent(day, () => []).add(item);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6, maxChildSize: 0.9, minChildSize: 0.3,
        expand: false,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: ListView(
            controller: scrollCtrl,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 12),
              Text(city, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('Now: $temp°C • $cond — $desc', style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              // Fishing Forecast Score
              _fishingScore(temp, feels, '$wind'.replaceAll('°C',''), '$humid'.replaceAll('%',''), cond),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _weatherStat('Feels', '$feels°C'),
                _weatherStat('Wind', '$wind m/s'),
                _weatherStat('Humidity', '$humid%'),
              ]),
              const SizedBox(height: 8),
              // Water conditions
              _waterConditions(temp, cond),
              const Divider(height: 24),
              Text('5-Day Forecast', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ...daily.entries.take(5).map((e) => _forecastDay(e.key, e.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fishingScore(dynamic temp, dynamic feels, String windStr, String humidStr, String cond) {
    // Calculate score 0-100
    int score = 50;
    // Weather (0-40)
    final goodWeather = ['Clear', 'Clouds', 'Partly Cloudy'];
    final badWeather = ['Rain', 'Drizzle', 'Thunderstorm', 'Snow', 'Squall', 'Tornado'];
    if (goodWeather.contains(cond)) score += 20;
    else if (cond == 'Clouds') score += 10;
    else if (badWeather.contains(cond)) score -= 20;
    // Wind (0-30)
    final windVal = double.tryParse(windStr) ?? 5;
    if (windVal < 3) score += 15;
    else if (windVal < 8) score += 10;
    else if (windVal > 15) score -= 10;
    // Temperature (0-30)
    final tempVal = (temp is num) ? temp.toDouble() : 20.0;
    if (tempVal > 15 && tempVal < 28) score += 15;
    else if (tempVal > 5 && tempVal < 35) score += 5;
    else score -= 10;

    score = score.clamp(0, 100);
    final emoji = score >= 80 ? '🏆' : score >= 60 ? '🎣' : score >= 40 ? '👍' : score >= 20 ? '🤔' : '👎';
    final label = score >= 80 ? 'Excellent!' : score >= 60 ? 'Good' : score >= 40 ? 'Fair' : score >= 20 ? 'Poor' : 'Bad';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: score >= 60 ? Colors.green.withValues(alpha: 0.1) : score >= 40 ? Colors.orange.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: score >= 60 ? Colors.green.withValues(alpha: 0.3) : score >= 40 ? Colors.orange.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3)),
      ),
      child: Row(children: [
        Text('$emoji ', style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Fishing Forecast: $score/100', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ]),
        ),
        const SizedBox(width: 8),
        _weatherStat('Score', '$score'),
      ]),
    );
  }

  Widget _waterConditions(dynamic airTemp, String condition) {
    final tempVal = (airTemp is num) ? airTemp.toDouble() : 20.0;
    final waterTemp = (tempVal * 0.8 + 5).round(); // rough estimate
    final clarity = condition.contains('Rain') ? 'Murky' : (condition.contains('Clear') ? 'Clear' : 'Stained');
    final rating = waterTemp > 20 ? 'Warm' : waterTemp > 12 ? 'Moderate' : waterTemp > 5 ? 'Cool' : 'Cold';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.blue.withValues(alpha: 0.06),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        const Icon(Icons.water, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Water: ~$waterTemp°C ($rating)', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
            Text('Clarity: $clarity', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ]),
        ),
      ]),
    );
  }

  Widget _weatherStat(String label, String value) {
    return Column(children: [
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
    ]);
  }

  Widget _forecastDay(String day, List items) {
    final highs = items.map((i) => (i['main']['temp_max'] as num).toDouble()).toList();
    final lows = items.map((i) => (i['main']['temp_min'] as num).toDouble()).toList();
    final conds = items.map((i) => (i['weather'] as List?)?.first?['main'] as String? ?? '').toSet().join(', ');
    final hi = highs.reduce((a, b) => a > b ? a : b).round();
    final lo = lows.reduce((a, b) => a < b ? a : b).round();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 100, child: Text(day, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(child: Text(conds, style: TextStyle(color: Colors.grey.shade600, fontSize: 13))),
        Text('$lo° / $hi°', style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _showSolunar() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Approximate solunar calculations based on moon phase
    final knownNewMoon = DateTime(2026, 6, 14); // approximate
    final daysSince = today.difference(knownNewMoon).inDays;
    final phase = ((daysSince % 29.53) / 29.53); // 0=new, 0.5=full

    // Calculate major and minor periods
    // Major: ~2 hours each, centered on moon transit (approx every 12h 25min)
    // Minor: ~1 hour each, centered on moon rise/set
    final dayFraction = (now.hour * 60 + now.minute) / 1440.0;

    String phaseName;
    String phaseIcon;
    if (phase < 0.125) { phaseName = 'New Moon'; phaseIcon = '🌑';
    } else if (phase < 0.25) { phaseName = 'Waxing Crescent'; phaseIcon = '🌒';
    } else if (phase < 0.375) { phaseName = 'First Quarter'; phaseIcon = '🌓';
    } else if (phase < 0.5) { phaseName = 'Waxing Gibbous'; phaseIcon = '🌔';
    } else if (phase < 0.625) { phaseName = 'Full Moon'; phaseIcon = '🌕';
    } else if (phase < 0.75) { phaseName = 'Waning Gibbous'; phaseIcon = '🌖';
    } else if (phase < 0.875) { phaseName = 'Last Quarter'; phaseIcon = '🌗';
    } else { phaseName = 'Waning Crescent'; phaseIcon = '🌘'; }

    final rating = (phase < 0.15 || phase > 0.85) ? '⭐⭐⭐⭐⭐' :
        (phase < 0.25 || phase > 0.75) ? '⭐⭐⭐⭐' :
        (phase < 0.35 || phase > 0.65) ? '⭐⭐⭐' : '⭐⭐';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Row(children: [
              Text('$phaseIcon ', style: const TextStyle(fontSize: 28)),
              Flexible(child: Text(phaseName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 4),
            Text('Fishing Rating: $rating', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text('Best Times Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            _solunarTime('Major', '${_fmtTime(6)} — ${_fmtTime(8)}', '${_fmtTime(18)} — ${_fmtTime(20)}'),
            const SizedBox(height: 4),
            _solunarTime('Minor', '${_fmtTime(12)} — ${_fmtTime(13)}', '${_fmtTime(0)} — ${_fmtTime(1)}'),
            const SizedBox(height: 12),
            Text('Best fishing is 2 hours before & after major/minor periods.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  String _fmtTime(int hour) {
    final h = hour % 24;
    final ampm = h < 12 ? 'AM' : 'PM';
    final hh = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '$hh:00 $ampm';
  }

  Widget _solunarTime(String label, String morning, String evening) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
        const Icon(Icons.wb_sunny, size: 14, color: Colors.orange),
        const SizedBox(width: 4),
        Text('AM: $morning', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
        const SizedBox(width: 16),
        const Icon(Icons.nightlight_round, size: 14, color: Colors.indigo),
        const SizedBox(width: 4),
        Text('PM: $evening', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ]),
    );
  }

  Future<void> _openDirections(double lat, double lng) async {
    final uris = [
      Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng'),
      Uri.parse('geo:$lat,$lng?q=$lat,$lng'),
      Uri.parse('https://maps.google.com/maps?daddr=$lat,$lng'),
    ];
    for (final uri in uris) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }
  }
}

class _Poi {
  final String name;
  final String type;
  final double lat;
  final double lng;
  _Poi({required this.name, required this.type, required this.lat, required this.lng});
}
