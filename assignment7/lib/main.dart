import 'dart:io' show File; // Only used for mobile
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraLocationApp(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CameraLocationApp extends StatefulWidget {
  const CameraLocationApp({super.key});

  @override
  _CameraLocationAppState createState() => _CameraLocationAppState();
}

class _CameraLocationAppState extends State<CameraLocationApp> {
  List<XFile> photos = [];
  String locationText = "Fetching location...";

  @override
  void initState() {
    super.initState();
    fetchLocation();
  }

  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          locationText = "Location services are disabled.";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            locationText = "Location permissions are denied.";
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          locationText = "Location permissions are permanently denied.";
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        locationText = "Lat: ${position.latitude}, Lon: ${position.longitude}";
      });
    } catch (e) {
      setState(() {
        locationText = "Error retrieving location.";
      });
    }
  }

  Future<void> takePhoto() async {
    final camera = cameras.first;
    final controller = CameraController(camera, ResolutionPreset.medium);

    await controller.initialize();
    final image = await controller.takePicture();

    setState(() {
      photos.add(image);
    });

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Camera & Location App")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Current Location: $locationText"),
          ),
          ElevatedButton(
            onPressed: takePhoto,
            child: Text("Take Photo"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: kIsWeb
                      ? Image.network(photo.path)
                      : Image.file(File(photo.path)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

