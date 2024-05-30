import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:async';
import 'dart:io';

import 'package:romanceradar/pages/loginpage.dart';

class SixthScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String dob;
  final String address;
  final String phoneNumber;
  final List<String> hobbies;
  final List<File?> selectedImages;
  final String selectedGender;
  final String selectedDatingPreference;
  final String bio;

  SixthScreen({
    required this.name,
    required this.email,
    required this.password,
    required this.dob,
    required this.address,
    required this.phoneNumber,
    required this.hobbies,
    required this.selectedImages,
    required this.selectedGender,
    required this.selectedDatingPreference,
    required this.bio,
  });

  @override
  _SixthScreenState createState() => _SixthScreenState();
}

class _SixthScreenState extends State<SixthScreen> {
  late Future<void> _storeUserDataFuture;
  late Timer _timeoutTimer;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    _storeUserDataFuture = _storeUserData();
    _timeoutTimer = Timer(Duration(seconds: 60), _handleTimeout);
  }

  Future<void> _storeUserData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentReference userRef = await firestore.collection('users').add({
        'name': widget.name,
        'email': widget.email,
        'password': widget.password,
        'dob': widget.dob,
        'address': widget.address,
        'phoneNumber': widget.phoneNumber,
        'hobbies': widget.hobbies,
        'gender': widget.selectedGender,
        'datingPreference': widget.selectedDatingPreference,
        'bio': widget.bio,
      });

      List<String> imageUrls = await _uploadImages(userRef.id);
      await userRef.update({'imageUrls': imageUrls});

      print(
          'User data and images stored successfully in Firestore and Storage!');
    } catch (e) {
      print('Error storing user data and images: $e');
      _handleError();
    }
  }

  Future<List<String>> _uploadImages(String userId) async {
    List<String> imageUrls = [];

    try {
      for (int i = 0; i < widget.selectedImages.length; i++) {
        File? imageFile = widget.selectedImages[i];

        if (imageFile != null) {
          firebase_storage.Reference storageReference = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child('user_images/${widget.email}/image_$i.jpg');

          firebase_storage.UploadTask uploadTask =
              storageReference.putFile(imageFile);

          await uploadTask.whenComplete(() async {
            String imageUrl = await storageReference.getDownloadURL();
            imageUrls.add(imageUrl);
            print('Image $i URL: $imageUrl');
          });
        }
      }
    } catch (e) {
      print('Error uploading images: $e');
      _handleError();
    }

    return imageUrls;
  }

  void _handleTimeout() {
    setState(() {
      _showError = true;
    });
  }

  void _handleError() {
    setState(() {
      _showError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _showError
            ? Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  
                  children: [
                    Text(
                      'Please check your connection',
                      style: TextStyle(fontSize: 16.0),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showError = false;
                        });
                        _timeoutTimer.cancel();
                        _storeUserDataFuture = _storeUserData();
                        _timeoutTimer =
                            Timer(Duration(seconds: 60), _handleTimeout);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 130, 108, 255),
                        padding: EdgeInsets.all(15.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            )
            : FutureBuilder<void>(
                future: _storeUserDataFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'It may take a while. We are setting up your account...',
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.0),
                          CircularProgressIndicator(),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  } else {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 80.0,
                        ),
                        SizedBox(height: 20.0),
                        Text(
                          'Your account is successfully created!',
                          style: TextStyle(fontSize: 18.0),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromARGB(255, 130, 108, 255),
                            padding: EdgeInsets.symmetric(vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
      ),
    );
  }
}
