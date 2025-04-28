import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Form Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const UserFormScreen(),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  const UserFormScreen({super.key});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _favoriteColorController = TextEditingController();
  final TextEditingController _luckyNumberController = TextEditingController();
  bool _subscribeNewsletter = false;

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String favoriteColor = _favoriteColorController.text.trim();
      final int luckyNumber =
          int.tryParse(_luckyNumberController.text.trim()) ?? 0;

      await _usersCollection.doc('userData').set({
        'favoriteColor': favoriteColor, // String
        'luckyNumber': luckyNumber,     // int
        'subscribeNewsletter': _subscribeNewsletter, // bool
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data submitted successfully!')),
      );

      _favoriteColorController.clear();
      _luckyNumberController.clear();
      setState(() {
        _subscribeNewsletter = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Form')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Favorite Color Input (String)
                  TextFormField(
                    controller: _favoriteColorController,
                    decoration: const InputDecoration(
                      labelText: 'Favorite Color!',
                      hintText: 'Enter your favorite color :)',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a color';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  //lucky num input (int)
                  TextFormField(
                    controller: _luckyNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Lucky Number',
                      hintText: 'Enter your lucky number!',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a number';
                      }
                      if (int.tryParse(value) == null) {
                        return 'You and I both know thats not a real number';
                      }
		      if (value == 666) {
			return 'That is NOT a lucky number...thats evil...';
		      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
		  //newsletter switch (bool)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subscribe to Mysterious Newsletter'),
                      Switch(
                        value: _subscribeNewsletter,
                        onChanged: (bool newValue) {
                          setState(() {
                            _subscribeNewsletter = newValue;
                          });
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

	    //firestore data storage
            const Text(
              'Stored Data from Firestore:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            StreamBuilder<DocumentSnapshot>(
              stream: _usersCollection.doc('userData').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                if (!snapshot.data!.exists) {
                  return const Text('No data submitted yet.');
                }

                final docData = snapshot.data!;
                final favoriteColor = docData.data() != null
                    ? docData.get('favoriteColor') ?? 'N/A'
                    : 'N/A';
                final luckyNumber = docData.data() != null
                    ? docData.get('luckyNumber') ?? 'N/A'
                    : 'N/A';
                final isSubscribed = docData.data() != null
                    ? docData.get('subscribeNewsletter') ?? false
                    : false;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Favorite Color: $favoriteColor'),
                    Text('Lucky Number: $luckyNumber'),
                    Text('Subscribed to Newsletter? ${isSubscribed ? "Yes" : "No"}'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

