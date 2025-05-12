import 'dart:convert';
import 'package:http/http.dart' as http;
import '../helpers/trail.dart';

class TrailApiService {
  static const String _baseUrl = 'https://trailapi-trailapi.p.rapidapi.com/activity/';
  static const String _apiKey = '2c8e1a7ca3msh70e6148a0d53b07p11e7bejsn50c3ac7aff57';
  static const String _host = 'trailapi-trailapi.p.rapidapi.com';

  static Future<List<Trail>> fetchNearbyHikingTrails({
    required double lat,
    required double lon,
    int radiusMiles = 25,
    int limit = 20,
  }) async {
    final uri = Uri.parse(
  '$_baseUrl?lat=$lat&lon=$lon&radius=$radiusMiles&q-activities_activity_type_name_eq=hiking&limit=$limit'
);

    final response = await http.get(
      uri,
      headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': _host,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch trails: ${response.statusCode}');
    }

    final data = json.decode(response.body);
    if (!data.containsKey('data')) return [];

    final List<dynamic> activities = data['data'];
    //error check
    print('API returned ${activities.length} activities');

    return activities.map((item) {
      final name = item['name'] ?? 'Unnamed Trail';
      final location = item['city'] ?? 'Unknown';
      final double distance = double.tryParse(item['length']?.toString() ?? '') ?? 0;
      final double elevation = double.tryParse(item['elevation_gain']?.toString() ?? '') ?? 0;

      return Trail(
        name: name,
        location: location,
        distance: distance,
        elevationGain: elevation,
      );
    }).toList();
  }
}