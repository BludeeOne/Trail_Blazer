import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:final_project/helpers/trail.dart';


class SavedTrailsScreen extends StatelessWidget {
  const SavedTrailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trailsRef = FirebaseFirestore.instance.collection('trails');

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 6, 48, 20),
      appBar: AppBar(title: const Text('Saved Trails')),
      body: StreamBuilder<QuerySnapshot>(
        stream: trailsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong.'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final trails = snapshot.data!.docs
              .map((doc) => Trail.fromMap(doc.data() as Map<String, dynamic>))
              .toList();

          if (trails.isEmpty) {
            return const Center(child: Text('No trails saved yet.'));
          }

          return ListView.builder(
            itemCount: trails.length,
            itemBuilder: (context, index) {
              final trail = trails[index];
              return ListTile(
                leading: const Icon(Icons.terrain),
                title: Text(trail.name),
                subtitle: Text(
                    'Distance: ${trail.distance} mi | Elevation: ${trail.elevationGain} ft\nLocation: ${trail.location}'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }
}

