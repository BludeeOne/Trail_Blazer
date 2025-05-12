import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

class TrailBlazerApp extends StatelessWidget {
  const TrailBlazerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TrailBlazerHome()
    );
  }
}
