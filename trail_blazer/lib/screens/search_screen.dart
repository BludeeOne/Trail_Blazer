import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final results = ['Waterfall Destination', 'Krater Trail', 'Mother Rock', 'Lake Murna'];
    return Scaffold(
      backgroundColor: Color.fromARGB(235, 51, 22, 234),
      appBar: AppBar(title: const Text('Search Trails')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.nature),
            title: Text(results[index]),
          );
        },
      ),
    );
  }
}

