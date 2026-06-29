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

  final _regions = ['All', 'North America', 'Europe', 'Asia/Pacific', 'South America', 'Africa', 'Australia'];

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
      final regionMatch = _selectedRegion == 'All' || f.regions.contains(_selectedRegion);
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // Search
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search fish...',
                    hintStyle: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.4)),
                    prefixIcon: Icon(Icons.search,
                        color: theme.colorScheme.primary,
                        size: 20),
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
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              // Region tabs
              TabBar(
                controller: _tabCtrl,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: theme.colorScheme.primary,
                unselectedLabelColor: theme.colorScheme.onSurface
                    .withValues(alpha: 0.5),
                indicatorColor: theme.colorScheme.primary,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
                tabs: _regions
                    .map((r) => Tab(text: r))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
      body: results.isEmpty
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
                        style: TextStyle(
                            color: Colors.grey.shade400)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: results.length,
              itemBuilder: (context, index) =>
                  _FishCard(fish: results[index]),
            ),
    );
  }
}

class _FishCard extends StatelessWidget {
  final FishSpecies fish;
  const _FishCard({required this.fish});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
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
              // Fish icon/avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: fish.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.set_meal,
                    color: fish.color, size: 32),
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
                            size: 14,
                            color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(fish.sizeRange,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600)),
                        const SizedBox(width: 12),
                        Icon(Icons.terrain,
                            size: 14,
                            color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(fish.habitat,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis),
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

          // Info chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: fish.regions.map((r) => Chip(
              avatar: const Icon(Icons.public, size: 16),
              label: Text(r, style: const TextStyle(fontSize: 12)),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )).toList(),
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
                style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
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
                style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            )),
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
                          ))),
                ],
              ),
            )),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(ThemeData theme, IconData icon, String label, String value) {
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

// ─── Fish Database ────────────────────────────────────────────────────────

const fishDatabase = <FishSpecies>[
  // ── North America ──
  FishSpecies(
    name: 'Largemouth Bass',
    scientificName: 'Micropterus salmoides',
    regions: ['North America'],
    sizeRange: '30–60 cm, up to 10 kg',
    habitat: 'Lakes, ponds, rivers',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, crayfish',
    commonTackle: 'Spinnerbaits, crankbaits, plastic worms',
    color: Color(0xFF4CAF50),
    description: 'The most popular game fish in North America. Known for aggressive strikes and acrobatic leaps when hooked. Prefers warm, vegetated waters with plenty of cover.',
    tips: [
      'Fish near weed lines and submerged structure',
      'Early morning and dusk are prime feeding times',
      'Use darker lures in stained water, natural colors in clear water',
    ],
  ),
  FishSpecies(
    name: 'Bluegill',
    scientificName: 'Lepomis macrochirus',
    regions: ['North America'],
    sizeRange: '15–25 cm, up to 2 kg',
    habitat: 'Ponds, lakes, slow rivers',
    waterType: 'Freshwater',
    diet: 'Insects, small crustaceans',
    commonTackle: 'Worms, small jigs, flies',
    color: Color(0xFF2196F3),
    description: 'A panfish favorite for beginners and experts alike. Colorful body with a distinctive dark gill flap. Excellent for kids to catch.',
    tips: [
      'Fish near docks and overhanging trees in summer',
      'Use small hooks with live bait for best results',
      'They school — if you catch one, more are nearby',
    ],
  ),
  FishSpecies(
    name: 'Northern Pike',
    scientificName: 'Esox lucius',
    regions: ['North America', 'Europe'],
    sizeRange: '50–120 cm, up to 25 kg',
    habitat: 'Weedy lakes, slow rivers',
    waterType: 'Freshwater',
    diet: 'Fish, frogs, small mammals',
    commonTackle: 'Spoons, spinnerbaits, jerkbaits with wire leader',
    color: Color(0xFF8BC34A),
    description: 'A fearsome predator with razor-sharp teeth. Known for explosive strikes and powerful runs. Requires a wire leader to prevent bite-offs.',
    tips: [
      'Fish near weed beds and drop-offs',
      'Use steel or titanium leaders to avoid cut lines',
      'Figure-8 at the boat — pike often follow lures',
    ],
  ),
  FishSpecies(
    name: 'Rainbow Trout',
    scientificName: 'Oncorhynchus mykiss',
    regions: ['North America', 'Europe', 'Australia'],
    sizeRange: '25–50 cm, up to 10 kg',
    habitat: 'Cold rivers, lakes, streams',
    waterType: 'Freshwater',
    diet: 'Insects, crustaceans, small fish',
    commonTackle: 'Spoons, spinners, flies, powerbait',
    color: Color(0xFFFF5722),
    description: 'Beautifully colored trout with a pink/red lateral stripe. Popular for fly fishing and stock programs worldwide.',
    tips: [
      'Fish early morning or late evening in summer',
      'Match the hatch — use flies that resemble local insects',
      'In streams, cast upstream and let bait drift naturally',
    ],
  ),
  FishSpecies(
    name: 'Channel Catfish',
    scientificName: 'Ictalurus punctatus',
    regions: ['North America'],
    sizeRange: '30–70 cm, up to 15 kg',
    habitat: 'Rivers, lakes, reservoirs',
    waterType: 'Freshwater',
    diet: 'Fish, insects, crustaceans, plant matter',
    commonTackle: 'Chicken liver, stinkbaits, cut bait',
    color: Color(0xFF607D8B),
    description: 'The most common catfish species in North America. Named for their forked tail. Nocturnal bottom-feeders with excellent sense of smell.',
    tips: [
      'Fish at night for best results',
      'Use smelly baits — catfish rely on scent',
      'Fish deep channels and holes in rivers',
    ],
  ),

  // ── Europe ──
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
    description: 'A common European game fish with distinctive dark vertical stripes on a greenish body. Schooling fish that provides excellent sport.',
    tips: [
      'Look for perch near underwater structures and weed edges',
      'Use small lures — perch have small mouths',
      'They school by size — keep fishing once you catch one',
    ],
  ),
  FishSpecies(
    name: 'Common Carp',
    scientificName: 'Cyprinus carpio',
    regions: ['Europe', 'Asia/Pacific', 'North America'],
    sizeRange: '30–80 cm, up to 40 kg',
    habitat: 'Lakes, rivers, ponds',
    waterType: 'Freshwater',
    diet: 'Plant matter, insects, crustaceans',
    commonTackle: 'Boilies, corn, dough balls, hair rigs',
    color: Color(0xFF9E9E9E),
    description: 'One of the hardest fighting freshwater fish. Gold or bronze colored with large scales. Highly prized by specimen anglers in Europe.',
    tips: [
      'Use hair rigs with boilies for specimen carp',
      'Carp are wary — use light line and subtle presentation',
      'Fish during warm months when carp are most active',
    ],
  ),
  FishSpecies(
    name: 'Atlantic Salmon',
    scientificName: 'Salmo salar',
    regions: ['Europe', 'North America'],
    sizeRange: '60–100 cm, up to 35 kg',
    habitat: 'Atlantic Ocean, rivers',
    waterType: 'Saltwater / Freshwater',
    diet: 'Fish, crustaceans, squid',
    commonTackle: 'Flies, spoons, spinners',
    color: Color(0xFFE91E63),
    description: 'The king of game fish. Anadromous — born in freshwater, migrate to sea, return to spawn. Famous for leaping ability and fighting spirit.',
    tips: [
      'Fly fishing with speckled flies is traditional',
      'Fish in rivers during spawning runs (spring/fall)',
      'Use sinking lines in deep pools and runs',
    ],
  ),

  // ── Asia/Pacific ──
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
    description: 'A highly prized sport fish across Asia and Australia. Silver bodied with a distinctive concave head shape. Can live in both fresh and saltwater.',
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
    description: 'A powerful pelagic fish highly prized in Japanese cuisine (hamachi/sushi grade). Known for fast runs and strong fights.',
    tips: [
      'Use poppers and stickbaits for topwater action',
      'Fish near reefs and drop-offs during summer',
      'Heavy tackle recommended — they are powerful fighters',
    ],
  ),

  // ── South America ──
  FishSpecies(
    name: 'Peacock Bass',
    scientificName: 'Cichla spp.',
    regions: ['South America'],
    sizeRange: '30–70 cm, up to 12 kg',
    habitat: 'Amazon basin rivers, lakes',
    waterType: 'Freshwater',
    diet: 'Fish, crustaceans',
    commonTackle: 'Topwater lures, swimbaits, jerkbaits',
    color: Color(0xFFFFEB3B),
    description: 'A vibrant South American game fish named for the eye-spot on its tail. Extremely aggressive and powerful. Introduced to Florida and Hawaii.',
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
    description: 'One of the largest freshwater fish in the world. Can breathe air using its swim bladder. Ancient-looking with a massive, armored body.',
    tips: [
      'Watch for surface rolls — they breathe air every 5-15 minutes',
      'Use extremely heavy tackle (100lb+ line)',
      'Catch and release is critical — populations are threatened',
    ],
  ),

  // ── Africa ──
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
    description: 'A massive freshwater predator native to African lakes and rivers. Introduced to Lake Victoria where it dramatically changed the ecosystem.',
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
    description: 'Named for its razor-sharp teeth and striped body. One of the most ferocious freshwater fish in the world. Known for aerial displays when hooked.',
    tips: [
      'Use wire leaders — their teeth will cut regular line',
      'Fast-moving lures trigger aggressive strikes',
      'Fish near rapids and river confluences',
    ],
  ),

  // ── Australia ──
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
    description: 'Australia\'s largest freshwater fish. A dark green mottled predator that can live for 50+ years. Sacred to Indigenous Australians.',
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
    description: 'A bottom-dwelling ambush predator with a flat, triangular head. Excellent eating quality. One of the most popular targets for Australian anglers.',
    tips: [
      'Drag soft plastics slowly along sandy bottoms',
      'Fish incoming tides in estuaries',
      'Fillets are white, flaky and delicious',
    ],
  ),
];
