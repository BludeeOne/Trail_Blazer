import 'package:final_project/trail_blazer.dart';
import 'package:flutter/material.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized();
 // await Firebase.initializeApp();
  runApp(TrailBlazerApp());
}






/*class RootNav extends StatefulWidget {
  const RootNav({super.key});

  @override
  State<RootNav> createState() => _RootNavState();
}

class _RootNavState extends State<RootNav> {
  int _index = 0;

  final List<Widget> _screens = const [
    TrailBlazerApp(),
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
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
      ),
    );
  }
}

*/

//good green for bottom bar maybe Color.fromARGB(195, 4, 33, 13),
//purple in similar shade Color.fromARGB(210, 28, 4, 33),
//maybe red for record Color.fromARGB(197, 142, 5, 5),