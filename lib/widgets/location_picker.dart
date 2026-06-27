import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';

/// Full-screen map to pick a location for a catch.
class LocationPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPicker({super.key, this.initialLat, this.initialLng});

  @override
  State<LocationPicker> createState() => _LocationPickerState();
}

class _LocationPickerState extends State<LocationPicker> {
  late LatLng _selected;

  @override
  void initState() {
    super.initState();
    if (widget.initialLat != null && widget.initialLng != null) {
      _selected = LatLng(widget.initialLat!, widget.initialLng!);
    } else {
      _selected = const LatLng(44.5, -78.0); // Default: central Ontario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Location'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, _selected),
            child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _selected,
          initialZoom: 8.0,
          onTap: (tapPos, latlng) {
            setState(() => _selected = latlng);
          },
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.bestcatchbuddy.best_catch_buddy',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _selected,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pop(context, _selected),
          icon: const Icon(Icons.check),
          label: const Text('Confirm Location'),
          backgroundColor: AppColors.primary,
          foregroundColor: const Color(0xFF003544),
        ),
      ),
    );
  }
}
