class FishCounter {
  final int? id;
  final String angler;
  int count;

  FishCounter({
    this.id,
    required this.angler,
    this.count = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'angler': angler,
      'count': count,
    };
  }

  factory FishCounter.fromMap(Map<String, dynamic> map) {
    return FishCounter(
      id: map['id'] as int?,
      angler: map['angler'] as String,
      count: (map['count'] as int?) ?? 0,
    );
  }
}
