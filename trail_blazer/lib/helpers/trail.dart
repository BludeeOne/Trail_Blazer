import 'package:cloud_firestore/cloud_firestore.dart';

class Trail {
  final int id;
  final String name;
  final String city;
  final String address;
  final double lat;
  final double lng;
  final String surface;
  final int difficulty;
  final double distance;
  final double elevationGain;
  final String? description;
  final String? photoUrl;
  final String? directions;

  Trail({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.lat,
    required this.lng,
    required this.surface,
    required this.difficulty,
    required this.distance,
    required this.elevationGain,
    this.description,
    this.photoUrl,
    this.directions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'address': address,
      'lat': lat,
      'lng': lng,
      'surface': surface,
      'difficulty': difficulty,
      'distance': distance,
      'elevationGain': elevationGain,
      'description': description,
      'photoUrl': photoUrl,
      'directions': directions,
    };
  }

  factory Trail.fromJson(Map<String, dynamic> json) {
    final distance = _calculateTotalDistance(json['loops']);
    final difficulty = json['difficulty'] ?? 1;

    return Trail(
      id: json['id'],
      name: json['name'],
      city: json['city'],
      address: json['address'],
      lat: double.parse(json['lat']),
      lng: double.parse(json['lng']),
      surface: json['surface'],
      difficulty: difficulty,
      distance: distance,
      elevationGain: estimateElevationGain(distance, difficulty),
      description: Uri.decodeFull(json['desc']),
      photoUrl: json['thumbURL'],
      directions: json['address'], // Using address as fallback directions
    );
  }

  /// Creates a Trail from a Firestore document.
  static Trail fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final distance = (data['distance'] as num?)?.toDouble() ?? 0.0;
    final difficulty = data['difficulty'] ?? 1;

    return Trail(
      id: data['id'] ?? 0,
      name: data['name'] ?? 'Unnamed',
      city: data['city'] ?? 'Unknown',
      address: data['address'] ?? '',
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (data['lng'] as num?)?.toDouble() ?? 0.0,
      surface: data['surface'] ?? '',
      difficulty: difficulty,
      distance: distance,
      elevationGain: (data['elevationGain'] as num?)?.toDouble()
        ?? estimateElevationGain(distance, difficulty),
      description: data['description'],
      photoUrl: data['photoUrl'],
      directions: data['directions'],
    );
  }
}

double _calculateTotalDistance(Map<String, dynamic>? loops) {
  if (loops == null) return 0;
  double total = 0;
  for (final loop in loops.values) {
    final dist = double.tryParse(loop['distance']?.toString() ?? '');
    total += dist ?? 0;
  }
  return total;
}

double estimateElevationGain(double distance, int difficulty) {
  switch (difficulty) {
    case 1: return distance * 5;   // easy: 5m per km
    case 2: return distance * 15;  // medium: 15m per km
    case 3: return distance * 30;  // hard: 30m per km
    default: return distance * 10; // fallback
  }
}
