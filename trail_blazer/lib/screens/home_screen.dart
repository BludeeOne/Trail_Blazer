// Home screen – lists nearby trails and lets you tap a card to view the full route

import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../helpers/trail.dart';
import '../helpers/trail_api.dart';
import 'trail_detail_screen.dart';
import 'map_screen.dart';
import 'account_screen.dart';

const TrailGreenColor = Color.fromARGB(255, 8, 37, 24);

class TrailBlazerHome extends StatefulWidget {
  const TrailBlazerHome({Key? key}) : super(key: key);

  @override
  State<TrailBlazerHome> createState() => _TrailBlazerHomeState();
}

class _TrailBlazerHomeState extends State<TrailBlazerHome> {
  int _bottomIndex = 0;
  List<Trail> _nearbyTrails = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchLocationAndTrails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationAndTrails() async {
    try {
      final location = Location();
      if (!await location.serviceEnabled() &&
          !await location.requestService()) {
        throw Exception('Location services disabled');
      }
      PermissionStatus p = await location.hasPermission();
      if (p == PermissionStatus.denied &&
          (p = await location.requestPermission()) !=
              PermissionStatus.granted) {
        throw Exception('Location permission denied');
      }
      final locData = await location.getLocation();
      final trails = await TrailApiService.fetchNearbyTrails(
        lat: locData.latitude ?? 39.7285,
        lng: locData.longitude ?? -121.8375,
      );
      setState(() {
        _nearbyTrails = trails;
        _isLoading = false;
      });
    } catch (_) {
      final trails = await TrailApiService.fetchNearbyTrails(
        lat: 39.7285,
        lng: -121.8375,
      );
      setState(() {
        _nearbyTrails = trails;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _tabs[_bottomIndex]),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _navTab(0, Icons.home, LineIcons.home),
              _navTab(1, Icons.map, LineIcons.map),
              _navTab(2, Icons.person, LineIcons.user),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navTab(int index, IconData active, IconData inactive) =>
      GestureDetector(
        onTap: () => setState(() => _bottomIndex = index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _bottomIndex == index ? active : inactive,
              size: 32,
              color: _bottomIndex == index ? TrailGreenColor : Colors.grey,
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 24,
              color:
                  _bottomIndex == index ? TrailGreenColor : Colors.transparent,
            ),
          ],
        ),
      );

  List<Widget> get _tabs => [
    _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _nearbyTrails.isEmpty
        ? const Center(child: Text('No trails found nearby.'))
        : _buildTrailGrid(),
    const MapScreen(),
    const AccountScreen(),
  ];

  Widget _buildTrailGrid() {
    final filtered = _nearbyTrails.where(
      (t) => t.name.toLowerCase().contains(_searchQuery.toLowerCase()),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(),
          const SizedBox(height: 24),
          const Text(
            "Let's go hiking!",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _searchBar(),
          const SizedBox(height: 24),
          const Text(
            'Nearby Hiking Trails',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 16),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.7,
            children: filtered.map(_buildTrailCard).toList(),
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
    children: [
      Expanded(
        child: IconButton(
          icon: const Icon(Icons.apps),
          color: TrailGreenColor,
          onPressed: () {},
        ),
      ),
      const Expanded(
        flex: 4,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, color: TrailGreenColor),
            SizedBox(width: 8),
            Text('Nearby Trails'),
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
  );

  Widget _searchBar() => Container(
    height: 52,
    decoration: BoxDecoration(
      color: Colors.grey[300],
      borderRadius: BorderRadius.circular(8),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: TextField(
      controller: _searchController,
      onChanged: (v) => setState(() => _searchQuery = v),
      decoration: const InputDecoration(
        icon: Icon(Icons.search),
        hintText: 'Search trails',
        border: InputBorder.none,
      ),
    ),
  );

  Widget _buildTrailCard(Trail trail) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => MapScreen(
                  trailPoints: [LatLng(trail.lat, trail.lng)],
                  trailName: trail.name,
                ),
          ),
        );
      },

      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(
              trail.photoUrl ??
                  'https://cdn.pixabay.com/photo/2016/11/20/08/17/squirrel-1842152__340.jpg',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(flex: 6, child: SizedBox()),
            Expanded(
              flex: 4,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        trail.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      trail.city,
                      style: const TextStyle(color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (trail.description != null)
                      Flexible(
                        child: Text(
                          trail.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    if (trail.distance > 0 || trail.elevationGain > 0)
                      Text(
                        '${trail.distance} km · ${trail.elevationGain} m',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
