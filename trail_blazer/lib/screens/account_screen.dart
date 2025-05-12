import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final options = ['Trails', 'Stats'];
    return Scaffold(
      backgroundColor: Colors.indigoAccent,
      appBar: AppBar(title: const Text('Account')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: options.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text(options[index]),
          );
        },
      ),
    );
  }
}

