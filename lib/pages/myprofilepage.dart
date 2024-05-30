import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romanceradar/pages/home.dart';
import 'package:romanceradar/pages/loginpage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class MyProfilePage extends StatefulWidget {
  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  late String userEmail = '';
  late Map<String, dynamic> userData = {};
  late List<String> imageUrls = [];
  late TextEditingController nameController = TextEditingController();
  late TextEditingController bioController = TextEditingController();
  late TextEditingController dobController = TextEditingController();
  late TextEditingController addressController = TextEditingController();
  late TextEditingController phoneNumberController = TextEditingController();
  late TextEditingController genderController = TextEditingController();

  late TextEditingController hobbiesController = TextEditingController();
  bool isEditMode = false;
  bool isDatePickerOpen = false;

  @override
  void initState() {
    super.initState();
    fetchUserEmail();
  }

  Future<void> fetchUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userEmail = prefs.getString('userEmail') ?? '';
    });

    if (userEmail.isNotEmpty) {
      fetchUserData();
    }
  }

  Future<void> fetchUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      print('Number of documents: ${users.docs.length}');

      if (users.docs.isNotEmpty) {
        setState(() {
          userData = users.docs[0].data() as Map<String, dynamic>;
          imageUrls = List<String>.from(userData['imageUrls'] ?? []);
          nameController.text = userData['name'] ?? '';
          bioController.text = userData['bio'] ?? '';
          dobController.text = userData['dob'] ?? '';
          addressController.text = userData['address'] ?? '';
          phoneNumberController.text = userData['phoneNumber'] ?? '';
          genderController.text = userData['gender'] ?? '';

          hobbiesController.text =
              userData['hobbies'] != null ? userData['hobbies'].join(', ') : '';
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> updateUserData() async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (users.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = users.docs.first;
        String documentId = userDoc.id;

        Map<String, dynamic> updatedData = {};

        if (nameController.text.isNotEmpty) {
          updatedData['name'] = nameController.text;
        }
        if (bioController.text.isNotEmpty) {
          updatedData['bio'] = bioController.text;
        }
        if (dobController.text.isNotEmpty) {
          updatedData['dob'] = dobController.text;
        }
        if (addressController.text.isNotEmpty) {
          updatedData['address'] = addressController.text;
        }
        if (phoneNumberController.text.isNotEmpty) {
          updatedData['phoneNumber'] = phoneNumberController.text;
        }
        if (genderController.text.isNotEmpty) {
          updatedData['gender'] = genderController.text;
        }

        if (hobbiesController.text.isNotEmpty) {
          updatedData['hobbies'] =
              hobbiesController.text.split(',').map((e) => e.trim()).toList();
        }
        if (imageUrls.isNotEmpty) {
          updatedData['imageUrls'] = imageUrls;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update(updatedData);

        print('User data for $userEmail updated with new values');
        fetchUserData();
      } else {
        print('Document does not exist for email: $userEmail');
      }
    } catch (e) {
      print('Error updating user data: $e');
    }
  }

  Future<void> updateFirstUrlInFirestore(String newUrl) async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (users.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = users.docs.first;
        String documentId = userDoc.id;

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<String> updatedImageUrls =
            List<String>.from(userData['imageUrls'] ?? []);

        updatedImageUrls[0] = newUrl;

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'imageUrls': updatedImageUrls});

        fetchUserData();
      } else {
        print('Document does not exist for email: $userEmail');
      }
    } catch (e) {
      print('Error updating the first URL in Firestore: $e');
    }
  }

  Future<void> deleteImageInStorage(String imageUrl) async {
    try {
      await firebase_storage.FirebaseStorage.instance
          .refFromURL(imageUrl)
          .delete();
    } catch (e) {
      print('Error deleting image from storage: $e');
    }
  }

  void _openImageZoom(BuildContext context, String imageUrl, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 400,
                height: 500,
                child: PhotoViewGallery(
                  pageController: PageController(initialPage: index),
                  backgroundDecoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  pageOptions: imageUrls
                      .map((url) => PhotoViewGalleryPageOptions(
                            imageProvider: NetworkImage(url),
                            minScale: PhotoViewComputedScale.contained * 2,
                            maxScale: PhotoViewComputedScale.covered * 3,
                          ))
                      .toList(),
                ),
              ),
              Positioned(
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Positioned(
                bottom: 10,
                left: 30,
                child: ElevatedButton(
                  onPressed: () {
                    _changeProfilePicture(index);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Change Profile Picture',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeProfilePicture(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String newImagePath = pickedFile.path;

      if (index >= 0 && index < imageUrls.length) {
        await deleteImageInStorage(imageUrls[index]);

        await uploadImageToStorage(newImagePath, index);
      }
    } else {
      print('Image picking canceled');
    }
  }

  Future<String> uploadImageToStorage(String imagePath, int index) async {
    try {
      File imageFile = File(imagePath);

      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('user_images/$userEmail/image_$index.jpg');

      firebase_storage.UploadTask uploadTask =
          storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() async {
        String imageUrl = await storageReference.getDownloadURL();
        updateImageUrlInFirestore(imageUrl, index);
      });

      return '';
    } catch (e) {
      print('Error uploading image to storage: $e');
      return '';
    }
  }

  Future<void> updateImageUrlInFirestore(String newUrl, int index) async {
    try {
      QuerySnapshot<Map<String, dynamic>> users = await FirebaseFirestore
          .instance
          .collection('users')
          .where('email', isEqualTo: userEmail)
          .limit(1)
          .get();

      if (users.docs.isNotEmpty) {
        DocumentSnapshot<Map<String, dynamic>> userDoc = users.docs.first;
        String documentId = userDoc.id;

        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        List<String> updatedImageUrls =
            List<String>.from(userData['imageUrls'] ?? []);

        if (index >= 0 && index < updatedImageUrls.length) {
          updatedImageUrls[index] = newUrl;
        }

        await FirebaseFirestore.instance
            .collection('users')
            .doc(documentId)
            .update({'imageUrls': updatedImageUrls});

        fetchUserData();
      } else {
        print('Document does not exist for email: $userEmail');
      }
    } catch (e) {
      print('Error updating the image URL in Firestore: $e');
    }
  }

  Future<bool> _onBackPressed() async {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        backgroundColor: Colors.pink[100],
        actions: [
          Container(
            margin: EdgeInsets.only(right: 15),
            child: TextButton(
              onPressed: () {
                logout();
              },
              child: Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: _onBackPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.pink[100]!,
                Colors.redAccent,
              ],
            ),
          ),
          child: Center(
            child: userEmail.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            if (imageUrls.isNotEmpty)
                              Container(
                                height: 150,
                                child: GestureDetector(
                                  onTap: () {
                                    _openImageZoom(context, imageUrls.first, 0);
                                  },
                                  child: Row(children: [
                                    ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(150.0),
                                      child: Image.network(
                                        imageUrls.first,
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding:
                                            EdgeInsets.only(left: 8, top: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (isEditMode)
                                              TextFormField(
                                                controller: nameController,
                                                decoration: InputDecoration(
                                                  hintText: 'Enter your name',
                                                ),
                                              )
                                            else
                                              Text(
                                                userData['name'] ?? '',
                                                style: TextStyle(
                                                  fontSize: 26,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            buildEditField('Bio', 'bio', userData['bio'] ?? ''),
                            buildEditField(
                                'Date of Birth', 'dob', userData['dob'] ?? '',
                                onTap: () {
                              if (isEditMode) {
                                _openDatePicker(context);
                              }
                            }),
                            buildEditField('Address', 'address',
                                userData['address'] ?? ''),
                            buildEditField('Phone Number', 'phoneNumber',
                                userData['phoneNumber'] ?? ''),
                            buildEditField(
                              'Hobbies',
                              'hobbies',
                              userData['hobbies'] != null
                                  ? userData['hobbies'].join(', ')
                                  : 'No hobbies',
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditMode = !isEditMode;
                                });

                                if (!isEditMode) {
                                  updateUserData();
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                              ),
                              child: Text(
                                isEditMode ? 'Save Changes' : 'Edit Profile',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 16),
                            if (imageUrls.isNotEmpty)
                              Container(
                                height: 200,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children:
                                      imageUrls.asMap().entries.map((entry) {
                                    int index = entry.key;
                                    String imageUrl = entry.value;

                                    return GestureDetector(
                                      onTap: () {
                                        _openImageZoom(
                                            context, imageUrl, index);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(8.0),
                                          child: Image.network(
                                            imageUrl,
                                            height: 200,
                                            width: 200,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text('User email not found.',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildEditField(String label, String field, String value,
      {bool dropdown = false, Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.redAccent,
            ),
          ),
          SizedBox(height: 4),
          if (isEditMode)
            dropdown
                ? buildDropdownField(label, field)
                : GestureDetector(
                    onTap: onTap,
                    child: TextFormField(
                      onTap: onTap,
                      controller: field == 'bio'
                          ? bioController
                          : field == 'dob'
                              ? dobController
                              : field == 'address'
                                  ? addressController
                                  : field == 'phoneNumber'
                                      ? phoneNumberController
                                      : hobbiesController,
                      decoration: InputDecoration(
                        hintText: 'Enter $label',
                      ),
                    ),
                  )
          else
            Text(
              value,
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
        ],
      ),
    );
  }

  void _openDatePicker(BuildContext context) async {
    DateTime initialDate;

    if (isEditMode && dobController.text.isNotEmpty) {
      initialDate = DateTime.parse(dobController.text);
    } else {
      initialDate = DateTime.now();
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        dobController.text = pickedDate.toLocal().toString().split(' ')[0];
      });
    }
  }

  Widget buildDropdownField(String label, String field) {
    List<String> options = [];
    String currentValue = '';

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: DropdownButtonFormField<String>(
          value: currentValue.isNotEmpty ? currentValue : null,
          onChanged: (value) {
            setState(() {});
          },
          items: options.map((String option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
              ),
            );
          }).toList(),
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(
              color: Colors.grey,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userEmail');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (Route<dynamic> route) => false,
    );
  }
}
