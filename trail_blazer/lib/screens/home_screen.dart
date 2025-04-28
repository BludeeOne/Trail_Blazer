import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Trails')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('trails')
            .where('isComplete', isEqualTo: true)
            .orderBy('startTime', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No trails found.'));
          }

          final trails = snapshot.data!.docs;

          return ListView.builder(
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trail = trails[index];
              final startTime = (trail['startTime'] as Timestamp).toDate();
              final photos = trail.data().toString().contains('photos') ? List<String>.from(trail['photos']) : [];

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  leading: photos.isNotEmpty
                      ? Image.network(photos[0], width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.map),
                  title: Text('Trail: ${trail.id.substring(0, 6)}...'),
                  subtitle: Text('Started: ${startTime.toLocal()}'),
                  onTap: () {
                    // Later: Navigate to Trail Detail Screen
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
