import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/trail.dart';

class TrailDetailScreen extends StatelessWidget {
  final DocumentSnapshot? firestoreTrail;
  final Trail? trail;

  const TrailDetailScreen({super.key, this.firestoreTrail, this.trail});

  @override
  Widget build(BuildContext context) {
    // Render mock trail if provided
    if (trail != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(trail!.name),
          backgroundColor: const Color(0xff297653),
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 240,
              child: Image.network(
                'https://cdn.pixabay.com/photo/2018/04/03/20/29/forest-3287976_960_720.jpg',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text(trail!.location),
            ),
            ListTile(
              leading: const Icon(Icons.directions_walk, color: Colors.green),
              title: Text('Distance: ${trail!.distance} km'),
            ),
            ListTile(
              leading: const Icon(Icons.terrain, color: Colors.green),
              title: Text('Elevation Gain: ${trail!.elevationGain} m'),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'This is a mock trail. No map data or photos available.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    // Otherwise, fall back to Firestore-based trail rendering
    final trailData = firestoreTrail!.data() as Map<String, dynamic>;
    final coordinates = List<Map<String, dynamic>>.from(trailData['coordinates'] ?? []);
    final startTime = (trailData['startTime'] as Timestamp).toDate();
    final endTime = trailData.containsKey('endTime') ? (trailData['endTime'] as Timestamp).toDate() : null;
    final photos = trailData.containsKey('photos') ? List<String>.from(trailData['photos']) : [];
    final trailName = trailData['trailName'] ?? 'Unnamed Trail';

    final List<LatLng> trailPoints = coordinates.map((point) {
      return LatLng(point['latitude'], point['longitude']);
    }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 4, 33),
      appBar: AppBar(
        title: Text(trailName),
        backgroundColor: const Color.fromARGB(255, 6, 55, 21),
      ),
      body: trailPoints.isEmpty
          ? const Center(child: Text('No trail data found.', style: TextStyle(color: Colors.white)))
          : ListView(
              children: [
                SizedBox(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: trailPoints.first,
                      zoom: 16,
                    ),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId('trail_path'),
                        points: trailPoints,
                        color: Colors.orange,
                        width: 5,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('start'),
                        position: trailPoints.first,
                        infoWindow: const InfoWindow(title: 'Start'),
                      ),
                      if (trailPoints.length > 1)
                        Marker(
                          markerId: const MarkerId('end'),
                          position: trailPoints.last,
                          infoWindow: const InfoWindow(title: 'End'),
                        ),
                    },
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.orange),
                  title: Text('Started: ${startTime.toLocal()}',
                      style: const TextStyle(color: Colors.white)),
                ),
                if (endTime != null)
                  ListTile(
                    leading: const Icon(Icons.flag, color: Colors.orange),
                    title: Text('Ended: ${endTime.toLocal()}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                const Divider(color: Colors.orange),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'Trail Photos',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                photos.isEmpty
                    ? const Center(
                        child: Text('No photos uploaded.', style: TextStyle(color: Colors.white70)))
                    : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Image.network(photos[index], height: 180),
                            );
                          },
                        ),
                      ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}