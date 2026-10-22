import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../helpers/trail.dart';
import '../helpers/trail_api.dart' as trail_api;

class TrailRecordScreen extends StatefulWidget {
  const TrailRecordScreen({Key? key}) : super(key: key);

  @override
  State<TrailRecordScreen> createState() => _TrailRecordScreenState();
}

class _TrailRecordScreenState extends State<TrailRecordScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<LatLng> _points = [];
  Timer? _timer;
  DateTime? _startTime;
  double _totalKm = 0;
  double _totalGain = 0;
  double? _prevAltitude;
  StreamSubscription<Position>? _posSub;

  @override
  void initState() {
    super.initState();
    _requestPermissionAndStart();
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _timer?.cancel();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionAndStart() async {
    final status = await Permission.location.request();
    if (!status.isGranted) return;

    _startTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));

    _posSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    ).listen((pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      if (_points.isNotEmpty) {
        final dist = Geolocator.distanceBetween(
          _points.last.latitude,
          _points.last.longitude,
          latLng.latitude,
          latLng.longitude,
        );
        _totalKm += dist / 1000.0;
      }
      if (_prevAltitude != null) {
        final gain = pos.altitude - _prevAltitude!;
        if (gain > 0) _totalGain += gain;
      }
      _prevAltitude = pos.altitude;
      setState(() => _points.add(latLng));
    });
  }

  Future<void> _endTrail() async {
    _posSub?.cancel();
    _timer?.cancel();
    if (_points.length < 2) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Trail too short to save.')));
      return;
    }

    final trail = Trail(
      id: DateTime.now().millisecondsSinceEpoch, // fake unique ID
      name: _nameController.text.isEmpty ? 'New Trail' : _nameController.text,
      city: 'Recorded',
      address: 'N/A',
      lat: _points.first.latitude,
      lng: _points.first.longitude,
      surface: 'unknown',
      distance: _totalKm,
      difficulty: 2,
      elevationGain: _totalGain,
      description: 'Recorded trail from Trail Blazer app.',
      photoUrl: null,
    );

    if (!mounted) return;
    Navigator.pop(context);
  }

  String _formatDuration() {
    if (_startTime == null) return '00:00:00';
    final diff = DateTime.now().difference(_startTime!);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final current = _points.isNotEmpty ? _points.last : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Trail Recording')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: current ?? const LatLng(37.7749, -122.4194),
                zoom: 15,
              ),
              polylines: {
                Polyline(
                  polylineId: const PolylineId('trail'),
                  color: Colors.blue,
                  width: 4,
                  points: _points,
                ),
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Trail name'),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Time: ${_formatDuration()}'),
                    Text('Distance: ${_totalKm.toStringAsFixed(2)} km'),
                    Text('Gain: ${_totalGain.toStringAsFixed(0)} m'),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _endTrail,
                  child: const Text('End Trail'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
