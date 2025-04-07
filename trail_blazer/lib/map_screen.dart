import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng _currentPosition = LatLng(37.7749, -122.4194); //i just set it to sf since thats the biggest city i know

  @override
  void initState() {
    super.initState();
    _locateUser();
  }

  Future<void> _locateUser() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _controller?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentPosition, 15),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Live Map'),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _currentPosition,
          zoom: 14,
        ),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (controller) => _controller = controller,
      ),
    );
  }
}

