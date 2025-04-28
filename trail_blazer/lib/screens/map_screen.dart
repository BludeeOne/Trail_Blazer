import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // If you want user-specific trails
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Location _location = Location();

  Future<void> _pickAndUploadPhoto() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null || _currentTrailId == null) return;

  final picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera); // or .gallery

  if (image == null) return;

  final File file = File(image.path);
  final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

  final ref = FirebaseStorage.instance
      .ref()
      .child('trail_photos')
      .child(user.uid)
      .child(_currentTrailId!)
      .child(fileName);

  final uploadTask = await ref.putFile(file);

  final downloadURL = await ref.getDownloadURL();

  await FirebaseFirestore.instance.collection('trails').doc(_currentTrailId).update({
    'photos': FieldValue.arrayUnion([downloadURL])
  });

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Photo uploaded!')),
  );
}


  LatLng? _currentPosition;
  final List<LatLng> _trailCoordinates = [];

  StreamSubscription<LocationData>? _locationSubscription;

  bool _isRecording = false;
  String? _currentTrailId;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    final locationData = await _location.getLocation();
    setState(() {
      _currentPosition = LatLng(locationData.latitude!, locationData.longitude!);
    });
  }

  Future<void> _startRecording() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in first.')));
      return;
    }

    // Create a new trail document
    final trailDoc = await FirebaseFirestore.instance.collection('trails').add({
      'userId': user.uid,
      'startTime': Timestamp.now(),
      'coordinates': [],
      'isComplete': false,
    });

    _currentTrailId = trailDoc.id;
    _trailCoordinates.clear();

    _locationSubscription = _location.onLocationChanged.listen((newLocation) {
      final newPos = LatLng(newLocation.latitude!, newLocation.longitude!);
      setState(() {
        _currentPosition = newPos;
        _trailCoordinates.add(newPos);
      });

      if (_currentTrailId != null) {
        FirebaseFirestore.instance.collection('trails').doc(_currentTrailId).update({
          'coordinates': FieldValue.arrayUnion([
            {
              'latitude': newLocation.latitude,
              'longitude': newLocation.longitude,
              'timestamp': Timestamp.now(),
            }
          ])
        });
      }
    });

    setState(() {
      _isRecording = true;
    });
  }

  Future<void> _stopRecording() async {
    _locationSubscription?.cancel();

    if (_currentTrailId != null) {
      await FirebaseFirestore.instance.collection('trails').doc(_currentTrailId).update({
        'endTime': Timestamp.now(),
        'isComplete': true,
      });
    }

    setState(() {
      _isRecording = false;
      _currentTrailId = null;
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trail Tracker Map')),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 17,
                  ),
                  
                  myLocationEnabled: true,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('trail'),
                      points: _trailCoordinates,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                  onMapCreated: (controller) {
                    _controller.complete(controller);
                  },
                ),
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: ElevatedButton.icon(
                    onPressed: _isRecording ? _pickAndUploadPhoto : null,
                    icon: Icon(Icons.camera_alt),
                    label: Text("Add Trail Photo"),
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                  onPressed: _isRecording ? _stopRecording : _startRecording,
                  child: Text(_isRecording ? 'Stop Recording' : 'Start Recording'),
                  ),
                ),
               ],
            ),
        );
  }
}

