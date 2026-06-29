/// Predefined tackle types with target species and usage tips.
class TackleTypeInfo {
  final String name;
  final String category;
  final String description;
  final List<String> targetSpecies;
  final String tips;
  final String icon; // emoji / icon name

  const TackleTypeInfo({
    required this.name,
    required this.category,
    required this.description,
    required this.targetSpecies,
    required this.tips,
    this.icon = '🎣',
  });
}

/// Built-in database of common lure / tackle types.
const tackleTypeDatabase = <TackleTypeInfo>[
  // ── Spinnerbaits ──
  TackleTypeInfo(
    name: 'Spinnerbait',
    category: 'Spinnerbait',
    description: 'A safety-pin shaped lure with spinning metal blades and a skirted jig head.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Spotted Bass',
      'Northern Pike', 'Muskellunge', 'Chain Pickerel',
    ],
    tips: 'Fish near weed edges, lily pads, and submerged timber. '
        'Vary your retrieve speed — slow rolling along the bottom works in cold water, '
        'while a fast, erratic retrieve triggers reaction strikes in warm water. '
        'Use a trailer hook for short-striking fish.',
    icon: '🔄',
  ),
  TackleTypeInfo(
    name: 'Buzzbait',
    category: 'Spinnerbait',
    description: 'A topwater spinnerbait with a propeller-style blade that churns the surface.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Northern Pike',
    ],
    tips: 'Fish early morning or dusk over weed beds and lily pads. '
        'Keep the rod tip up and reel steadily so the blade stays on the surface. '
        'Wait a full second after a strike before setting the hook — fish often miss on the first blow.',
    icon: '💨',
  ),

  // ── Crankbaits ──
  TackleTypeInfo(
    name: 'Crankbait',
    category: 'Crankbait',
    description: 'A hard-bodied lure with a diving bill that wobbles and dives on retrieve.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Walleye', 'Northern Pike',
      'Striped Bass', 'White Bass',
    ],
    tips: 'Match the diving depth to the water — shallow divers (1-2m) for banks, '
        'deep divers (4-8m) for drop-offs. Use square-bill crankbaits around rocks and wood '
        '(they deflect off cover). Crankbaits work best when ticking the bottom — adjust retrieve speed.',
    icon: '🏊',
  ),
  TackleTypeInfo(
    name: 'Lipless Crankbait',
    category: 'Crankbait',
    description: 'A vibrating, sinking lure with no diving bill — straight retrieve or yo-yo.',
    targetSpecies: [
      'Largemouth Bass', 'Striped Bass', 'White Bass',
      'Walleye', 'Redfish',
    ],
    tips: 'Cast and let it sink to the desired depth, then reel with a steady cadence. '
        'Yo-yo it by lifting the rod tip and letting it fall back — strikes often come on the fall. '
        'Great for covering water fast in spring and fall.',
    icon: '📳',
  ),

  // ── Jigs ──
  TackleTypeInfo(
    name: 'Jig',
    category: 'Jig',
    description: 'A lead head with a hook, dressed with a skirt or soft plastic trailer.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Walleye',
      'Northern Pike', 'Channel Catfish', 'Blue Catfish',
    ],
    tips: 'Fish jigs slowly — drag, hop, or swim them along the bottom. '
        'Use a pork or plastic trailer to add bulk and scent. '
        'Fluorocarbon line improves sensitivity for feeling subtle bites. '
        'Jigs excel in cold water when fish are sluggish.',
    icon: '🪨',
  ),
  TackleTypeInfo(
    name: 'Football Jig',
    category: 'Jig',
    description: 'A jig with a wide, football-shaped head designed for rocky bottoms.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Spotted Bass',
    ],
    tips: 'Drag it slowly across rock piles, gravel points, and chunk rock banks. '
        'The football head keeps the hook upright. Pair with a crawfish-trailer for best results. '
        'Use 15-20 lb fluorocarbon line.',
    icon: '⚽',
  ),
  TackleTypeInfo(
    name: 'Finesse Jig',
    category: 'Jig',
    description: 'A compact, lighter jig for clear water and pressured fish.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Crappie',
    ],
    tips: 'Use a smaller profile trailer (2.5-3"). Fish on light line (8-12 lb). '
        'Skip under docks and overhanging branches. Dead-stick it — let it sit motionless '
        'for 10-15 seconds between hops.',
    icon: '🪶',
  ),

  // ── Soft Plastics ──
  TackleTypeInfo(
    name: 'Plastic Worm',
    category: 'Soft Plastic',
    description: 'A soft plastic worm rigged Texas-style, Carolina-style, or on a jig head.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Spotted Bass',
      'Northern Pike', 'Channel Catfish',
    ],
    tips: 'Texas rig with a bullet weight for weedy areas. Carolina rig for open water. '
        'Drag slowly and pause frequently — bass often pick it up on the pause. '
        'Green pumpkin, watermelon, and black/blue are universal colors.',
    icon: '🐛',
  ),
  TackleTypeInfo(
    name: 'Soft Plastic Jerkbait',
    category: 'Soft Plastic',
    description: 'A paddle-tail or shad-shaped soft plastic on a jig head — swims on retrieve.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Striped Bass', 'Redfish',
      'Speckled Trout', 'Snook', 'Mahi Mahi',
    ],
    tips: 'Use a steady retrieve with occasional twitches. Paddle-tails produce vibration '
        'that fish feel with their lateral line. Match the size to the forage — 3" for panfish, '
        '5-6" for bass. Great for covering water quickly.',
    icon: '🐟',
  ),
  TackleTypeInfo(
    name: 'Creature Bait',
    category: 'Soft Plastic',
    description: 'An irregularly shaped soft plastic mimicking crawfish, lizards, or insects.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Spotted Bass',
    ],
    tips: 'Texas rig or Carolina rig with a moderate retrieve. '
        'Hop it along the bottom like a crawfish. Great around rocks, docks, and laydowns. '
        'Use a heavier weight (3/16 - 3/8 oz) for deeper water.',
    icon: '🦎',
  ),
  TackleTypeInfo(
    name: 'Drop Shot Rig',
    category: 'Soft Plastic',
    description: 'A weight below the hook with a soft plastic presented off the bottom.',
    targetSpecies: [
      'Smallmouth Bass', 'Largemouth Bass', 'Walleye', 'Yellow Perch',
      'Crappie',
    ],
    tips: 'Use finesse worms or minnow-shaped baits. The weight stays on the bottom while '
        'the bait suspends above it. Shake the rod tip to make the bait quiver. '
        'Ideal for deep, clear water and pressured fish. Light line (6-10 lb) recommended.',
    icon: '📏',
  ),

  // ── Topwater ──
  TackleTypeInfo(
    name: 'Popper',
    category: 'Topwater',
    description: 'A concave-faced lure that "pops" and chugs when twitched.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Northern Pike',
      'Striped Bass', 'Snook',
    ],
    tips: 'Work it with sharp rod-tip twitches followed by pauses. '
        'The pop creates a disturbance that draws fish up. Most strikes happen '
        'during the pause. Fish early morning, dusk, or overcast days.',
    icon: '💥',
  ),
  TackleTypeInfo(
    name: 'Walking Bait',
    category: 'Topwater',
    description: 'A cigar-shaped topwater lure that walks side-to-side with a zig-zag retrieve.',
    targetSpecies: [
      'Largemouth Bass', 'Smallmouth Bass', 'Striped Bass',
      'Snook', 'Redfish',
    ],
    tips: 'Walk-the-dog by twitching the rod tip down while reeling slack. '
        'Vary the cadence — fast then slow. Great for covering flats and open water. '
        'Trophy fish often prefer walking baits over other topwaters.',
    icon: '🚶',
  ),
  TackleTypeInfo(
    name: 'Frog',
    category: 'Topwater',
    description: 'A hollow-bodied weedless frog for fishing thick vegetation.',
    targetSpecies: [
      'Largemouth Bass', 'Northern Pike', 'Chain Pickerel',
    ],
    tips: 'Fish over lily pads, hydrilla, and matted vegetation. '
        'Walk it across the top of the pads and pause in openings. '
        'Wait 2-3 seconds after a blow-up before setting the hook. '
        'Use heavy braided line (50-65 lb) to pull fish out of cover.',
    icon: '🐸',
  ),

  // ── Spoons ──
  TackleTypeInfo(
    name: 'Spoon',
    category: 'Spoon',
    description: 'A concave metal lure that wobbles and flashes on retrieve.',
    targetSpecies: [
      'Northern Pike', 'Muskellunge', 'Walleye', 'Lake Trout',
      'Rainbow Trout', 'Brook Trout', 'Redfish', 'Bluefish',
    ],
    tips: 'Cast and let it flutter down on a semi-slack line — many strikes come on the fall. '
        'Retrieve steadily or with a lift-drop cadence. '
        'Nickel and gold are staple colors. Great for deep trolling and casting.',
    icon: '🥄',
  ),
  TackleTypeInfo(
    name: 'Jigging Spoon',
    category: 'Spoon',
    description: 'A heavy spoon designed for vertical jigging in deep water.',
    targetSpecies: [
      'Lake Trout', 'Walleye', 'Striped Bass', 'Bluefin Tuna',
    ],
    tips: 'Drop to the bottom, then lift the rod tip sharply and let the spoon flutter back. '
        'Strikes usually happen on the drop. Use braided line for better sensitivity. '
        'Add a strip of bait (minnow or cut bait) to trigger reluctant fish.',
    icon: '⬇️',
  ),

  // ── Live Bait Rigs ──
  TackleTypeInfo(
    name: 'Live Bait Rig',
    category: 'Live Bait',
    description: 'A hook and weight rig for presenting live bait like minnows, worms, or shrimp.',
    targetSpecies: [
      'Walleye', 'Channel Catfish', 'Blue Catfish', 'Crappie',
      'Yellow Perch', 'Redfish', 'Speckled Trout', 'Flounder',
    ],
    tips: 'Use a circle hook for better hook-up ratios and safer release. '
        'Add a slip sinker above a swivel so the fish can take the bait without feeling resistance. '
        'Match bait size to the target species — small minnows for panfish, large shiners for bass.',
    icon: '🪱',
  ),
  TackleTypeInfo(
    name: 'Carolina Rig',
    category: 'Live Bait',
    description: 'A weight slides on the main line above a swivel, with a leader and hook below.',
    targetSpecies: [
      'Largemouth Bass', 'Striped Bass', 'Redfish', 'Flounder',
    ],
    tips: 'Drag it slowly across flats and points. The weight ticks along the bottom '
        'while the bait floats above. Use a 2-4 ft leader. Great for covering water '
        'and fishing soft plastics in open water.',
    icon: '🔗',
  ),

  // ── Ice Fishing ──
  TackleTypeInfo(
    name: 'Ice Jig',
    category: 'Ice Fishing',
    description: 'A small, lightweight jig for ice fishing, often tipped with a wax worm or minnow.',
    targetSpecies: [
      'Yellow Perch', 'Walleye', 'Crappie', 'Bluegill', 'Lake Trout',
    ],
    tips: 'Use ultra-light action rods. Pound the bottom to create a puff of sediment, '
        'then let the jig sit — fish are attracted to the commotion. '
        'Tip with a wax worm, spike, or small minnow. Use a spring bobber for detecting light bites.',
    icon: '🧊',
  ),
  TackleTypeInfo(
    name: 'Tip-Up Rig',
    category: 'Ice Fishing',
    description: 'A mechanical flag rig that pops up when a fish takes the bait through the ice.',
    targetSpecies: [
      'Northern Pike', 'Walleye', 'Lake Trout', 'Chain Pickerel',
    ],
    tips: 'Set the bait 1-2 ft off the bottom using a float. Use live shiners or suckers. '
        'When the flag pops, wait a few seconds before running to the hole — '
        'the fish needs time to turn the bait. Set the hook firmly.',
    icon: '🚩',
  ),

  // ── Fly Fishing ──
  TackleTypeInfo(
    name: 'Dry Fly',
    category: 'Fly Fishing',
    description: 'A floating fly that imitates an adult insect on the water surface.',
    targetSpecies: [
      'Rainbow Trout', 'Brown Trout', 'Brook Trout', 'Cutthroat Trout',
      'Arctic Grayling',
    ],
    tips: 'Match the hatch — observe what insects are emerging and choose a fly of similar size and colour. '
        'Cast upstream and let the fly drift naturally. Set the hook gently — trout have soft mouths. '
        'Use a 4-6 wt rod for most trout streams.',
    icon: '🪰',
  ),
  TackleTypeInfo(
    name: 'Nymph',
    category: 'Fly Fishing',
    description: 'A weighted subsurface fly imitating aquatic insect larvae.',
    targetSpecies: [
      'Rainbow Trout', 'Brown Trout', 'Brook Trout', 'Steelhead',
    ],
    tips: 'Use an indicator (bobber) above the nymph to detect strikes. '
        'Add split shot to get the fly down to the fish. '
        'Dead-drift nymphs through likely holding water — seams, pools, and runs. '
        'Pheasant Tail and Hare\'s Ear are universal patterns.',
    icon: '🪰',
  ),
  TackleTypeInfo(
    name: 'Streamer',
    category: 'Fly Fishing',
    description: 'A larger fly that imitates baitfish, leeches, or crayfish.',
    targetSpecies: [
      'Rainbow Trout', 'Brown Trout', 'Northern Pike',
      'Muskellunge', 'Smallmouth Bass', 'Striped Bass',
    ],
    tips: 'Strip the line in short, sharp pulls to imitate fleeing baitfish. '
        'Use sinking tip lines to get deeper. Streamers are great for covering water '
        'and triggering reaction strikes from large fish. Use a 6-8 wt rod for big streamers.',
    icon: '🐟',
  ),

  // ── Saltwater ──
  TackleTypeInfo(
    name: 'Popping Cork Rig',
    category: 'Saltwater',
    description: 'A floating cork with a concave face that pops on retrieve, with a leader and bait below.',
    targetSpecies: [
      'Redfish', 'Speckled Trout', 'Snook', 'Flounder',
    ],
    tips: 'Pop the cork in a steady rhythm — pop-pop-pause. '
        'The noise attracts fish while the bait below is presented naturally. '
        'Use live shrimp or soft plastics below the cork. '
        'Incoming tide over grass flats is prime time.',
    icon: '🪸',
  ),
  TackleTypeInfo(
    name: 'Bucktail Jig',
    category: 'Saltwater',
    description: 'A lead-head jig with bucktail hair dressing — classic saltwater lure.',
    targetSpecies: [
      'Striped Bass', 'Bluefish', 'Flounder', 'Redfish',
      'Cobia', 'King Mackerel',
    ],
    tips: 'Hop it along the bottom or swim it at mid-depth. '
        'White is the most universal colour. '
        'Add a soft plastic trailer or strip bait for extra attraction. '
        'Bucktails work year-round in both surf and bays.',
    icon: '🪮',
  ),
  TackleTypeInfo(
    name: 'Trolling Spoon',
    category: 'Saltwater',
    description: 'A large metal spoon designed for trolling behind a boat.',
    targetSpecies: [
      'King Mackerel', 'Spanish Mackerel', 'Mahi Mahi',
      'Bluefin Tuna', 'Yellowfin Tuna', 'Sailfish',
    ],
    tips: 'Troll at 5-8 knots behind in-line Planers or downriggers. '
        'Use a wire leader for toothy fish like mackerel. '
        'Vary trolling speed and distance from the boat until you find the strike zone. '
        'Match spoon size to target species — smaller for Spanish mackerel, larger for tuna.',
    icon: '🚤',
  ),
];
