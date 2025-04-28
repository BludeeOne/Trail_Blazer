import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Random Dog Facts',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: DogInfoScreen(),
    );
  }
}

class DogInfoScreen extends StatefulWidget {
  const DogInfoScreen({super.key});

  @override
  _DogInfoScreenState createState() => _DogInfoScreenState();
}

class _DogInfoScreenState extends State<DogInfoScreen> {
  String dogImageUrl = "";
  String dogFact = "Press the button to FETCH a dog fact!";
  bool isLoading = false;

  Future<void> fetchDogData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Fetch Random Dog Image
      final imageResponse = await http.get(Uri.parse("https://dog.ceo/api/breeds/image/random"));
      final imageData = jsonDecode(imageResponse.body);
      String newImageUrl = imageData["message"];

      // Fetch Random Dog Fact
      final factResponse = await http.get(Uri.parse("https://dogapi.dog/api/v2/facts"));
      final factData = jsonDecode(factResponse.body);
      String newFact = factData["data"][0]["attributes"]["body"];

      setState(() {
        dogImageUrl = newImageUrl;
        dogFact = newFact;
      });
    } catch (error) {
      setState(() {
        dogFact = "Failed to load data. Try again!";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dog Facts Dot Com")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              dogImageUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(dogImageUrl, height: 250, fit: BoxFit.cover),
                    )
                  : Container(height: 250, color: Colors.grey[100], child: Center(child: Text("No image yet"))),
              SizedBox(height: 20),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(dogFact, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                ),
              ),
              SizedBox(height: 25),
              ElevatedButton(
                onPressed: isLoading ? null : fetchDogData,
                child: isLoading ? CircularProgressIndicator() : Text("Fetch New Dog Info"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

