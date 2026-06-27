import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_provider.dart';
import '../main.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    AppColors.applyPreset(tp.preset);
    final cs = Theme.of(context).colorScheme;
    final t = cs.onSurface.withValues(alpha: 0.65);

    return Scaffold(
      appBar: AppBar(title: const Text('How to Use')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Step 1
          _stepNumber(tp, '1'),
          const SizedBox(height: 4),
          _heading('Adding Anglers (Counter Tab)'),
          _body(t, 'The Counter tab is for tracking how many fish each person catches in real time — perfect for friendly competitions on the water.'),
          _bullet(t, 'Tap the COUNTER tab at the top, then tap the + button (bottom-right).'),
          _bullet(t, 'Enter the angler\'s name (e.g., "John", "Lou", "Dave") and tap Add.'),
          _bullet(t, 'Each angler gets their own row with + / - buttons and a running total.'),
          _bullet(t, 'Tap the name card to see a species breakdown (if you\'ve used voice with species names).'),
          _bullet(t, 'Use the 🗑️ icon to remove an angler, or the 🔄 icon to reset their count to zero.'),
          _bullet(t, 'The "New Trip" button (🗑️ in the AppBar) clears all anglers and starts fresh.'),

          const SizedBox(height: 24),

          // Step 2
          _stepNumber(tp, '2'),
          const SizedBox(height: 4),
          _heading('Counting Fish by Voice (Counter Tab)'),
          _body(t, 'The fastest way to tally fish while keeping your hands on your rod. Tap the mic button once and just talk.'),
          _bullet(t, 'Tap the 🎤 VOICE button in the Counter tab AppBar. It turns into ACTIVE with a pulsing dot.'),
          _bullet(t, 'Say the angler\'s name clearly — "John", "Lou", "Dave" — to add 1 to their count.'),
          _bullet(t, 'For species tracking, say "John caught a perch" or "Lou bass". The species is logged separately.'),
          _bullet(t, 'The mic stays on for up to 24 hours in continuous mode — no need to tap between calls.'),
          _bullet(t, 'Say "reset" or "clear" to start a new trip (clears all counters).'),
          _bullet(t, 'Tap the ACTIVE button again to stop listening when you\'re done.'),
          _body(t, 'Tip: The voice system matches names intelligently — "Jon" will match "John", "Louie" matches "Lou".'),

          const SizedBox(height: 24),

          // Step 3
          _stepNumber(tp, '3'),
          const SizedBox(height: 4),
          _heading('Logging Detailed Catches (Catches Tab)'),
          _body(t, 'The Catches tab is your fishing journal. Use it to record all the details of each catch with photos and measurements.'),
          _bullet(t, 'Tap the CATCHES tab, then tap the + button (bottom-right) to open the Add Catch form.'),
          _bullet(t, 'Select a Region and Country to filter the species list to fish found in your area.'),
          _bullet(t, 'Choose the Species from the autocomplete list, or type any custom name.'),
          _bullet(t, 'Add up to 3 Photos by tapping the photo slots — take a picture or pick from your gallery.'),
          _bullet(t, 'Enter the Angler who caught it, the Location, and the Lure/Bait used.'),
          _bullet(t, 'Record the Weight and Length — toggle between kg/lbs and cm/in.'),
          _bullet(t, 'Set the Date & Time — defaults to now, but you can change it for past catches.'),
          _bullet(t, 'Tap "Pick on map" under Catch Location to drop a pin exactly where you caught it.'),
          _bullet(t, 'Tap SAVE — the catch appears in your list with all details.'),

          const SizedBox(height: 24),

          // Step 4
          _stepNumber(tp, '4'),
          const SizedBox(height: 4),
          _heading('Viewing Your Catch Map (Map Tab)'),
          _body(t, 'See all your catches plotted on an interactive map. Great for finding patterns in where you catch certain species.'),
          _bullet(t, 'Go to the MAP tab — every catch with a pinned location shows as a cyan 🐟 marker.'),
          _bullet(t, 'Pan and zoom with standard touch gestures.'),
          _bullet(t, 'Tap any marker to see species, angler, weight, and exact coordinates.'),
          _bullet(t, 'Tap the 📍 button (bottom-right) to center the map on your current GPS location.'),
          _bullet(t, 'The refresh button (⟳) reloads your catch data from the database.'),
          _body(t, 'Tip: The more catches you pin, the easier it is to spot your hot spots!'),

          const SizedBox(height: 24),

          // Step 5a
          _stepNumber(tp, '5'),
          const SizedBox(height: 4),
          _heading('Checking the Weather (Map Tab)'),
          _body(t, 'Get current conditions and a 5-day forecast for your fishing spot right from the map.'),
          _bullet(t, 'On the MAP tab, tap the 🌤️ Weather button (top-left toggle area).'),
          _bullet(t, 'A bottom sheet shows current temp, feels like, wind speed, and humidity.'),
          _bullet(t, 'Scroll down to see the 5-day forecast with daily highs and lows.'),
          _bullet(t, 'Weather is fetched for the center of your current map view — pan to a new area and tap again.'),

          const SizedBox(height: 24),

          // Step 6
          _stepNumber(tp, '6'),
          const SizedBox(height: 4),
          _heading('Finding Nearby Bait & Gas (Map Tab)'),
          _body(t, 'Never get stranded without bait or fuel. The map can show nearby supplies using OpenStreetMap data.'),
          _bullet(t, 'On the MAP tab, tap the 🎣 Bait toggle button (top-left).'),
          _bullet(t, 'Pink markers appear for nearby bait shops, tackle shops, and convenience stores.'),
          _bullet(t, 'Tap the ⛽ Gas toggle to see orange markers for gas stations.'),
          _bullet(t, 'Tap any marker to see the business name and type.'),
          _bullet(t, 'Pan to a new area and toggle again to search that area.'),
          _bullet(t, 'Results come from OpenStreetMap — coverage varies by location. Towns and cities have the most data.'),

          const SizedBox(height: 24),

          // Step 6
          _stepNumber(tp, '7'),
          const SizedBox(height: 4),
          _heading('Customizing the Look (Theme & Dark Mode)'),
          _body(t, 'Make the app look the way you want with 5 color themes and dark/light mode.'),
          _bullet(t, 'Tap the 🎨 palette icon in the top AppBar to open the theme picker.'),
          _bullet(t, 'Choose from: Cyberpunk (neon), Ocean Deep (teal), Sunset (warm), Forest (green), or Midnight (purple).'),
          _bullet(t, 'Tap the ☀️/🌙 icon next to the palette to toggle between light and dark mode.'),
          _bullet(t, 'Your theme choice is saved and will persist when you restart the app.'),

          const SizedBox(height: 30),
          _heading('Quick Tips'),
          _body(t, '• Voice counting and catch logging are independent — use voice for quick tallying, then log details later.\n'
              '• You can edit any catch by tapping it in the list. Long-press to delete.\n'
              '• The biggest catch trophy updates automatically based on weight or length.\n'
              '• Each build gets a unique version number automatically.'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _stepNumber(ThemeProvider tp, String num) {
    return Row(children: [
      Container(width: 32, height: 32, alignment: Alignment.center,
        decoration: BoxDecoration(color: tp.preset.primary, borderRadius: BorderRadius.circular(8)),
        child: Text(num, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      const SizedBox(width: 12),
      Container(height: 1, color: tp.preset.primary.withValues(alpha: 0.2)),
    ]);
  }

  Widget _heading(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }

  Widget _body(Color t, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(fontSize: 14, color: t)),
    );
  }

  Widget _bullet(Color t, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, left: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('  •  ', style: TextStyle(fontSize: 14)),
        Expanded(child: Text(text, style: TextStyle(fontSize: 14, color: t))),
      ]),
    );
  }
}
