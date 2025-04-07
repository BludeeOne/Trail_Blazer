import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'map_screen.dart';

void main() {
  runApp(TrailTrackerApp());
}

class TrailTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Blazer',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomeScreen(),
        '/map': (context) => MapScreen(),
      },
    );
  }
}

