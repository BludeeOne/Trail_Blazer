import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import '../helpers/trail.dart';
import '../helpers/trail_api.dart';
import 'trail_detail_screen.dart';

Color TrailGreenColor = const Color(0xff297653);

class TrailBlazerHome extends StatefulWidget {
  TrailBlazerHome({Key? key}) : super(key: key);

  @override
  _TrailBlazerAppState createState() => _TrailBlazerAppState();
}

class _TrailBlazerAppState extends State<TrailBlazerHome> {
  int _bottomIndex = 0;
  List<Trail> _nearbyTrails = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocationAndTrails();
  }

  Future<void> _fetchLocationAndTrails() async {
    try {
      final location = Location();

      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locData = await location.getLocation();
      debugPrint('Lat: ${locData.latitude}, Lon: ${locData.longitude}');

      final trails = await TrailApiService.fetchNearbyHikingTrails(
        lat: 39.7285, // Chico
        lon: -121.8375,
);


      debugPrint('API returned ${trails.length} trails');

      setState(() {
        _nearbyTrails = trails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching trails: $e');
    }
  }

  List<Widget> get _widgetItems => [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _nearbyTrails.isEmpty
                ? const Center(child: Text('No trails found nearby.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: IconButton(
                                icon: Icon(Icons.apps),
                                color: TrailGreenColor,
                                onPressed: () {},
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.location_on, color: TrailGreenColor),
                                  SizedBox(width: 8),
                                  Text("Nearby Trails"),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: TrailGreenColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          "Let’s go hiking!",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: const TextField(
                            decoration: InputDecoration(
                              icon: Icon(Icons.search),
                              hintText: "Search trails...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text("Nearby Hiking Trails", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 16),
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.85,
                          children: _nearbyTrails.map((trail) {
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TrailDetailScreen(trail: trail),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      "https://cdn.pixabay.com/photo/2016/11/20/08/17/squirrel-1842152__340.jpg",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 6,
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            top: 8,
                                            right: 8,
                                            child: Icon(Icons.favorite_border, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.only(
                                            bottomLeft: Radius.circular(8),
                                            bottomRight: Radius.circular(8),
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(trail.name, style: TextStyle(fontWeight: FontWeight.bold)),
                                            SizedBox(height: 4),
                                            Text("${trail.distance} km · ${trail.elevationGain} m", style: TextStyle(color: Colors.grey)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
        Container(color: Colors.blue),
        Container(color: TrailGreenColor),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _widgetItems.elementAt(_bottomIndex)),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTabIcon(0, Icons.home, LineIcons.home),
              _buildTabIcon(1, Icons.map_outlined, LineIcons.map),
              _buildTabIcon(2, Icons.favorite, LineIcons.heart),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabIcon(int index, IconData active, IconData inactive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _bottomIndex = index;
        });
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _bottomIndex == index ? active : inactive,
            size: 32,
            color: _bottomIndex == index ? TrailGreenColor : Colors.grey,
          ),
          SizedBox(height: 8),
          Container(
            height: 3,
            width: 24,
            decoration: BoxDecoration(
              color: _bottomIndex == index ? TrailGreenColor : Colors.transparent,
            ),
          ),
        ],
      ),
    );
  }
}
