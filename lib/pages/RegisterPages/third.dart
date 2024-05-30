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

  TextEditingController dogNameController = TextEditingController();
  TextEditingController dogBreedController = TextEditingController();
  TextEditingController dogAgeController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  List<Map<String, dynamic>> predefinedHobbies = [
    {'name': 'Passeggiate', 'icon': Icons.directions_walk, 'color': Colors.blue},
    {'name': 'Correre', 'icon': Icons.sports_score, 'color': Colors.green},
    {'name': 'Gare canine', 'icon': Icons.restaurant, 'color': Colors.orange},
    {'name': 'Sfilate di moda', 'icon': Icons.diamond, 'color': Colors.purple},
    {'name': 'Fare amicizia', 'icon': Icons.people, 'color': Colors.red},
    {'name': 'Giocare', 'icon': Icons.videogame_asset, 'color': Color.fromARGB(255, 245, 241, 4)},
    {'name': 'Mangiare', 'icon': Icons.restaurant, 'color': Colors.pink},
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
    if (_formKey.currentState?.validate() ?? false) {
      if (hobbies.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Informazioni Mancanti'),
              content: Text('Per favore seleziona almeno un hobby.'),
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

      // Validazione delle informazioni del cane
      if (dogNameController.text.isEmpty || dogBreedController.text.isEmpty || dogAgeController.text.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Informazioni del Cane Mancanti'),
              content: Text('Per favore inserisci tutte le informazioni del cane.'),
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
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parlateci di voi'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: dogNameController,
                  decoration: InputDecoration(
                    labelText: 'Nome del Cane',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore inserisci il nome del cane';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: dogBreedController,
                  decoration: InputDecoration(
                    labelText: 'Specie del Cane',
                    prefixIcon: Icon(Icons.info),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore inserisci la specie del cane';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10.0),
                TextFormField(
                  controller: dogAgeController,
                  decoration: InputDecoration(
                    labelText: 'Età del Cane',
                    prefixIcon: Icon(Icons.cake),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Per favore inserisci l\'età del cane';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20.0),

                Container(
                  margin: EdgeInsets.only(right: 15.0, top: 10),
                  child: Center(
                    child: Text(
                      'Attività',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Puoi regolare la dimensione del testo a tuo piacimento
                      ),
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15.0),
                    child: Image.asset(
                      'assets/images/hobbies.jpg',
                      height: 200,
                      width: 250,
                      fit: BoxFit.cover,
                    ),
                  ),
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
                          labelText: 'Inserisci altre attività',
                          prefixIcon: Icon(Icons.favorite),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        if (customHobbyController.text.isNotEmpty) {
                          _addToHobbiesList(customHobbyController.text);
                          customHobbyController.clear();
                          setState(() {
                            showCustomHobbyContainer = false;
                          });
                        }
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
                    backgroundColor: Color.fromARGB(255, 130, 108, 255),
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
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
