/// Tracks whether a fish species has been caught, mastered, or favorited.
class FishStatus {
  final String speciesName;
  int caughtCount;
  bool isMaster;
  bool isFavorite;

  FishStatus({
    required this.speciesName,
    this.caughtCount = 0,
    this.isMaster = false,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() => {
        'species_name': speciesName,
        'caught_count': caughtCount,
        'is_master': isMaster ? 1 : 0,
        'is_favorite': isFavorite ? 1 : 0,
      };

  factory FishStatus.fromMap(Map<String, dynamic> map) => FishStatus(
        speciesName: map['species_name'] as String,
        caughtCount: map['caught_count'] as int? ?? 0,
        isMaster: (map['is_master'] as int? ?? 0) == 1,
        isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      );
}
