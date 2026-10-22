// account_screen.dart – user stats dashboard
//displays the uesrs total elevstion gained in terms of stories climbed
//shows how far the user has walked total distnace

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../helpers/trail.dart';
import 'trail_detail_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late Future<_UserStats> _statsFuture;

  @override
  void initState() {
    super.initState();
    _statsFuture = _gatherStats();
  }

  Future<_UserStats> _gatherStats() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _UserStats.empty();
    }
    final uid = user.uid;

    final completedQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('trails')
            .where('completed', isEqualTo: true)
            .get();

    double totalElevation = 0;
    double totalDistance = 0;
    for (final doc in completedQuery.docs) {
      totalElevation += (doc['elevationGain'] ?? 0).toDouble();
      totalDistance += (doc['distance'] ?? 0).toDouble();
    }

    final favQuery =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('favoriteTrails')
            .get();

    final favourites = favQuery.docs
        .map((d) => Trail.fromFirestore(d))
        .toList(growable: false);

    return _UserStats(
      totalElevation: totalElevation,
      totalDistance: totalDistance,
      trailsCompleted: completedQuery.docs.length,
      favouriteTrails: favourites,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                // Return to first route (e.g. login/start screen)
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<_UserStats>(
        future: _statsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final stats = snapshot.data!;
          final storiesClimbed = (stats.totalElevation / 3.048).floor();
          final milesWalked = (stats.totalDistance / 1609.34).toStringAsFixed(
            2,
          );

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // stats cards
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    _StatCard(
                      label: 'Stories Climbed',
                      value: '$storiesClimbed',
                    ),
                    _StatCard(label: 'Distance (mi)', value: milesWalked),
                    _StatCard(
                      label: 'Trails Completed',
                      value: '${stats.trailsCompleted}',
                    ),
                  ],
                ),
                // favourite trails
                const SizedBox(height: 32),
                Text(
                  'Favorite Trails',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                if (stats.favouriteTrails.isEmpty)
                  const Text('No favourites yet.')
                else
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: stats.favouriteTrails.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final trail = stats.favouriteTrails[index];
                      return ListTile(
                        leading: const Icon(Icons.terrain),
                        title: Text(trail.name),
                        subtitle: Text(
                          '${(trail.distance / 1609.34).toStringAsFixed(2)} mi • ${trail.elevationGain.round()} ft',
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TrailDetailScreen(trail: trail),
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 120,
        height: 120,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserStats {
  final double totalElevation;
  final double totalDistance;
  final int trailsCompleted;
  final List<Trail> favouriteTrails;

  _UserStats({
    required this.totalElevation,
    required this.totalDistance,
    required this.trailsCompleted,
    required this.favouriteTrails,
  });

  factory _UserStats.empty() => _UserStats(
    totalElevation: 0,
    totalDistance: 0,
    trailsCompleted: 0,
    favouriteTrails: const [],
  );
}
