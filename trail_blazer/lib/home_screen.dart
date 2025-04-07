import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final List<String> trails = [
    'Morning Run - Bidwell Park',
    'Sunset Hike - Lassen Trail',
    'Weekend Ride - River Path'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trail Blazer'),
        actions: [
          IconButton(
            icon: Icon(Icons.map),
            onPressed: () {
              Navigator.pushNamed(context, '/map');
            },
          )
        ],
      ),
      body: ListView.builder(
        itemCount: trails.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.terrain),
            title: Text(trails[index]),
            subtitle: Text('Saved trail'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
            },
          );
        },
      ),
    );
  }
}

