import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_sync.dart';
import '../services/database_service.dart';
import '../services/theme_provider.dart';
import '../main.dart';
import 'login_screen.dart';

class CloudSyncScreen extends StatefulWidget {
  const CloudSyncScreen({super.key});
  @override
  State<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends State<CloudSyncScreen> {
  int _cloudCatchCount = 0;
  int _localCatchCount = 0;
  bool _syncing = false;
  String? _syncResult;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final local = await DatabaseService.instance.getCatchCount();
      final cloud = await FirebaseSyncService.instance.fetchCloudCatches();
      if (mounted) {
        setState(() {
          _localCatchCount = local;
          _cloudCatchCount = cloud.length;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncNow() async {
    if (!FirebaseSyncService.instance.isLoggedIn) return;
    setState(() { _syncing = true; _syncResult = null; });

    try {
      final catches = await DatabaseService.instance.getCatches();
      int uploaded = 0;
      for (final c in catches) {
        await FirebaseSyncService.instance.uploadCatch(c);
        uploaded++;
      }
      await _loadStats();
      if (mounted) {
        setState(() {
          _syncResult = '✅ Synced $uploaded catches';
          _syncing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _syncResult = '❌ Sync error: $e';
          _syncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);
    final isLoggedIn = FirebaseSyncService.instance.isLoggedIn;
    final user = FirebaseSyncService.instance.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync'),
        actions: [
          if (isLoggedIn)
            IconButton(
              icon: const Icon(Icons.cloud_done, color: Colors.green),
              tooltip: 'Synced',
              onPressed: () {},
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).padding.bottom + 20),
        children: [
          // ── Header ──────────────────────────────────────────────
          Icon(
            isLoggedIn ? Icons.cloud_done : Icons.cloud_off,
            size: 72,
            color: isLoggedIn ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(
            isLoggedIn ? 'Cloud Sync Active' : 'Not Synced',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isLoggedIn ? Colors.green : Colors.grey,
            ),
          ),
          if (isLoggedIn && user != null) ...[
            const SizedBox(height: 4),
            Text(
              user.email ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
          const SizedBox(height: 24),

          // ── Stats Cards ──────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.phone_android,
                  label: 'Local',
                  value: '$_localCatchCount',
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.cloud,
                  label: 'Cloud',
                  value: '$_cloudCatchCount',
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Sync Info ────────────────────────────────────────────
          if (isLoggedIn) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sync Details',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const Divider(),
                    _SyncRow(icon: Icons.sync, label: 'Auto-sync', value: 'On save'),
                    _SyncRow(icon: Icons.wifi, label: 'Requires internet', value: 'Yes'),
                    _SyncRow(icon: Icons.people, label: 'Share with friends', value: 'Via email'),
                    _SyncRow(icon: Icons.photo_library, label: 'Photo backup', value: 'Firebase Storage'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Sync Now Button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _syncing ? null : _syncNow,
                icon: _syncing
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
                label: Text(_syncing ? 'Syncing...' : 'Sync Now'),
              ),
            ),
            if (_syncResult != null) ...[
              const SizedBox(height: 8),
              Text(_syncResult!, textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _syncResult!.startsWith('✅') ? Colors.green : Colors.red)),
            ],
            const SizedBox(height: 24),

            // ── Sign Out ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await FirebaseSyncService.instance.signOut();
                  if (mounted) {
                    setState(() { _cloudCatchCount = 0; _syncResult = null; });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Signed out of cloud sync')),
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Sign Out', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                ),
              ),
            ),
          ] else ...[
            // ── Not logged in ───────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Sync your catches across devices',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Back up to the cloud, share with friends, and never lose your fishing memories.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        icon: const Icon(Icons.cloud_sync),
                        label: const Text('Sign In to Cloud'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _SyncRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SyncRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 10),
          Flexible(child: Text(label, style: const TextStyle(fontSize: 14), overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Flexible(child: Text(value, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), overflow: TextOverflow.ellipsis, textAlign: TextAlign.end)),
        ],
      ),
    );
  }
}
