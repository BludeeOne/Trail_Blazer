import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../helpers/trail.dart';

class TrailDetailScreen extends StatefulWidget {
  final Trail? trail;
  final DocumentSnapshot? firestoreTrail;

  const TrailDetailScreen({super.key, this.trail, this.firestoreTrail});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  bool _isFavourite = false;
  bool _checkingFavourite = true;

  CollectionReference<Map<String, dynamic>> get _favCollection {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favoriteTrails');
  }

  @override
  void initState() {
    super.initState();
    if (widget.trail != null) {
      _checkIfFavourite();
    } else {
      _checkingFavourite = false;
    }
  }

  Future<void> _checkIfFavourite() async {
    final snap =
        await _favCollection
            .where('name', isEqualTo: widget.trail!.name)
            .limit(1)
            .get();
    setState(() {
      _isFavourite = snap.docs.isNotEmpty;
      _checkingFavourite = false;
    });
  }

  Future<void> _toggleFavourite() async {
    if (widget.trail == null) return; //api trails

    setState(() => _checkingFavourite = true);

    final existing =
        await _favCollection
            .where('name', isEqualTo: widget.trail!.name)
            .limit(1)
            .get();

    if (existing.docs.isNotEmpty) {
      await _favCollection.doc(existing.docs.first.id).delete();
      _isFavourite = false;
    } else {
      await _favCollection.add(widget.trail!.toMap());
      _isFavourite = true;
    }

    if (mounted) {
      setState(() => _checkingFavourite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavourite ? 'Added to favourites.' : 'Removed from favourites.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trail != null) {
      final trail = widget.trail!;
      return Scaffold(
        appBar: AppBar(
          title: Text(trail.name),
          backgroundColor: const Color(0xff297653),
          actions: [
            if (_checkingFavourite)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                icon: Icon(
                  _isFavourite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.redAccent,
                ),
                onPressed: _toggleFavourite,
              ),
          ],
        ),
        body: ListView(
          children: [
            if (trail.photoUrl != null)
              Image.network(trail.photoUrl!, height: 250, fit: BoxFit.cover),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.green),
              title: Text(trail.city),
            ),
            if (trail.description != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  trail.description!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            if (trail.distance > 0 || trail.elevationGain > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    if (trail.distance > 0)
                      Text(
                        "${trail.distance.toStringAsFixed(1)} km",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    if (trail.elevationGain > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          "${trail.elevationGain.toStringAsFixed(0)} m gain",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                  ],
                ),
              ),
            if (trail.directions != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Directions:\n${trail.directions!}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    //firestore trails
    final trailData = widget.firestoreTrail!.data() as Map<String, dynamic>;
    final coordinates = List<Map<String, dynamic>>.from(
      trailData['coordinates'] ?? [],
    );
    final startTime = (trailData['startTime'] as Timestamp).toDate();
    final endTime =
        trailData.containsKey('endTime')
            ? (trailData['endTime'] as Timestamp).toDate()
            : null;
    final photos =
        trailData.containsKey('photos')
            ? List<String>.from(trailData['photos'])
            : [];
    final trailName = trailData['trailName'] ?? 'Unnamed Trail';

    final List<LatLng> trailPoints =
        coordinates.map((point) {
          return LatLng(point['latitude'], point['longitude']);
        }).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 28, 4, 33),
      appBar: AppBar(
        title: Text(trailName),
        backgroundColor: const Color.fromARGB(255, 6, 55, 21),
      ),
      body:
          trailPoints.isEmpty
              ? const Center(child: Text('No trail data found.'))
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
                    leading: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                    ),
                    title: Text(
                      'Started: ${startTime.toLocal()}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  if (endTime != null)
                    ListTile(
                      leading: const Icon(Icons.flag, color: Colors.orange),
                      title: Text(
                        'Ended: ${endTime.toLocal()}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  const Divider(color: Colors.orange),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Trail Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  photos.isEmpty
                      ? const Center(
                        child: Text(
                          'No photos uploaded.',
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                      : SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
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
