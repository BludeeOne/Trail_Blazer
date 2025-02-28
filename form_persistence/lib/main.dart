import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FormPage(),
    );
  }
}

class FormPage extends StatefulWidget {
  @override
  _FormPageState createState() => _FormPageState();
}

class _FormPageState extends State<FormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String? _savedName;
  int? _savedAge;
  String? _favoriteColor;
  String? _savedColor;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _savedName = prefs.getString('name') ?? "Not Set";
      _savedAge = prefs.getInt('age') ?? 0;
      _savedColor = prefs.getString('color') ?? "Not Set";
    });
  }

  Future<void> _saveData() async {
    if (_formKey.currentState!.validate()) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', _nameController.text);
      await prefs.setInt('age', int.parse(_ageController.text));
      await prefs.setString('color', _favoriteColor ?? "Not Set");
      setState(() {
        _savedName = _nameController.text;
        _savedAge = int.parse(_ageController.text);
        _savedColor = _favoriteColor;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Data Saved Successfully!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Form")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: "Enter your Name"),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "bruh, you left this filed empty. Enter your name, or else...";
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _ageController,
                    decoration: InputDecoration(labelText: "Enter your Age"),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your age.";
                      }
                      if (int.tryParse(value) == null) {
                        return "Enter a VALID number, no funny business...";
                      }
                      return null;
                    },
                  ),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Select Your Favorite Color"),
                    items: ["Red", "Blue", "Green", "Yellow", "Black", "White"].map((color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _favoriteColor = value;
                      });
                    },
                    validator: (value) => value == null ? "Please select a color my friend :)" : null,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveData,
                    child: Text("Save"),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text("Saved Data:", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("Name: $_savedName", style: TextStyle(fontSize: 18)),
            Text("Age: $_savedAge", style: TextStyle(fontSize: 18)),
            Text("Favorite Color: $_savedColor", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
