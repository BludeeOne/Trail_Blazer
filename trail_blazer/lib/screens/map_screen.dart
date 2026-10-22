import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key, this.trailPoints, this.trailName})
    : super(key: key);

  final List<LatLng>? trailPoints;

  final String? trailName;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentLatLng;

  late final List<LatLng> _trailPoints =
      widget.trailPoints != null ? List.of(widget.trailPoints!) : <LatLng>[];

  final Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStream;

  bool get _liveTracking => widget.trailPoints == null;

  @override
  void initState() {
    super.initState();
    if (_liveTracking) {
      _initLocationTracking();
    } else if (_trailPoints.isNotEmpty) {
      _addStaticMarkers();
      _currentLatLng = _trailPoints.first;
    }
  }

  void _addStaticMarkers() {
    if (_trailPoints.isEmpty) return;

    _markers
      ..add(
        Marker(
          markerId: const MarkerId('start'),
          position: _trailPoints.first,
          infoWindow: const InfoWindow(title: 'Start'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      )
      ..add(
        Marker(
          markerId: const MarkerId('end'),
          position: _trailPoints.last,
          infoWindow: const InfoWindow(title: 'End'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
  }

  Future<void> _initLocationTracking() async {
    final permission = await Permission.location.request();
    if (!permission.isGranted) return;

    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    final start = LatLng(pos.latitude, pos.longitude);

    setState(() {
      _currentLatLng = start;
      _trailPoints.add(start);

      _markers
        ..add(
          Marker(
            markerId: const MarkerId('start'),
            position: start,
            infoWindow: const InfoWindow(title: 'Start'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          ),
        )
        ..add(
          Marker(
            markerId: const MarkerId('you'),
            position: start,
            infoWindow: const InfoWindow(title: 'You'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
    });

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((Position newPos) async {
      final next = LatLng(newPos.latitude, newPos.longitude);

      setState(() {
        _currentLatLng = next;
        _trailPoints.add(next);

        _markers.removeWhere((m) => m.markerId == const MarkerId('you'));
        _markers.add(
          Marker(
            markerId: const MarkerId('you'),
            position: next,
            infoWindow: const InfoWindow(title: 'You'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        );
      });

      final map = await _controller.future;
      map.animateCamera(CameraUpdate.newLatLng(next));
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.trailName ?? 'Map')),
      body:
          (_currentLatLng == null && _trailPoints.isEmpty)
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentLatLng ?? _trailPoints.first,
                  zoom: 16,
                ),
                myLocationEnabled: _liveTracking,
                myLocationButtonEnabled: true,
                markers: _markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('trail'),
                    color: Colors.blue,
                    width: 5,
                    points: _trailPoints,
                  ),
                },
                onMapCreated: (controller) => _controller.complete(controller),
              ),
    );
  }
}
