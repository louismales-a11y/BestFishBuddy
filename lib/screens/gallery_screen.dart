import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../models/catch.dart';
import '../services/database_service.dart';
import '../main.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});
  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<Catch> _catches = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final c = await DatabaseService.instance.getCatches();
    if (mounted) setState(() { _catches = c.where((c) => c.hasPhotos).toList(); _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Gallery'), actions: [
        IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _catches.isEmpty
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('No photos yet', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Add photos when logging catches', style: TextStyle(color: Colors.grey.shade600)),
                ]))
              : GridView.builder(
                  padding: const EdgeInsets.all(4),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, crossAxisSpacing: 4, mainAxisSpacing: 4),
                  itemCount: _catches.fold<int>(0, (sum, c) => sum + (c.photoPaths?.length ?? 0)),
                  itemBuilder: (ctx, i) {
                    int idx = 0;
                    for (final c in _catches) {
                      for (final path in c.photoPaths ?? []) {
                        if (idx == i) {
                          return GestureDetector(
                            onTap: () => _showPhoto(path, c),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(image: FileImage(File(path)), fit: BoxFit.cover),
                              ),
                            ),
                          );
                        }
                        idx++;
                      }
                    }
                    return const SizedBox();
                  },
                ),
    );
  }

  void _showPhoto(String path, Catch c) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Expanded(child: Image.file(File(path), fit: BoxFit.contain)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text('${c.species} — ${c.angler}', style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ]),
      ),
    );
  }
}
