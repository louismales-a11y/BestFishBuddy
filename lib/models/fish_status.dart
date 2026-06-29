/// Tracks whether a fish species has been caught and/or mastered.
class FishStatus {
  final String speciesName;
  int caughtCount;
  bool isMaster;

  FishStatus({
    required this.speciesName,
    this.caughtCount = 0,
    this.isMaster = false,
  });

  Map<String, dynamic> toMap() => {
        'species_name': speciesName,
        'caught_count': caughtCount,
        'is_master': isMaster ? 1 : 0,
      };

  factory FishStatus.fromMap(Map<String, dynamic> map) => FishStatus(
        speciesName: map['species_name'] as String,
        caughtCount: map['caught_count'] as int? ?? 0,
        isMaster: (map['is_master'] as int? ?? 0) == 1,
      );
}
