class Trail {
  final String name;
  final double distance;
  final double elevationGain;
  final String location;

  Trail({
    required this.name,
    required this.distance,
    required this.elevationGain,
    required this.location,
  });

  factory Trail.fromMap(Map<String, dynamic> data) {
    return Trail(
      name: data['name'] ?? '',
      distance: (data['distance'] ?? 0).toDouble(),
      elevationGain: (data['elevationGain'] ?? 0).toDouble(),
      location: data['location'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distance': distance,
      'elevationGain': elevationGain,
      'location': location,
    };
  }
}

