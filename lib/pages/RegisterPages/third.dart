import 'package:flutter/material.dart';
import 'package:romanceradar/pages/RegisterPages/fourth.dart';

class ThirdScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String dob;
  final String address;
  final String phoneNumber;

  ThirdScreen({
    required this.name,
    required this.email,
    required this.password,
    required this.dob,
    required this.address,
    required this.phoneNumber,
  });

  @override
  _ThirdScreenState createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  List<String> hobbies = [];
  TextEditingController customHobbyController = TextEditingController();
  bool showCustomHobbyContainer = false;

  List<Map<String, dynamic>> predefinedHobbies = [
    {'name': 'Reading', 'icon': Icons.book, 'color': Colors.blue},
    {'name': 'Running', 'icon': Icons.directions_run, 'color': Colors.green},
    {'name': 'Cooking', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Traveling', 'icon': Icons.flight, 'color': Colors.purple},
    {'name': 'Photography', 'icon': Icons.camera, 'color': Colors.red},
    {'name': 'Gaming', 'icon': Icons.videogame_asset, 'color': Color.fromARGB(255, 245, 241, 4)},
    {'name': 'Painting', 'icon': Icons.palette, 'color': Colors.pink},
  ];

  Widget _buildPredefinedHobby(String hobby, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        _addToHobbiesList(hobby);
      },
      child: Container(
        margin: EdgeInsets.all(3.0),
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8.0),
            Text(hobby, style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedHobbyChip(String hobby) {
    return Chip(
      label: Text(hobby),
      onDeleted: () {
        _removeFromHobbiesList(hobby);
      },
      deleteIcon: Icon(Icons.cancel),
      backgroundColor: const Color.fromARGB(255, 209, 226, 235),
    );
  }

  void _addToHobbiesList(String hobby) {
    print('Added to hobbies list: $hobby');
    setState(() {
      hobbies.add(hobby);
    });
  }

  void _removeFromHobbiesList(String hobby) {
    print('Removed from hobbies list: $hobby');
    setState(() {
      hobbies.remove(hobby);
    });
  }

  bool validateForm() {
    if (hobbies.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Hobbies Required'),
            content: Text('Please select at least one hobby.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hobbies'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/hobbies.jpg',
                height: 200,
                width: 250,
              ),
              SizedBox(height: 10.0),
              Wrap(
                spacing: 1.0,
                runSpacing: 1.0,
                children: predefinedHobbies
                    .map((hobby) => _buildPredefinedHobby(
                        hobby['name'], hobby['icon'], hobby['color']))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: customHobbyController,
                      onChanged: (value) {
                        setState(() {
                          showCustomHobbyContainer = value.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Enter Custom Hobby',
                        prefixIcon: Icon(Icons.favorite),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      _addToHobbiesList(customHobbyController.text);

                      customHobbyController.clear();
                      setState(() {
                        showCustomHobbyContainer = false;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: hobbies
                    .map((hobby) => _buildSelectedHobbyChip(hobby))
                    .toList(),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                  onPressed: () {
                    if (validateForm()) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FourthScreen(
                            name: widget.name,
                            email: widget.email,
                            password: widget.password,
                            dob: widget.dob,
                            address: widget.address,
                            phoneNumber: widget.phoneNumber,
                            hobbies: hobbies,
                          ),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromARGB(255, 130, 108, 255),
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
