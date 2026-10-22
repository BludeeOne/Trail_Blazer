import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'auth_gate.dart';


class TrailBlazerApp extends StatelessWidget {
  const TrailBlazerApp({super.key});

  @override
   Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Blazer',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AuthGate(),
    );
  }
}
