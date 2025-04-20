import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purpleAccent,
      appBar: AppBar(title: const Text('Saved Trails')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Saved Trails', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...['Death Canyon', 'Round Valley', 'Murder Rock'].map(
            (name) => Card(
              child: ListTile(
                title: Text(name),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Recommended Trails', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: Image.asset('assets/trail1.png', height: 100, fit: BoxFit.cover)),
              const SizedBox(width: 10),
              Expanded(child: Image.asset('assets/trail2.png', height: 100, fit: BoxFit.cover)),
            ],
          ),
        ],
      ),
    );
  }
}
