import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(235, 51, 22, 234),
      appBar: AppBar(title: const Text('Search Trails')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by trail name',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('trails')
                  .where('isComplete', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allTrails = snapshot.data!.docs;

                // Fuzzy filter trails locally
                final filteredTrails = allTrails.where((doc) {
                  final name = (doc.data() as Map<String, dynamic>)['trailName']?.toString().toLowerCase() ?? '';
                  return name.contains(_searchText.toLowerCase());
                }).toList();

                if (filteredTrails.isEmpty) {
                  return const Center(child: Text('No matching trails.'));
                }

                return ListView.builder(
                  itemCount: filteredTrails.length,
                  itemBuilder: (context, index) {
                    final trail = filteredTrails[index];
                    final name = (trail.data() as Map<String, dynamic>)['trailName'] ?? 'Unnamed Trail';
                    final photos = trail.data().toString().contains('photos')
                        ? List<String>.from((trail.data() as Map<String, dynamic>)['photos'])
                        : [];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: photos.isNotEmpty
                            ? Image.network(photos[0], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.landscape),
                        title: Text(name),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Later: go to Trail Detail
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
