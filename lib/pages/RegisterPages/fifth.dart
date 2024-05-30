import 'package:flutter/material.dart';
import 'package:romanceradar/pages/RegisterPages/sixth.dart';
import 'dart:io';

class FifthScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String dob;
  final String address;
  final String phoneNumber;
  final List<String> hobbies;
  final List<File?> selectedImages;

  FifthScreen({
    required this.name,
    required this.email,
    required this.password,
    required this.dob,
    required this.address,
    required this.phoneNumber,
    required this.hobbies,
    required this.selectedImages,
  });

  @override
  _FifthScreenState createState() => _FifthScreenState();
}

class _FifthScreenState extends State<FifthScreen> {
  String? selectedGender;
  String? selectedDatingPreference;
  TextEditingController bioController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preferenze'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Image.asset(
                'assets/images/fifthPage.png',
                width: 250,
                height: 250,
              ),
              _buildDropdown(
                items: ['Maschio', 'Femmina'],
                value: selectedGender,
                onChanged: (value) {
                  setState(() {
                    selectedGender = value;
                  });
                },
                hintText: 'Sesso del tuo cane',
              ),
              SizedBox(height: 16.0),
              _buildDropdown(
                items: ['Maschio', 'Femmina'],
                value: selectedDatingPreference,
                onChanged: (value) {
                  setState(() {
                    selectedDatingPreference = value;
                  });
                },
                hintText: 'Preferenza degli altri cani',
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: bioController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Bio del cane',
                  hintText: 'Scrivi tutte le informazioni sul tuo amico',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_validateFields()) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SixthScreen(
                          name: widget.name,
                          email: widget.email,
                          password: widget.password,
                          dob: widget.dob,
                          address: widget.address,
                          phoneNumber: widget.phoneNumber,
                          hobbies: widget.hobbies,
                          selectedImages: widget.selectedImages,
                          selectedGender: selectedGender ?? '',
                          selectedDatingPreference:
                          selectedDatingPreference ?? '',
                          bio: bioController.text,
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Validation Error'),
                          content: Text('Please fill in all fields.'),
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
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 130, 108, 255),
                  padding: EdgeInsets.all(20.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required List<String> items,
    required String? value,
    required void Function(String?) onChanged,
    required String hintText,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  bool _validateFields() {
    if (selectedGender == null ||
        selectedDatingPreference == null ||
        bioController.text.trim().isEmpty) {
      // Return false if any of the fields is not filled
      return false;
    }

    return true;
  }
}
