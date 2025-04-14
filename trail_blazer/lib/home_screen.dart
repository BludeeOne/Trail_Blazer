import 'package:flutter/material.dart';

class Trail {
  final String name;
  final double distance;
  final double elevationGain;
  final String location;

  Trail({
    required this.name,
    required this.distance,
    required this.elevationGain,
    required this.location,
  });

  factory Trail.fromMap(Map<String, dynamic> data) {
    return Trail(
      name: data['name'],
      distance: data['distance'].toDouble(),
      elevationGain: data['elevationGain'].toDouble(),
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'distance': distance,
      'elevationGain': elevationGain,
      'location': location,
    };
  }
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    SavedTrailsScreen(),
    PlaceholderScreen(title: 'Map'),
    PlaceholderScreen(title: 'Search'),
    PlaceholderScreen(title: 'User'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'User'),
        ],
      ),
    );
  }
}

class SavedTrailsScreen extends StatelessWidget {
  const SavedTrailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trails = [
      Trail(name: 'Morning Run - Bidwell Park', distance: 3.2, elevationGain: 120, location: 'Chico, CA'),
      Trail(name: 'Sunset Hike - Lassen Trail', distance: 5.8, elevationGain: 350, location: 'Lassen Volcanic Park'),
      Trail(name: 'Weekend Ride - River Path', distance: 12.4, elevationGain: 90, location: 'Sacramento River'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Trails')),
      body: ListView.builder(
        itemCount: trails.length,
        itemBuilder: (context, index) {
          final trail = trails[index];
          return ListTile(
            leading: const Icon(Icons.terrain),
            title: Text(trail.name),
            subtitle: Text(
              'Distance: ${trail.distance} mi | Elevation: ${trail.elevationGain} ft\nLocation: ${trail.location}',
            ),
            isThreeLine: true,
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate to detail screen (future feature)
            },
          );
        },
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('$title Screen'));
  }
}

