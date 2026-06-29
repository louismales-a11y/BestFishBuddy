import 'package:flutter/material.dart';

class FishIdScreen extends StatefulWidget {
  const FishIdScreen({super.key});

  @override
  State<FishIdScreen> createState() => _FishIdScreenState();
}

class _FishIdScreenState extends State<FishIdScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedRegion = 'All';

  final _regions = [
    'All',
    'USA',
    'Canada',
    'Europe',
    'Asia/Pacific',
    'South America',
    'Africa',
    'Australia',
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _regions.length, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) {
        setState(() => _selectedRegion = _regions[_tabCtrl.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<FishSpecies> get _filtered {
    final query = _searchQuery.toLowerCase().trim();
    return fishDatabase.where((f) {
      final regionMatch =
          _selectedRegion == 'All' || f.regions.contains(_selectedRegion);
      if (!regionMatch) return false;
      if (query.isEmpty) return true;
      return f.name.toLowerCase().contains(query) ||
          f.scientificName.toLowerCase().contains(query) ||
          f.regions.any((r) => r.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fish ID'),
      ),
      body: Column(
        children: [
          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search fish...',
                hintStyle: TextStyle(
                    color: theme.colorScheme.onSurface
                        .withValues(alpha: 0.4)),
                prefixIcon: Icon(Icons.search,
                    color: theme.colorScheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        })
                    : null,
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
          // ── Region tabs ──
          SizedBox(
            height: 40,
            child: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor:
                  theme.colorScheme.onSurface.withValues(alpha: 0.5),
              indicatorColor: theme.colorScheme.primary,
              dividerColor: Colors.transparent,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: _regions.map((r) => Tab(text: r)).toList(),
            ),
          ),
          const Divider(height: 1),
          // ── Results count ──
          if (results.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Text('${results.length} species',
                      style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5))),
                  const Spacer(),
                  Text(_selectedRegion,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary)),
                ],
              ),
            ),
          // ── Fish list or empty state ──
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.menu_book,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text('No fish found',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade500)),
                        if (_searchQuery.isNotEmpty)
                          Text('Try a different search term',
                              style:
                                  TextStyle(color: Colors.grey.shade400)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    itemCount: results.length,
                    itemBuilder: (context, index) =>
                        _FishCard(fish: results[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Fish Card ────────────────────────────────────────────────────────────

class _FishCard extends StatelessWidget {
  final FishSpecies fish;
  const _FishCard({required this.fish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => _FishDetailScreen(fish: fish)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: fish.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child:
                    Icon(Icons.set_meal, color: fish.color, size: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(fish.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )),
                    const SizedBox(height: 2),
                    Text(fish.scientificName,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 12,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        )),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.straighten,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(fish.sizeRange,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.terrain,
                            size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(fish.habitat,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600),
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Detail Screen ────────────────────────────────────────────────────────

class _FishDetailScreen extends StatelessWidget {
  final FishSpecies fish;
  const _FishDetailScreen({required this.fish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(fish.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Hero header
          Container(
            height: 180,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  fish.color.withValues(alpha: 0.2),
                  fish.color.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Icon(Icons.set_meal,
                  size: 80, color: fish.color.withValues(alpha: 0.6)),
            ),
          ),
          const SizedBox(height: 20),

          // Name & scientific
          Text(fish.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              )),
          Text(fish.scientificName,
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16,
                color: theme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
              )),
          const SizedBox(height: 16),

          // Region chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fish.regions
                .map((r) => Chip(
                      avatar: const Icon(Icons.public, size: 16),
                      label: Text(r, style: const TextStyle(fontSize: 12)),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),

          // Details
          _detailRow(theme, Icons.straighten, 'Size', fish.sizeRange),
          _detailRow(theme, Icons.terrain, 'Habitat', fish.habitat),
          _detailRow(theme, Icons.water_drop, 'Water', fish.waterType),
          _detailRow(theme, Icons.restaurant, 'Diet', fish.diet),
          _detailRow(theme, Icons.build, 'Tackle', fish.commonTackle),

          if (fish.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('About',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(fish.description,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.8),
                )),
          ],

          if (fish.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Fishing Tips',
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            ...fish.tips.map((tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle,
                          size: 16, color: Colors.green.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(tip,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.4,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.8),
                            )),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _detailRow(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                )),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─── Data Model ───────────────────────────────────────────────────────────

class FishSpecies {
  final String name;
  final String scientificName;
  final List<String> regions;
  final String sizeRange;
  final String habitat;
  final String waterType;
  final String diet;
  final String commonTackle;
  final String description;
  final List<String> tips;
  final Color color;

  const FishSpecies({
    required this.name,
    required this.scientificName,
    required this.regions,
    required this.sizeRange,
    required this.habitat,
    required this.waterType,
    required this.diet,
    required this.commonTackle,
    this.description = '',
    this.tips = const [],
    this.color = Colors.blue,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
//  FISH DATABASE — World Species Reference
// ═══════════════════════════════════════════════════════════════════════════

const fishDatabase = <FishSpecies>[
  // ─────────────────────────────────────────────────────────────────────────
  //  USA
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Largemouth Bass',
    scientificName: 'Micropterus salmoides',
    regions: ['USA'],
    sizeRange: '30–60 cm, up to 10 kg',
    habitat: 'Lakes, ponds, rivers',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, crayfish',
    commonTackle: 'Spinnerbaits, crankbaits, plastic worms',
    color: Color(0xFF4CAF50),
    description:
        'The most popular game fish in the USA. Known for aggressive strikes and acrobatic leaps when hooked. Prefers warm, vegetated waters with plenty of cover like logs and lily pads.',
    tips: [
      'Fish near weed lines and submerged structure',
      'Early morning and dusk are prime feeding times',
      'Use darker lures in stained water, natural colors in clear water',
    ],
  ),
  FishSpecies(
    name: 'Bluegill',
    scientificName: 'Lepomis macrochirus',
    regions: ['USA', 'Canada'],
    sizeRange: '15–25 cm, up to 2 kg',
    habitat: 'Ponds, lakes, slow rivers',
    waterType: 'Freshwater',
    diet: 'Insects, small crustaceans',
    commonTackle: 'Worms, small jigs, flies',
    color: Color(0xFF2196F3),
    description:
        'A panfish favorite for beginners and experts alike. Colorful body with a distinctive dark gill flap. Excellent for kids to catch and makes for great table fare.',
    tips: [
      'Fish near docks and overhanging trees in summer',
      'Use small hooks with live bait for best results',
      'They school — if you catch one, more are nearby',
    ],
  ),
  FishSpecies(
    name: 'Channel Catfish',
    scientificName: 'Ictalurus punctatus',
    regions: ['USA', 'Canada'],
    sizeRange: '30–70 cm, up to 15 kg',
    habitat: 'Rivers, lakes, reservoirs',
    waterType: 'Freshwater',
    diet: 'Fish, insects, crustaceans, plant matter',
    commonTackle: 'Chicken liver, stinkbaits, cut bait',
    color: Color(0xFF607D8B),
    description:
        'The most common catfish species in North America. Named for their forked tail. Nocturnal bottom-feeders with an excellent sense of smell and taste.',
    tips: [
      'Fish at night for best results',
      'Use smelly baits — catfish rely on scent',
      'Fish deep channels and holes in rivers',
    ],
  ),
  FishSpecies(
    name: 'Walleye',
    scientificName: 'Sander vitreus',
    regions: ['USA', 'Canada'],
    sizeRange: '30–60 cm, up to 8 kg',
    habitat: 'Lakes, rivers, reservoirs',
    waterType: 'Freshwater',
    diet: 'Small fish, insects',
    commonTackle: 'Jigs, crankbaits, live minnows, spinner rigs',
    color: Color(0xFF9E9E9E),
    description:
        'A prized game fish with excellent eyesight adapted for low light. Named for their opaque, glassy eyes. One of the best-tasting freshwater fish.',
    tips: [
      'Fish at dawn, dusk, or after dark — their eyes are light-sensitive',
      'Troll with bottom-bouncing rigs in deeper lakes',
      'Jig with a minnow-tipped jig head near rocky bottoms',
    ],
  ),
  FishSpecies(
    name: 'Crappie',
    scientificName: 'Pomoxis spp.',
    regions: ['USA'],
    sizeRange: '20–35 cm, up to 2 kg',
    habitat: 'Lakes, ponds, slow rivers',
    waterType: 'Freshwater',
    diet: 'Small fish, insects, crustaceans',
    commonTackle: 'Small jigs, minnows under a bobber',
    color: Color(0xFF66BB6A),
    description:
        'Highly popular panfish known for schooling behavior and delicious white meat. Two main species: Black Crappie and White Crappie. Spawn in spring.',
    tips: [
      'Fish around submerged brush piles and docks',
      'Use light tackle — crappie have soft mouths',
      'Spring spawning season is the best time to catch limits',
    ],
  ),
  FishSpecies(
    name: 'Striped Bass',
    scientificName: 'Morone saxatilis',
    regions: ['USA'],
    sizeRange: '40–100 cm, up to 30 kg',
    habitat: 'Coastal waters, rivers, lakes',
    waterType: 'Saltwater / Freshwater',
    diet: 'Fish, squid, crustaceans',
    commonTackle: 'Poppers, swimbaits, live eels, heavy spinning gear',
    color: Color(0xFF1565C0),
    description:
        'A powerful migratory game fish with distinctive horizontal stripes. Anadromous — lives in saltwater but spawns in freshwater. Known for surface blitzes.',
    tips: [
      'Look for birds diving — they signal baitfish schools',
      'Use surfcasting gear from beaches and jetties',
      'Live eels are the ultimate bait for trophy stripers',
    ],
  ),
  FishSpecies(
    name: 'Muskellunge (Muskie)',
    scientificName: 'Esox masquinongy',
    regions: ['USA', 'Canada'],
    sizeRange: '70–130 cm, up to 30 kg',
    habitat: 'Weedy lakes, slow rivers',
    waterType: 'Freshwater',
    diet: 'Fish, ducks, muskrats',
    commonTackle: 'Large bucktail spinners, topwater lures, heavy baitcaster',
    color: Color(0xFF33691E),
    description:
        'The "fish of 10,000 casts." North America\'s largest pike species. Apex predator known for massive size, elusive nature, and explosive strikes.',
    tips: [
      'Use a steel leader — they have razor teeth',
      'Fish early morning or late evening near weed beds',
      'Figure-8 at the boat — many follows happen at boat side',
    ],
  ),
  FishSpecies(
    name: 'Redfish (Red Drum)',
    scientificName: 'Sciaenops ocellatus',
    regions: ['USA'],
    sizeRange: '40–90 cm, up to 20 kg',
    habitat: 'Coastal waters, estuaries, bays',
    waterType: 'Saltwater',
    diet: 'Crab, shrimp, small fish',
    commonTackle: 'Soft plastics, spoons, live shrimp on a popping cork',
    color: Color(0xFFE53935),
    description:
        'A hard-fighting inshore species named for its bronze-red color and distinctive black spot near the tail. Popular along the Atlantic and Gulf coasts.',
    tips: [
      'Look for tailing fish in shallow flats',
      'Use gold spoons or paddle-tail soft plastics',
      'Incoming tides push redfish into marsh creeks',
    ],
  ),
  FishSpecies(
    name: 'Rainbow Trout',
    scientificName: 'Oncorhynchus mykiss',
    regions: ['USA', 'Canada', 'Europe', 'Australia'],
    sizeRange: '25–50 cm, up to 10 kg',
    habitat: 'Cold rivers, lakes, streams',
    waterType: 'Freshwater',
    diet: 'Insects, crustaceans, small fish',
    commonTackle: 'Spoons, spinners, flies, powerbait',
    color: Color(0xFFFF5722),
    description:
        'Beautifully colored trout with a pink/red lateral stripe. Popular for fly fishing and stock programs worldwide. Steelhead is the migratory form.',
    tips: [
      'Fish early morning or late evening in summer',
      'Match the hatch — use flies that resemble local insects',
      'In streams, cast upstream and let bait drift naturally',
    ],
  ),
  FishSpecies(
    name: 'Smallmouth Bass',
    scientificName: 'Micropterus dolomieu',
    regions: ['USA', 'Canada'],
    sizeRange: '25–50 cm, up to 5 kg',
    habitat: 'Clear lakes, rocky rivers',
    waterType: 'Freshwater',
    diet: 'Crayfish, small fish, insects',
    commonTackle: 'Tube jigs, crankbaits, drop-shot rigs',
    color: Color(0xFF8D6E63),
    description:
        'Considered the hardest fighting bass species pound-for-pound. Bronzy-green with vertical bars. Prefers cooler, clearer water than largemouth.',
    tips: [
      'Focus on rocky banks and gravel bottoms',
      'Crayfish-colored lures are deadly',
      'Smallmouth put up an incredible fight — light tackle is fun',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  Canada
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Northern Pike',
    scientificName: 'Esox lucius',
    regions: ['Canada', 'Europe'],
    sizeRange: '50–120 cm, up to 25 kg',
    habitat: 'Weedy lakes, slow rivers',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, small mammals',
    commonTackle: 'Spoons, spinnerbaits, jerkbaits with wire leader',
    color: Color(0xFF8BC34A),
    description:
        'A fearsome predator with razor-sharp teeth. Known for explosive strikes and powerful runs. Especially abundant in Canadian shield lakes.',
    tips: [
      'Fish near weed beds and drop-offs',
      'Use steel or titanium leaders to avoid cut lines',
      'Figure-8 at the boat — pike often follow lures',
    ],
  ),
  FishSpecies(
    name: 'Lake Trout',
    scientificName: 'Salvelinus namaycush',
    regions: ['Canada'],
    sizeRange: '40–80 cm, up to 30 kg',
    habitat: 'Deep, cold lakes',
    waterType: 'Freshwater',
    diet: 'Small fish, crustaceans',
    commonTackle: 'Spoons, downriggers, lead core line, live bait',
    color: Color(0xFF37474F),
    description:
        'Canada\'s largest trout species. Lives in deep, cold lakes across the north. Grayish body with light spots. Requires specialized deep-water techniques.',
    tips: [
      'Troll with downriggers in 15-30m of water during summer',
      'Spring and fall — fish shallower near shore',
      'Use flashers or dodgers to attract strikes',
    ],
  ),
  FishSpecies(
    name: 'Brook Trout',
    scientificName: 'Salvelinus fontinalis',
    regions: ['Canada', 'USA'],
    sizeRange: '20–40 cm, up to 5 kg',
    habitat: 'Cold streams, small lakes, ponds',
    waterType: 'Freshwater',
    diet: 'Insects, crustaceans, small fish',
    commonTackle: 'Small spinners, flies, worms',
    color: Color(0xFFFF6F00),
    description:
        'Canada\'s only native stream trout and provincial fish of several provinces. Stunning colors — olive back, red spots, and white-edged fins.',
    tips: [
      'Fish in small, pristine streams with light tackle',
      'Use dry flies in summer, nymphs in spring',
      'Brook trout are sensitive to warm water — fish early',
    ],
  ),
  FishSpecies(
    name: 'Arctic Char',
    scientificName: 'Salvelinus alpinus',
    regions: ['Canada'],
    sizeRange: '30–70 cm, up to 10 kg',
    habitat: 'Arctic waters, deep cold lakes',
    waterType: 'Freshwater / Saltwater',
    diet: 'Small fish, zooplankton, insects',
    commonTackle: 'Spoons, small jigs, flies',
    color: Color(0xFFFF4081),
    description:
        'The most northerly freshwater fish. Related to trout and salmon. Stunning red-orange belly during spawning season. Found in Canada\'s Arctic regions.',
    tips: [
      'Best fished from July to September in northern rivers',
      'Brightly colored lures work well in clear Arctic water',
      'Fly fishing with streamers is productive',
    ],
  ),
  FishSpecies(
    name: 'Sturgeon (Lake Sturgeon)',
    scientificName: 'Acipenser fulvescens',
    regions: ['Canada', 'USA'],
    sizeRange: '100–200 cm, up to 100 kg',
    habitat: 'Large lakes and rivers',
    waterType: 'Freshwater',
    diet: 'Bottom invertebrates, small fish',
    commonTackle: 'Heavy rod, large hooks, cut bait, worms',
    color: Color(0xFF5D4037),
    description:
        'A living fossil — virtually unchanged for 200 million years. Canada\'s largest freshwater fish. Protected in many areas; catch and release only.',
    tips: [
      'Fish deep holes in large rivers like the Fraser or Winnipeg',
      'Use heavy tackle — sturgeon are incredibly strong',
      'Check local regulations — many areas have strict rules',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  Europe
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'European Perch',
    scientificName: 'Perca fluviatilis',
    regions: ['Europe'],
    sizeRange: '15–40 cm, up to 4 kg',
    habitat: 'Lakes, ponds, slow rivers',
    waterType: 'Freshwater',
    diet: 'Small fish, insects, crustaceans',
    commonTackle: 'Small spinners, worms, jigheads',
    color: Color(0xFFFF9800),
    description:
        'A common European game fish with distinctive dark vertical stripes on a greenish body. Schooling fish that provides excellent sport on light tackle.',
    tips: [
      'Look for perch near underwater structures and weed edges',
      'Use small lures — perch have small mouths',
      'They school by size — keep fishing once you catch one',
    ],
  ),
  FishSpecies(
    name: 'Common Carp',
    scientificName: 'Cyprinus carpio',
    regions: ['Europe', 'Asia/Pacific', 'USA', 'Canada'],
    sizeRange: '30–80 cm, up to 40 kg',
    habitat: 'Lakes, rivers, ponds',
    waterType: 'Freshwater',
    diet: 'Plant matter, insects, crustaceans',
    commonTackle: 'Boilies, corn, dough balls, hair rigs',
    color: Color(0xFF9E9E9E),
    description:
        'One of the hardest fighting freshwater fish. Gold or bronze colored with large scales. Highly prized by specimen anglers across Europe.',
    tips: [
      'Use hair rigs with boilies for specimen carp',
      'Carp are wary — use light line and subtle presentation',
      'Fish during warm months when carp are most active',
    ],
  ),
  FishSpecies(
    name: 'Atlantic Salmon',
    scientificName: 'Salmo salar',
    regions: ['Europe', 'Canada'],
    sizeRange: '60–100 cm, up to 35 kg',
    habitat: 'Atlantic Ocean, rivers',
    waterType: 'Saltwater / Freshwater',
    diet: 'Fish, crustaceans, squid',
    commonTackle: 'Flies, spoons, spinners',
    color: Color(0xFFE91E63),
    description:
        'The king of game fish. Anadromous — born in freshwater, migrate to sea, return to spawn. Famous for leaping ability and fighting spirit.',
    tips: [
      'Fly fishing with speckled flies is traditional',
      'Fish in rivers during spawning runs (spring/fall)',
      'Use sinking lines in deep pools and runs',
    ],
  ),
  FishSpecies(
    name: 'Zander',
    scientificName: 'Sander lucioperca',
    regions: ['Europe'],
    sizeRange: '30–70 cm, up to 15 kg',
    habitat: 'Lakes, rivers, canals',
    waterType: 'Freshwater',
    diet: 'Small fish',
    commonTackle: 'Jigs, hard lures, dead bait, drop-shot rigs',
    color: Color(0xFF78909C),
    description:
        'Europe\'s premier predatory game fish. Related to walleye with similar eyesight adaptations. Highly prized for both sport and excellent table quality.',
    tips: [
      'Fish at dawn, dusk, and nighttime',
      'Use dark-colored soft plastics on jig heads',
      'Drop-shot rigging is very effective for finicky zander',
    ],
  ),
  FishSpecies(
    name: 'Brown Trout',
    scientificName: 'Salmo trutta',
    regions: ['Europe', 'USA', 'Canada', 'Australia'],
    sizeRange: '25–60 cm, up to 15 kg',
    habitat: 'Rivers, streams, lakes',
    waterType: 'Freshwater',
    diet: 'Insects, crustaceans, small fish',
    commonTackle: 'Flies, spinners, small crankbaits, worms',
    color: Color(0xFFA0522D),
    description:
        'A classic European game fish introduced worldwide. Golden-brown with dark spots and red dots. Wary and challenging — the ultimate fly fishing target.',
    tips: [
      'Approach quietly — brown trout are easily spooked',
      'Match the hatch with dry flies in summer',
      'Larger browns are nocturnal — fish after dark with streamers',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  Asia/Pacific
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Asian Seabass (Barramundi)',
    scientificName: 'Lates calcarifer',
    regions: ['Asia/Pacific', 'Australia'],
    sizeRange: '50–120 cm, up to 60 kg',
    habitat: 'Rivers, estuaries, coastal waters',
    waterType: 'Saltwater / Freshwater',
    diet: 'Fish, crustaceans',
    commonTackle: 'Soft plastics, hard-bodied lures, live bait',
    color: Color(0xFF00BCD4),
    description:
        'A highly prized sport fish across Asia and Australia. Silver bodied with a distinctive concave head shape. Catadromous — lives in fresh water, spawns in salt.',
    tips: [
      'Fish around structure like mangroves and rock bars',
      'Barramundi are ambush predators — work lures slowly',
      'Catch and release is encouraged for larger specimens',
    ],
  ),
  FishSpecies(
    name: 'Japanese Amberjack (Hamachi)',
    scientificName: 'Seriola quinqueradiata',
    regions: ['Asia/Pacific'],
    sizeRange: '40–100 cm, up to 10 kg',
    habitat: 'Coastal waters, offshore reefs',
    waterType: 'Saltwater',
    diet: 'Fish, squid, crustaceans',
    commonTackle: 'Popping lures, jigs, live bait',
    color: Color(0xFFFFD600),
    description:
        'A powerful pelagic fish highly prized in Japanese cuisine as hamachi/sushi grade. Known for blistering runs and dogged fights.',
    tips: [
      'Use poppers and stickbaits for topwater action',
      'Fish near reefs and drop-offs during summer',
      'Heavy tackle recommended — they are powerful fighters',
    ],
  ),
  FishSpecies(
    name: 'Giant Trevally (GT)',
    scientificName: 'Caranx ignobilis',
    regions: ['Asia/Pacific', 'Australia'],
    sizeRange: '60–150 cm, up to 80 kg',
    habitat: 'Reefs, atolls, coastal waters',
    waterType: 'Saltwater',
    diet: 'Fish, crustaceans, squid',
    commonTackle: 'Poppers, stickbaits, heavy jigs, 80lb+ braid',
    color: Color(0xFF1B5E20),
    description:
        'The ultimate saltwater hard-core fish. Bronze-backed giant that crushes surface poppers. Known for explosive strikes and unstoppable power.',
    tips: [
      'Cast poppers into breaking surf and reef washes',
      'Use 80-130lb braid with 100-150lb leader',
      'Strike hard and fast — GTs hit and turn immediately',
    ],
  ),
  FishSpecies(
    name: 'Snakehead',
    scientificName: 'Channa spp.',
    regions: ['Asia/Pacific'],
    sizeRange: '30–80 cm, up to 10 kg',
    habitat: 'Swamps, canals, ponds, rivers',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, insects',
    commonTackle: 'Frogs, spinnerbaits, topwater lures',
    color: Color(0xFF4E342E),
    description:
        'An aggressive air-breathing predator native to Asia. Can survive out of water for days. Known for powerful strikes and weed-bed ambushes.',
    tips: [
      'Topwater frog lures are deadly in lily pads',
      'Fish shallow, vegetated areas',
      'They guard their young — if you see fry, adults are nearby',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  South America
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Peacock Bass',
    scientificName: 'Cichla spp.',
    regions: ['South America', 'USA'],
    sizeRange: '30–70 cm, up to 12 kg',
    habitat: 'Amazon basin rivers, lakes',
    waterType: 'Freshwater',
    diet: 'Fish, crustaceans',
    commonTackle: 'Topwater lures, swimbaits, jerkbaits',
    color: Color(0xFFFFEB3B),
    description:
        'A vibrant South American game fish named for the eye-spot on its tail. Extremely aggressive and powerful. Successfully introduced to Florida.',
    tips: [
      'Surface lures drive them crazy — explosive strikes',
      'Fish near submerged logs and rock piles',
      'Use braided line for better control in heavy cover',
    ],
  ),
  FishSpecies(
    name: 'Arapaima',
    scientificName: 'Arapaima gigas',
    regions: ['South America'],
    sizeRange: '200–300 cm, up to 200 kg',
    habitat: 'Amazon River basin',
    waterType: 'Freshwater',
    diet: 'Fish',
    commonTackle: 'Large lures, live bait, heavy tackle',
    color: Color(0xFF795548),
    description:
        'One of the largest freshwater fish in the world. Can breathe air using its swim bladder. Ancient-looking with a massive, armored body and red tail.',
    tips: [
      'Watch for surface rolls — they breathe air every 5-15 minutes',
      'Use extremely heavy tackle (100lb+ line)',
      'Catch and release is critical — populations are threatened',
    ],
  ),
  FishSpecies(
    name: 'Payara (Vampire Fish)',
    scientificName: 'Hydrolycus scomberoides',
    regions: ['South America'],
    sizeRange: '40–90 cm, up to 10 kg',
    habitat: 'Amazon and Orinoco river basins',
    waterType: 'Freshwater',
    diet: 'Fish',
    commonTackle: 'Large spoons, swimbaits, wire leader',
    color: Color(0xFF263238),
    description:
        'The vampire fish of the Amazon. Named for two massive fangs that protrude from its lower jaw. A silver torpedo that strikes with incredible ferocity.',
    tips: [
      'Use fast-moving lures — payara are visual predators',
      'Wire leader is mandatory — those fangs cut everything',
      'Fish near rapids and fast-flowing water',
    ],
  ),
  FishSpecies(
    name: 'Golden Dorado',
    scientificName: 'Salminus brasiliensis',
    regions: ['South America'],
    sizeRange: '40–100 cm, up to 20 kg',
    habitat: 'Rivers in the Paraná and Uruguay basins',
    waterType: 'Freshwater',
    diet: 'Fish',
    commonTackle: 'Surface lures, spoons, large streamer flies',
    color: Color(0xFFFFC107),
    description:
        'The "tiger of the rivers." A brilliant gold-colored predator that attacks surface lures with explosive fury. One of South America\'s most sought-after sport fish.',
    tips: [
      'Use bright, flashy lures that create surface disturbance',
      'Fish near rapids, tailraces, and river confluences',
      'They travel in packs — stay alert after a catch',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  Africa
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Nile Perch',
    scientificName: 'Lates niloticus',
    regions: ['Africa'],
    sizeRange: '60–150 cm, up to 200 kg',
    habitat: 'African lakes, rivers',
    waterType: 'Freshwater',
    diet: 'Fish, crustaceans',
    commonTackle: 'Large lures, live bait, heavy trolling gear',
    color: Color(0xFF1565C0),
    description:
        'A massive freshwater predator native to African lakes and rivers. Introduced to Lake Victoria where it transformed the ecosystem and fishery.',
    tips: [
      'Fish deep drop-offs and submerged river channels',
      'Use large lures — they hunt fish up to half their size',
      'Trolling with deep-diving plugs is effective',
    ],
  ),
  FishSpecies(
    name: 'Tigerfish',
    scientificName: 'Hydrocynus spp.',
    regions: ['Africa'],
    sizeRange: '30–80 cm, up to 15 kg',
    habitat: 'African rivers, lakes',
    waterType: 'Freshwater',
    diet: 'Fish',
    commonTackle: 'Spinners, spoons, wire leaders',
    color: Color(0xFFFF6F00),
    description:
        'Named for its razor-sharp teeth and striped body. One of the most ferocious freshwater fish in the world. Known for aerial displays when hooked.',
    tips: [
      'Use wire leaders — their teeth will cut regular line',
      'Fast-moving lures trigger aggressive strikes',
      'Fish near rapids and river confluences',
    ],
  ),
  FishSpecies(
    name: 'African Sharptooth Catfish',
    scientificName: 'Clarias gariepinus',
    regions: ['Africa'],
    sizeRange: '40–100 cm, up to 25 kg',
    habitat: 'Rivers, lakes, swamps',
    waterType: 'Freshwater',
    diet: 'Fish, insects, plant matter, carrion',
    commonTackle: 'Worms, fish bait, chicken liver',
    color: Color(0xFF455A64),
    description:
        'A hardy, widespread African catfish. Can breathe air and survive in low-oxygen water. Dark grey to black. Grows large and fights hard.',
    tips: [
      'Fish at night using strong-smelling baits',
      'Found in almost any freshwater body across Africa',
      'They can be invasive — check local regulations',
    ],
  ),

  // ─────────────────────────────────────────────────────────────────────────
  //  Australia
  // ─────────────────────────────────────────────────────────────────────────
  FishSpecies(
    name: 'Murray Cod',
    scientificName: 'Maccullochella peelii',
    regions: ['Australia'],
    sizeRange: '50–120 cm, up to 110 kg',
    habitat: 'Murray-Darling River system',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, crayfish, water birds',
    commonTackle: 'Large lures, spinnerbaits, live bait',
    color: Color(0xFF33691E),
    description:
        "Australia's largest freshwater fish. A dark green mottled predator that can live for 50+ years. Sacred to Indigenous Australians.",
    tips: [
      'Fish near fallen timber and undercut banks',
      'Use large, slow-moving lures at dawn and dusk',
      'Strict catch limits — practice catch and release',
    ],
  ),
  FishSpecies(
    name: 'Flathead',
    scientificName: 'Platycephalus spp.',
    regions: ['Australia', 'Asia/Pacific'],
    sizeRange: '30–80 cm, up to 5 kg',
    habitat: 'Estuaries, coastal bays, sandy bottoms',
    waterType: 'Saltwater',
    diet: 'Small fish, prawns, crabs',
    commonTackle: 'Soft plastics, bait on a running rig',
    color: Color(0xFFA1887F),
    description:
        'A bottom-dwelling ambush predator with a flat, triangular head. Excellent eating quality. One of the most popular targets for Australian anglers.',
    tips: [
      'Drag soft plastics slowly along sandy bottoms',
      'Fish incoming tides in estuaries',
      'Fillets are white, flaky and delicious',
    ],
  ),
  FishSpecies(
    name: 'Australian Salmon',
    scientificName: 'Arripis trutta',
    regions: ['Australia'],
    sizeRange: '30–60 cm, up to 5 kg',
    habitat: 'Coastal waters, surf beaches, bays',
    waterType: 'Saltwater',
    diet: 'Small fish, krill, prawns',
    commonTackle: 'Metal slugs, pilchards, surfcasting gear',
    color: Color(0xFF42A5F5),
    description:
        'Not a true salmon but a highly popular Australian sport fish. Greenish-blue back with silver belly. Known for schooling behavior and powerful runs.',
    tips: [
      'Surfcast from beaches using bait or metal lures',
      'Look for birds working — salmon push baitfish to the surface',
      'They school by size — catch one and you\'ll likely catch more',
    ],
  ),
];
