import 'package:flutter/material.dart';

class TrailRecordScreen extends StatelessWidget {
  const TrailRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(197, 142, 5, 5),
      appBar: AppBar(title: const Text('Trail Recording')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              children: [
                Text('Time: 1 hr 30 min', style: TextStyle(fontSize: 24)),
                Text('Elevation Gain: 200 ft', style: TextStyle(fontSize: 18)),
              ],
            ),
            ElevatedButton(
              onPressed: () {},
              child: const Text('End Trail'),
            ),
          ],
        ),
      ),
    );
  }
}

