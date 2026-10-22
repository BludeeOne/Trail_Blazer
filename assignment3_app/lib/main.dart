import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment 3',
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  Color _backgroundColor = Colors.white;

  final Random _random = Random();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _changeBackgroundColor() {
    setState(() {
      _backgroundColor = Color.fromRGBO(
        _random.nextInt(256), // Red
        _random.nextInt(256), // Green
        _random.nextInt(256), // Blue
        1,                    // Opacity (1 = fully opaque)
      );
    });
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Info"),
          content: const Text("You pressed the info button!\nUnfortunately there's no info here..."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle1 = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: Colors.blue.shade900,
    );

    const textStyle2 = TextStyle(
      fontSize: 16,
      fontStyle: FontStyle.italic,
      color: Colors.black87,
    );

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Assignment 3'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Counter: $_counter', style: textStyle1),

            const SizedBox(height: 16),

            Text(
              'Press the buttons below to change the app!',
              style: textStyle2,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _incrementCounter,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('Increment!'),
            ),

            const SizedBox(height: 16),

            OutlinedButton(
              onPressed: _changeBackgroundColor,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.red, width: 3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.color_lens),
                  SizedBox(width: 8),
                  Text('Change Background'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            TextButton(
              onPressed: _showDialog,
              style: TextButton.styleFrom(
                foregroundColor: Colors.purple,
                textStyle: const TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.underline,
                ),
              ),
              child: const Icon(Icons.info),
            ),
          ],
        ),
      ),
    );
  }
}
