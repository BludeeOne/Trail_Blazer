import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/trail_record_screen.dart';
import 'screens/search_screen.dart';
import 'screens/account_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const TrailBlazerApp());
}

class TrailBlazerApp extends StatelessWidget {
  const TrailBlazerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trail Blazer',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepOrange,
      ),
      home: const RootNav(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MapScreen(),
    TrailRecordScreen(),
    SearchScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 6, 55, 21),
        unselectedItemColor: Color.fromARGB(255, 11, 98, 37),
        selectedItemColor: Color.fromARGB(255, 240, 146, 4),
        currentIndex: _index,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Important: 5 tabs
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_run), label: 'Record'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}



//good green for bottom bar maybe Color.fromARGB(195, 4, 33, 13),
//purple in similar shade Color.fromARGB(210, 28, 4, 33),
//maybe red for record Color.fromARGB(197, 142, 5, 5),