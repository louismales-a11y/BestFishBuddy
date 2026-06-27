/// Fish species encyclopedia data.
class FishInfo {
  final String name;
  final String scientific;
  final String description;
  final String habitat;
  final String typicalLength;
  final String typicalWeight;
  final String record;
  final String season;
  final String icon;

  const FishInfo({
    required this.name, required this.scientific, required this.description,
    required this.habitat, required this.typicalLength, required this.typicalWeight,
    required this.record, required this.season, this.icon = '🐟',
  });
}

const List<FishInfo> fishEncyclopedia = [
  FishInfo(
    name: 'Bass (Largemouth)', scientific: 'Micropterus salmoides',
    description: 'North America\'s most popular game fish. Green with dark horizontal stripe. Prefers warm, vegetated lakes and slow rivers.',
    habitat: 'Warm lakes, ponds, reservoirs with weed beds', typicalLength: '30-50 cm', typicalWeight: '1-5 kg',
    record: '10.1 kg (Georgia, 1932)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Bass (Smallmouth)', scientific: 'Micropterus dolomieu',
    description: 'Bronze-green with vertical bars. Prefers cooler, clearer water than largemouth. Known for acrobatic fights.',
    habitat: 'Rocky lakes and rivers with current', typicalLength: '25-45 cm', typicalWeight: '1-3 kg',
    record: '5.4 kg (Kentucky, 1955)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Northern Pike', scientific: 'Esox lucius',
    description: 'Ambush predator with long body and duck-like snout. Olive green with yellow spots. Aggressive striker.',
    habitat: 'Weedy lakes, slow rivers, backwaters', typicalLength: '50-100 cm', typicalWeight: '2-10 kg',
    record: '24.9 kg (Germany, 1986)', season: 'Year-round', icon: '🐟',
  ),
  FishInfo(
    name: 'Muskellunge (Muskie)', scientific: 'Esox masquinongy',
    description: 'The largest pike family member. Elusive "fish of 10,000 casts." Bronze/silver with dark vertical bars.',
    habitat: 'Clear lakes and rivers with weed beds', typicalLength: '70-130 cm', typicalWeight: '5-20 kg',
    record: '31.8 kg (Wisconsin, 1949)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Walleye', scientific: 'Sander vitreus',
    description: 'Popular table fish with distinctive glassy eyes. Olive gold with white belly. Nocturnal feeder.',
    habitat: 'Deep lakes and rivers with gravel bottoms', typicalLength: '30-60 cm', typicalWeight: '1-4 kg',
    record: '11.3 kg (Tennessee, 1960)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Yellow Perch', scientific: 'Perca flavescens',
    description: 'Classic panfish with yellow-green body and dark vertical bars. Excellent eating. Travels in schools.',
    habitat: 'Lakes and slow rivers with clean water', typicalLength: '15-30 cm', typicalWeight: '0.1-0.5 kg',
    record: '1.9 kg (New Jersey, 1865)', season: 'Year-round', icon: '🐟',
  ),
  FishInfo(
    name: 'Rainbow Trout', scientific: 'Oncorhynchus mykiss',
    description: 'Beautiful fish with pink/red lateral stripe. Popular with fly fishermen. Both freshwater and steelhead (migratory) forms.',
    habitat: 'Cold, clear streams and deep lakes', typicalLength: '25-50 cm', typicalWeight: '0.5-3 kg',
    record: '21.3 kg (Canada, 2009)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Brook Trout', scientific: 'Salvelinus fontinalis',
    description: 'Canada\'s only native trout. Dark green with red spots and blue halos. White-edged fins. Needs pure cold water.',
    habitat: 'Small cold streams and spring-fed lakes', typicalLength: '20-40 cm', typicalWeight: '0.2-2 kg',
    record: '6.5 kg (Ontario, 1915)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Lake Trout', scientific: 'Salvelinus namaycush',
    description: 'Largest of the char family. Grey-green with pale spots. Lives in deep, cold lakes. Can live 40+ years.',
    habitat: 'Deep, cold lakes (prefers <10°C water)', typicalLength: '40-80 cm', typicalWeight: '2-10 kg',
    record: '32.6 kg (Northwest Territories, 1994)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Atlantic Salmon', scientific: 'Salmo salar',
    description: 'The "King of Fish." Silver with black spots. Anadromous (lives in ocean, spawns in rivers). Prized by anglers.',
    habitat: 'Atlantic Ocean, rivers from Connecticut to Quebec', typicalLength: '50-90 cm', typicalWeight: '3-10 kg',
    record: '35.8 kg (Norway, 1928)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Chinook Salmon', scientific: 'Oncorhynchus tshawytscha',
    description: 'Largest Pacific salmon. Also called King salmon. Spawns once then dies. Highly prized for sport and food.',
    habitat: 'Pacific Ocean, large rivers from California to Alaska', typicalLength: '60-100 cm', typicalWeight: '5-20 kg',
    record: '44.1 kg (Alaska, 1986)', season: 'Spring-Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Coho Salmon', scientific: 'Oncorhynchus kisutch',
    description: 'Silver salmon. Strong fighter that leaps frequently. Smaller than Chinook but equally prized.',
    habitat: 'Pacific Ocean, coastal rivers', typicalLength: '45-70 cm', typicalWeight: '3-8 kg',
    record: '14.1 kg (British Columbia, 2007)', season: 'Fall', icon: '🐟',
  ),
  FishInfo(
    name: 'Bluegill', scientific: 'Lepomis macrochirus',
    description: 'The classic sunfish. Deep blue body with dark ear flap. Perfect for kids and panfishing.',
    habitat: 'Warm weedy lakes and ponds', typicalLength: '15-25 cm', typicalWeight: '0.1-0.5 kg',
    record: '2.1 kg (Alabama, 1950)', season: 'Summer', icon: '🐟',
  ),
  FishInfo(
    name: 'Crappie', scientific: 'Pomoxis annularis/nigromaculatus',
    description: 'Silver-olive with dark spots. Two species: Black and White Crappie. Schooling fish, excellent table fare.',
    habitat: 'Lakes and slow rivers with cover', typicalLength: '20-30 cm', typicalWeight: '0.2-0.5 kg',
    record: '2.3 kg (Mississippi, 1957)', season: 'Spring', icon: '🐟',
  ),
  FishInfo(
    name: 'Catfish (Channel)', scientific: 'Ictalurus punctatus',
    description: 'Smooth-skinned with whiskers. Olive-brown with dark spots. Nocturnal bottom feeder. Excellent eating.',
    habitat: 'Rivers and lakes with muddy bottoms', typicalLength: '30-60 cm', typicalWeight: '1-5 kg',
    record: '26.3 kg (South Carolina, 1964)', season: 'Year-round', icon: '🐟',
  ),
];
