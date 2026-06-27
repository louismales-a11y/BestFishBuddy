import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/counter.dart';
import '../models/fish_species.dart' show allFishSpecies;
import '../services/database_service.dart';
import '../services/theme_provider.dart';
import '../main.dart';

class _StaggeredFadeSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const _StaggeredFadeSlide({super.key, required this.index, required this.child});

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

// ─── Angler Avatar Colors ─────────────────────────────────────────────────────
final _avatarColors = [
  AppColors.primary,
  AppColors.secondary,
  AppColors.tertiary,
  const Color(0xFF7B1FA2), // purple
  const Color(0xFFE64A19), // deep orange
  const Color(0xFF2E7D32), // green
  const Color(0xFF6A1B9A), // deep purple
  const Color(0xFF00838F), // cyan
];

Color _colorFor(String name) {
  final hash = name.codeUnits.fold(0, (prev, c) => prev + c);
  return _avatarColors[hash % _avatarColors.length];
}

class CounterScreen extends StatefulWidget {
  const CounterScreen({super.key});

  @override
  State<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  List<FishCounter> _counters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCounters();
  }

  Future<void> _loadCounters() async {
    setState(() => _loading = true);
    final counters = await DatabaseService.instance.getCounters();
    setState(() {
      _counters = counters;
      _loading = false;
    });
  }

  Future<void> _addAngler() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('Add Angler'),
          ],
        ),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Angler name',
            hintText: 'e.g. John',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) {
      await DatabaseService.instance.addCounter(name);
      _loadCounters();
    }
  }

  Future<void> _confirmDelete(FishCounter c) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_remove, color: AppColors.error, size: 24),
            const SizedBox(width: 8),
            Text('Delete Angler'),
          ],
        ),
        content: Text('Remove ${c.angler} from the counter?'),
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
      await DatabaseService.instance.deleteCounter(c.id!);
      _loadCounters();
    }
  }

  Future<void> _newTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_sweep, color: AppColors.tertiary, size: 24),
            const SizedBox(width: 8),
            Text('New Trip'),
          ],
        ),
        content: Text('Clear all anglers and start a new trip?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.tertiary,
              foregroundColor: Colors.black,
            ),
            child: Text('Start New Trip'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseService.instance.newTrip();
      _loadCounters();
    }
  }

  // ── Voice Command ──────────────────────────────────────────────────────────
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _continuousMode = false;

  void _toggleVoiceMode() {
    if (_isListening) {
      _stopListening();
    } else {
      _continuousMode = true;
      _startListening();
    }
  }

  void _stopListening() {
    _continuousMode = false;
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _startListening() async {
    final available = await _speech.initialize(
      onError: (error) {
        if (mounted) {
          setState(() => _isListening = false);
          _showVoiceFeedback('Speech error: ${error.errorMsg}');
        }
      },
    );
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.mic_off, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('Speech not available. Check microphone permissions.')),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }
    setState(() => _isListening = true);

    _speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase().trim();

        // Restart listening if silence/timeout in continuous mode
        if (text.isEmpty) {
          if (_continuousMode && result.finalResult) {
            _speech.stop();
            _resumeIfContinuous();
          }
          return;
        }

        // Try to match an angler name (full or partial)
        FishCounter? matched;
        int bestScore = 0;
        for (final c in _counters) {
          final name = c.angler.toLowerCase();
          // Exact match wins immediately
          if (text.contains(name)) {
            matched = c;
            bestScore = 999;
            break;
          }
          // Partial match: how many chars of the name appear in the text?
          int score = 0;
          for (var i = 0; i < name.length && i < text.length; i++) {
            if (text[i] == name[i]) score++;
          }
          // Also check if the name starts with any word in the text
          for (final word in text.split(' ')) {
            if (word.length >= 2 && name.startsWith(word)) {
              score = max(score, word.length * 2);
            }
            if (word.length >= 2 && word.startsWith(name.substring(0, min(3, name.length)))) {
              score = max(score, name.length);
            }
          }
          if (score > bestScore) {
            bestScore = score;
            matched = c;
          }
        }

        // Try to extract species from the spoken text
        String? species;
        final allSpecies = allFishSpecies;
        for (final s in allSpecies) {
          if (text.contains(s.toLowerCase())) {
            species = s;
            break;
          }
        }
        // Also check single words (e.g. "perch", "bass", "trout")
        if (species == null) {
          for (final word in text.split(' ')) {
            if (word.length > 2) {
              for (final s in allSpecies) {
                if (s.toLowerCase().contains(word) || word == s.toLowerCase().split(' ').first) {
                  species = s;
                  break;
                }
              }
            }
            if (species != null) break;
          }
        }

        // If we found a strong name match, increment & optionally log species
        if (matched != null && bestScore >= 3) {
          _logAndIncrement(matched, species);
          _speech.stop();
          _resumeIfContinuous();
          return;
        }

        // Generic fish command — requires a name mention, no default fallback
        if (text.contains('fish') || text.contains('catch') || text.contains('add')) {
          if (_counters.isNotEmpty) {
            if (matched != null && bestScore > 0) {
              _logAndIncrement(matched, species);
              _speech.stop();
              _resumeIfContinuous();
              return;
            }
            _showVoiceFeedback('Say a name like "${_counters.first.angler}"');
            _speech.stop();
            _resumeIfContinuous();
            return;
          }
        } else if (text.contains('reset') || text.contains('clear')) {
          _newTrip();
          _showVoiceFeedback('Counters reset! 🔄');
          _speech.stop();
          _resumeIfContinuous();
        }
      },
      listenFor: const Duration(days: 1),
      pauseFor: const Duration(seconds: 5),
      partialResults: false,
    );
  }

  void _resumeIfContinuous() {
    if (!_continuousMode || !mounted) return;
    // Wait a bit before re-listening to avoid rapid restarts
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (_continuousMode && mounted && !_speech.isListening) {
        _startListening();
      }
    });
  }

  void _showVoiceFeedback(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.record_voice_over, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(msg),
          ],
        ),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0E1422)
            : Colors.white,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _incrementAndRefresh(int id) async {
    await DatabaseService.instance.incrementCounter(id);
    _loadCounters();
  }

  Future<void> _logAndIncrement(FishCounter angler, String? species) async {
    // Vibrate + sound on fish detection
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);

    await DatabaseService.instance.incrementCounter(angler.id!);

    if (species != null) {
      await DatabaseService.instance.incrementVoiceSpecies(angler.angler, species);
      _showVoiceFeedback('${angler.angler} +1 $species! 🎣');
    } else {
      _showVoiceFeedback('${angler.angler} +1 fish! 🎣');
    }

    _loadCounters();
  }

  int get _totalCount => _counters.fold(0, (sum, c) => sum + c.count);

  @override
  Widget build(BuildContext context) {
    AppColors.applyPreset(context.read<ThemeProvider>().preset);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        title: SizedBox.shrink(),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCounters,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.delete_sweep),
            onPressed: _newTrip,
            tooltip: 'New Trip',
          ),
          // Voice activation pill button
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: GestureDetector(
              onTap: _toggleVoiceMode,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 36,
                constraints: const BoxConstraints(minWidth: 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: _isListening
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isListening
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.primary.withValues(alpha: 0.2),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      size: 16,
                      color: _isListening ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isListening ? 'ACTIVE' : 'VOICE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                        color: _isListening ? AppColors.primary : AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _counters.isEmpty
              ? _emptyState()
              : ReorderableListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 88),
                  itemCount: _counters.length + 1,
                  onReorder: (oldI, newI) {
                    if (oldI < _counters.length && newI <= _counters.length) {
                      setState(() {
                        final item = _counters.removeAt(oldI);
                        _counters.insert(newI > oldI ? newI - 1 : newI, item);
                      });
                    }
                  },
                  itemBuilder: (ctx, i) {
                    if (i == _counters.length) {
                      return Padding(
                        padding: EdgeInsets.zero,
                        key: const ValueKey('total'),
                        child: _totalRow(),
                      );
                    }
                    return _StaggeredFadeSlide(
                      key: ValueKey(_counters[i].id),
                      index: i,
                      child: _counterCard(_counters[i]),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAngler,
        child: Icon(Icons.person_add),
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
            'No anglers yet!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to add an angler',
            style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  // ─── Total Row ──────────────────────────────────────────────────────────────
  Widget _totalRow() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: SweepGradient(
            colors: [
              AppColors.tertiary.withValues(alpha: 0.2),
              AppColors.tertiary.withValues(alpha: 0.05),
              AppColors.primary.withValues(alpha: 0.08),
              AppColors.secondary.withValues(alpha: 0.08),
              AppColors.tertiary.withValues(alpha: 0.2),
            ],
          ),
          border: Border.all(
            color: AppColors.tertiary.withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.tertiary.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
              child: Icon(Icons.assessment, color: Colors.black, size: 26),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GRAND TOTAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.tertiary.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '$_totalCount fish',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── Counter Card ───────────────────────────────────────────────────────────
  Widget _counterCard(FishCounter c) {
    final avatarColor = _colorFor(c.angler);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showAnglerDetails(c),
        child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        child: Row(
          children: [
            // Colored avatar with gradient ring
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    avatarColor.withValues(alpha: 0.2),
                    avatarColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: avatarColor.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Center(
                child: Text(
                  c.angler.isNotEmpty ? c.angler[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: avatarColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    c.angler,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: avatarColor.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${c.count} fish',
                        style: TextStyle(
                          fontSize: 12,
                          color: avatarColor.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Count badge with glow
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    avatarColor.withValues(alpha: 0.15),
                    avatarColor.withValues(alpha: 0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: avatarColor.withValues(alpha: 0.25),
                  width: 1.0,
                ),
              ),
              child: Text(
                '${c.count}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: avatarColor,
                ),
              ),
            ),
            const SizedBox(width: 2),
            // Action buttons
            _smallIconButton(
              icon: Icons.remove_circle_outline,
              color: Colors.orange,
              onPressed: () async {
                await DatabaseService.instance.decrementCounter(c.id!);
                _loadCounters();
              },
            ),
            _smallIconButton(
              icon: Icons.add_circle,
              color: Colors.green.shade600,
              onPressed: () async {
                await DatabaseService.instance.incrementCounter(c.id!);
                _loadCounters();
              },
            ),
            _smallIconButton(
              icon: Icons.refresh,
              color: Colors.grey,
              onPressed: () async {
                await DatabaseService.instance.resetCounter(c.id!);
                _loadCounters();
              },
            ),
            _smallIconButton(
              icon: Icons.delete_outline,
              color: Colors.red.shade300,
              onPressed: () => _confirmDelete(c),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<void> _showAnglerDetails(FishCounter c) async {
    // Get species counts from voice tracking (not from catches)
    final speciesCounts = await DatabaseService.instance.getVoiceSpeciesCounts(c.angler);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: _colorFor(c.angler).withValues(alpha: 0.2),
              child: Text(c.angler[0].toUpperCase(), style: TextStyle(color: _colorFor(c.angler))),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(c.angler, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('${c.count} total fish', style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
        content: speciesCounts.isEmpty
            ? const Text("No species recorded yet.\nSay 'John caught a perch' to track by species.")
            : SizedBox(
                width: double.maxFinite,
                child: ListBody(
                  children: speciesCounts.entries.map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.set_meal, size: 18, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(child: Text(e.key, style: const TextStyle(fontSize: 15))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${e.value}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
      ),
    );
  }

  Widget _smallIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: color.withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}
