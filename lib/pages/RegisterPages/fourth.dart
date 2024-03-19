import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:romanceradar/pages/RegisterPages/fifth.dart';

class FourthScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String dob;
  final String address;
  final String phoneNumber;
  final List<String> hobbies;

  FourthScreen({
    required this.name,
    required this.email,
    required this.password,
    required this.dob,
    required this.address,
    required this.phoneNumber,
    required this.hobbies,
  });

  @override
  _FourthScreenState createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  List<File?> _selectedImages = List.generate(5, (index) => null);

  Future<void> _pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages[index] = File(pickedFile.path);
      });
    }
  }

  bool validateImages() {
  for (int i = 0; i < 5; i++) {
    if (_selectedImages[i] == null) {
      return false;
    }
  }
  return true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload Images'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/uploadPhotos.png',
              width: 300,
              height: 300,
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int i = 0; i < 3; i++)
                  InkWell(
                    onTap: () => _pickImage(i),
                    child: Container(
                      height: 90,
                      width: 90,
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _selectedImages[i] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                _selectedImages[i]!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 3; i < 5; i++)
                  InkWell(
                    onTap: () => _pickImage(i),
                    child: Container(
                      height: 90,
                      width: 90,
                      margin: EdgeInsets.only(right: 10.0, left: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: _selectedImages[i] != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(
                                _selectedImages[i]!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.add,
                              size: 40,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                if (validateImages()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FifthScreen(
                        name: widget.name,
                        email: widget.email,
                        password: widget.password,
                        dob: widget.dob,
                        address: widget.address,
                        phoneNumber: widget.phoneNumber,
                        hobbies: widget.hobbies,
                        selectedImages: _selectedImages,
                      ),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Images Required'),
                        content: Text('Please upload all images.'),
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
                primary: Color.fromARGB(255, 130, 108, 255),
                padding: EdgeInsets.all(20.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Upload Images and Continue',
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
    );
  }
}
