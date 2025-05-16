import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../helpers/trail.dart';

class TrailApiService {
  static const String _baseUrl = 'https://prescriptiontrails.org/api';

  static Future<List<Trail>> fetchNearbyTrails({
    required double lat,
    required double lng,
    int count = 20,
    int offset = 0,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/filter/?by=coord&lat=$lat&lng=$lng&offset=$offset&count=$count',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trails: ${response.statusCode}');
    }

    final data = json.decode(response.body);

    final List<dynamic> trailsJson = data['trails'] ?? [];

    debugPrint('Fetched ${trailsJson.length} trails near location');

    return trailsJson.map<Trail>((item) {
      final loops = item['loops'] as Map<String, dynamic>?;

      double totalDistance = 0;
      if (loops != null) {
        for (final loop in loops.values) {
          final distStr = loop['distance']?.toString();
          final dist = double.tryParse(distStr ?? '0') ?? 0;
          totalDistance += dist;
        }
      }

     return Trail(
  id: item['id'],
  name: item['name'] ?? 'Unnamed Trail',
  city: item['city'] ?? 'Unknown',
  address: item['address'] ?? 'No address',
  lat: double.tryParse(item['lat'] ?? '') ?? 0.0,
  lng: double.tryParse(item['lng'] ?? '') ?? 0.0,
  surface: item['surface'] ?? 'Unknown surface',
  difficulty: item['difficulty'] ?? 1,
  distance: totalDistance,
  elevationGain: estimateElevationGain(
    totalDistance,
    item['difficulty'] ?? 1,
  ),
  description: Uri.decodeFull(item['desc'] ?? ''),
  photoUrl: item['thumbURL'],
);


    }).toList();
  }
}
