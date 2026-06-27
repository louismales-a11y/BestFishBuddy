import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:latlong2/latlong.dart';
import '../models/catch.dart';
import '../models/fish_species.dart' show fishingRegions, northAmericaSubRegions, speciesForRegion;
import '../services/database_service.dart';
import '../services/firebase_sync.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_config.dart';
import '../main.dart';
import '../widgets/location_picker.dart';

class AddCatchScreen extends StatefulWidget {
  final Catch? existingCatch;

  const AddCatchScreen({super.key, this.existingCatch});

  @override
  State<AddCatchScreen> createState() => _AddCatchScreenState();
}

class _AddCatchScreenState extends State<AddCatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _anglerCtrl = TextEditingController();
  List<String> _knownAnglers = [];
  bool _showAnglerSuggestions = false;
  final _anglerFocusNode = FocusNode();
  final _locationCtrl = TextEditingController();
  final _lureCtrl = TextEditingController();
  final _tripCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _shareCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _lengthCtrl = TextEditingController();
  String _selectedRegion = '🌍 All Regions';
  String _selectedSubRegion = 'Canada';
  String _speciesName = '';
  final _speciesFocusNode = FocusNode();
  String _weightUnit = 'kg';
  String _lengthUnit = 'cm';
  double? _latitude;
  double? _longitude;
  DateTime _caughtAt = DateTime.now();
  final List<File> _photoFiles = [];
  bool _saving = false;

  static const _maxPhotos = 3;

  @override
  void initState() {
    super.initState();
    _loadKnownAnglers();
    _anglerFocusNode.addListener(() {
      if (_anglerFocusNode.hasFocus && _knownAnglers.isNotEmpty) {
        setState(() => _showAnglerSuggestions = true);
      } else {
        setState(() => _showAnglerSuggestions = false);
      }
    });
    final existing = widget.existingCatch;
    if (existing != null) {
      _anglerCtrl.text = existing.angler;
      _saveAnglerToPrefs(existing.angler);
      _speciesName = existing.species;
      _locationCtrl.text = existing.location;
      _lureCtrl.text = existing.lure;
      if (existing.tripName != null) _tripCtrl.text = existing.tripName!;
      if (existing.notes != null) _notesCtrl.text = existing.notes!;
      if (existing.weight != null) _weightCtrl.text = existing.weight.toString();
      _weightUnit = existing.weightUnit;
      if (existing.length != null) _lengthCtrl.text = existing.length.toString();
      _lengthUnit = existing.lengthUnit;
      _latitude = existing.latitude;
      _longitude = existing.longitude;
      _caughtAt = existing.caughtAt;
      if (existing.hasPhotos) {
        for (final p in existing.photoPaths!) {
          final f = File(p);
          if (f.existsSync()) {
            _photoFiles.add(f);
          }
        }
      }
    }
  }

  Future<void> _loadKnownAnglers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('known_anglers') ?? [];
    if (mounted) setState(() => _knownAnglers = list);
  }

  Future<void> _saveAnglerToPrefs(String name) async {
    if (name.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    final list = (prefs.getStringList('known_anglers') ?? []);
    if (!list.contains(name)) {
      list.add(name);
      await prefs.setStringList('known_anglers', list);
    }
    if (mounted) setState(() => _knownAnglers = list);
  }

  @override
  void dispose() {
    _anglerCtrl.dispose();
    _anglerFocusNode.dispose();
    _locationCtrl.dispose();
    _lureCtrl.dispose();
    _tripCtrl.dispose();
    _notesCtrl.dispose();
    _shareCtrl.dispose();
    _weightCtrl.dispose();
    _lengthCtrl.dispose();
    _speciesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    if (_photoFiles.length >= _maxPhotos) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maximum 3 photos allowed')),
        );
      }
      return;
    }
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, maxWidth: 1024);
    if (picked != null) {
      setState(() => _photoFiles.add(File(picked.path)));
    }
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _caughtAt,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(
                primary: AppColors.primary,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_caughtAt),
        builder: (context, child) => Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        ),
      );
      if (time != null) {
        setState(() {
          _caughtAt = DateTime(
            date.year, date.month, date.day,
            time.hour, time.minute,
          );
        });
      }
    }
  }

  Future<String> _savePhoto(File photo, int index) async {
    final appDir = await getApplicationDocumentsDirectory();
    final catchDir = Directory('${appDir.path}/catch_photos');
    if (!await catchDir.exists()) {
      await catchDir.create(recursive: true);
    }
    final ext = photo.path.split('.').last;
    final fileName = 'catch_${DateTime.now().millisecondsSinceEpoch}_$index.$ext';
    final savedFile = File('${catchDir.path}/$fileName');
    await photo.copy(savedFile.path);
    return savedFile.path;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      List<String>? savedPaths;
      if (_photoFiles.isNotEmpty) {
        savedPaths = [];
        for (var i = 0; i < _photoFiles.length; i++) {
          final path = await _savePhoto(_photoFiles[i], i);
          savedPaths.add(path);
        }
      }

      final weight = double.tryParse(_weightCtrl.text.trim());
      final length = double.tryParse(_lengthCtrl.text.trim());

      // Auto-fetch weather if coordinates are set
      double? wt; String? wc; String? wi;
      if (_latitude != null && _longitude != null && ApiConfig.hasValidWeatherKey) {
        try {
          final wUrl = 'https://api.openweathermap.org/data/2.5/weather?lat=$_latitude&lon=$_longitude&appid=${ApiConfig.openWeatherApiKey}&units=metric';
          final wRes = await http.get(Uri.parse(wUrl)).timeout(const Duration(seconds: 10));
          if (wRes.statusCode == 200) {
            final wd = jsonDecode(wRes.body);
            wt = (wd['main']['temp'] as num?)?.toDouble();
            wc = (wd['weather'] as List?)?.firstOrNull?['main'] as String?;
            wi = (wd['weather'] as List?)?.firstOrNull?['icon'] as String?;
          }
        } catch (_) {}
      }

      final existing = widget.existingCatch;
      final catchItem = Catch(
        id: existing?.id,
        angler: _anglerCtrl.text.trim(),
        species: _speciesName.trim(),
        location: _locationCtrl.text.trim(),
        lure: _lureCtrl.text.trim(),
        tripName: _tripCtrl.text.trim().isNotEmpty ? _tripCtrl.text.trim() : null,
        notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        photoPaths: savedPaths ?? existing?.photoPaths,
        weight: weight,
        weightUnit: _weightUnit,
        length: length,
        lengthUnit: _lengthUnit,
        latitude: _latitude,
        longitude: _longitude,
        weatherTemp: wt ?? existing?.weatherTemp,
        weatherCondition: wc ?? existing?.weatherCondition,
        weatherIcon: wi ?? existing?.weatherIcon,
        caughtAt: _caughtAt,
      );

      // Upload to cloud sync
      try {
        final shareEmail = _shareCtrl.text.trim();
        await FirebaseSyncService.instance.uploadCatch(catchItem, shareWithEmail: shareEmail.isNotEmpty ? shareEmail : null);
      } catch (_) {}

      _saveAnglerToPrefs(_anglerCtrl.text.trim());

      if (existing != null) {
        await DatabaseService.instance.updateCatch(catchItem);
      } else {
        await DatabaseService.instance.addCatch(catchItem);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error saving: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingCatch != null;
    final dateStr = DateFormat('MMM d, yyyy  h:mm a').format(_caughtAt);
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Catch' : 'Add Catch')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Photo Picker (up to 3) ─────────────────────────────────────────
            Column(
              children: [
                // Photo grid
                Row(
                  children: [
                    for (var i = 0; i < _maxPhotos; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: i < _photoFiles.length
                              ? () => _showPhotoOptions(index: i)
                              : _photoFiles.length < _maxPhotos
                                  ? () => _showPhotoOptions()
                                  : null,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: i < _photoFiles.length
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : Colors.grey.shade300,
                                width: i < _photoFiles.length ? 2 : 1,
                              ),
                              color: i < _photoFiles.length
                                  ? null
                                  : Colors.grey.shade100,
                              image: i < _photoFiles.length
                                  ? DecorationImage(
                                      image: FileImage(_photoFiles[i]),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: i < _photoFiles.length
                                ? Stack(
                                    children: [
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () => setState(() => _photoFiles.removeAt(i)),
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 4,
                                        left: 4,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            '${i + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        _photoFiles.isEmpty && i == 0
                                            ? Icons.camera_alt_outlined
                                            : Icons.add_photo_alternate_outlined,
                                        size: 24,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        i == 0 ? 'Add Photo' : 'Photo ${i + 1}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${_photoFiles.length} / $_maxPhotos photos',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── Angler ────────────────────────────────────────────────────────
            TextFormField(
              controller: _anglerCtrl,
              focusNode: _anglerFocusNode,
              decoration: InputDecoration(
                labelText: 'Angler *',
                hintText: 'Who caught it?',
                prefixIcon: const Icon(Icons.person),
                suffixIcon: _knownAnglers.isNotEmpty
                    ? Icon(Icons.arrow_drop_down, color: Colors.grey.shade400)
                    : null,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() => _showAnglerSuggestions = true),
            ),
            // Angler suggestions
            if (_showAnglerSuggestions && _knownAnglers.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF161C2E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: Text('PREVIOUS ANGLERS', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                    Wrap(
                      spacing: 6, runSpacing: 4,
                      children: _knownAnglers.where((a) => a.toLowerCase().contains(_anglerCtrl.text.toLowerCase())).map((a) =>
                        GestureDetector(
                          onTap: () { _anglerCtrl.text = a; setState(() => _showAnglerSuggestions = false); },
                          child: Chip(
                            label: Text(a, style: const TextStyle(fontSize: 13)),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ).toList(),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // ── Region Selector ────────────────────────────────────────────────
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: const InputDecoration(
                labelText: 'Region',
                prefixIcon: Icon(Icons.public),
                helperText: 'Filters species list',
              ),
              items: fishingRegions.map((r) {
                return DropdownMenuItem(value: r, child: Text(r));
              }).toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() {
                    _selectedRegion = v;
                    _selectedSubRegion = 'Canada';
                  });
                }
              },
            ),
            const SizedBox(height: 14),

            // ── Sub-Region (North America only) ─────────────────────────────────
            if (_selectedRegion == '🌎 North America')
              DropdownButtonFormField<String>(
                value: _selectedSubRegion,
                decoration: const InputDecoration(
                  labelText: 'Country',
                  prefixIcon: Icon(Icons.flag),
                ),
                items: northAmericaSubRegions.map((r) {
                  return DropdownMenuItem(value: r, child: Text(r));
                }).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedSubRegion = v);
                },
              ),
            if (_selectedRegion == '🌎 North America') const SizedBox(height: 14),

            // ── Species (Autocomplete + free-text) ────────────────────────────
            Autocomplete<String>(
              optionsBuilder: (textEditingValue) {
                // Use sub-region for North America, otherwise use main region
                final effectiveRegion = _selectedRegion == '🌎 North America'
                    ? _selectedSubRegion
                    : _selectedRegion;
                final speciesList = speciesForRegion(effectiveRegion);
                if (textEditingValue.text.isEmpty) {
                  return speciesList;
                }
                final query = textEditingValue.text.toLowerCase();
                return speciesList.where(
                  (species) => species.toLowerCase().contains(query),
                );
              },
              onSelected: (selection) {
                setState(() => _speciesName = selection);
              },
              fieldViewBuilder: (context, controller, focusNode, onSubmit) {
                // Set initial value from state
                if (controller.text != _speciesName && _speciesName.isNotEmpty) {
                  controller.text = _speciesName;
                }
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: 'Species *',
                    hintText: 'Search or type any species',
                    prefixIcon: Icon(Icons.emoji_nature),
                    helperText: 'Select from list or type your own',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  textCapitalization: TextCapitalization.words,
                  onFieldSubmitted: (_) => onSubmit(),
                  onChanged: (v) => _speciesName = v,
                );
              },
              displayStringForOption: (option) => option,
              optionsViewBuilder: (context, onSelected, options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    constraints: const BoxConstraints(maxHeight: 280),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A3E)
                          : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        final isSelected = option == _speciesName;
                        return ListTile(
                          dense: true,
                          selected: isSelected,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: Icon(
                            Icons.emoji_nature,
                            size: 20,
                            color: isSelected ? AppColors.primary : Colors.grey,
                          ),
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              color: isSelected ? AppColors.primary : null,
                            ),
                          ),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),

            // ── Location ──────────────────────────────────────────────────────
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                labelText: 'Location',
                hintText: 'Where was it caught?',
                prefixIcon: Icon(Icons.location_on),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // ── Lure ──────────────────────────────────────────────────────────
            TextFormField(
              controller: _lureCtrl,
              decoration: const InputDecoration(
                labelText: 'Lure / Bait',
                hintText: 'What did you use?',
                prefixIcon: Icon(Icons.vpn_key),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),

            // ── Trip Name ───────────────────────────────────────────────────────
            TextFormField(
              controller: _tripCtrl,
              decoration: const InputDecoration(
                labelText: 'Trip Name',
                hintText: 'e.g. Lake Simcoe Weekend',
                prefixIcon: Icon(Icons.directions_boat),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 14),

            // ── Notes ─────────────────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Weather, conditions, technique...',
                prefixIcon: Icon(Icons.notes),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 14),

            // ── Share with friend ──────────────────────────────────────────────
            if (FirebaseSyncService.instance.isLoggedIn)
              TextFormField(
                controller: _shareCtrl,
                decoration: const InputDecoration(
                  labelText: 'Share with friend',
                  hintText: 'Enter their email',
                  prefixIcon: Icon(Icons.person_add),
                  helperText: 'They\'ll see this catch in their app',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            if (FirebaseSyncService.instance.isLoggedIn) const SizedBox(height: 14),

            // ── Weight ────────────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      hintText: 'e.g. 2.5',
                      prefixIcon: Icon(Icons.monitor_weight),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A3E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      _unitChip('kg', _weightUnit, (v) => setState(() => _weightUnit = v)),
                      _unitChip('lbs', _weightUnit, (v) => setState(() => _weightUnit = v)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Length / Size ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lengthCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Length',
                      hintText: 'e.g. 45',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A3E)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      _lengthUnitChip('cm'),
                      _lengthUnitChip('in'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ── Date & Time ───────────────────────────────────────────────────
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date & Time',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  dateStr,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // ── Save Button ───────────────────────────────────────────────────
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_saving
                    ? 'Saving...'
                    : (widget.existingCatch != null ? 'Update Catch' : 'Save Catch')),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _unitChip(String unit, String current, ValueChanged<String> onChanged) {
    final selected = current == unit;
    return GestureDetector(
      onTap: () => onChanged(unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.push<LatLng>(
      context,
      MaterialPageRoute(
        builder: (_) => LocationPicker(
          initialLat: _latitude,
          initialLng: _longitude,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        _latitude = result.latitude;
        _longitude = result.longitude;
      });
    }
  }

  Widget _lengthUnitChip(String unit) {
    final selected = _lengthUnit == unit;
    return GestureDetector(
      onTap: () => setState(() => _lengthUnit = unit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          unit,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions({int? index}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                index != null ? 'Change Photo ${index + 1}' : 'Add Photo',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_outlined, color: AppColors.primary),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_outlined, color: AppColors.secondary),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick an existing photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickPhoto(ImageSource.gallery);
                },
              ),
              if (index != null && index < _photoFiles.length) ...[const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.delete_outline, color: AppColors.error),
                  ),
                  title: Text('Remove Photo', style: TextStyle(color: AppColors.error)),
                  subtitle: const Text('Delete this photo', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _photoFiles.removeAt(index!));
                  },
                ),],
            ],
          ),
        ),
      ),
    );
  }
}
