import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:romanceradar/pages/about.dart';
import 'package:romanceradar/pages/chatbox.dart';
import 'package:romanceradar/pages/datingPreference.dart';

import 'package:romanceradar/pages/myprofilepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  late List<Map<String, dynamic>> userData = [];
  String? currentDatingPreference;
  String? userId;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String loggedInUserEmail = prefs.getString('userEmail') ?? '';

      if (loggedInUserEmail.isNotEmpty) {
        QuerySnapshot loggedInUserSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: loggedInUserEmail)
            .limit(1)
            .get();

        if (loggedInUserSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> loggedInUserData =
              loggedInUserSnapshot.docs.first.data() as Map<String, dynamic>;

          userId = loggedInUserSnapshot.docs.first.id;
          String loggedInUserDatingPreference =
              loggedInUserData['datingPreference'] ?? '';

          currentDatingPreference = loggedInUserData['datingPreference'] ?? '';

          String loggedInUserGender = loggedInUserData['gender'] ?? '';

          currentDatingPreference = loggedInUserData['datingPreference']
              as String?; // Update currentDatingPreference

          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance.collection('users').get();

          if (querySnapshot.docs.isNotEmpty) {
            setState(() {
              userData = querySnapshot.docs
                  .where((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return data['email'] != loggedInUserEmail &&
                        data['gender'] == loggedInUserDatingPreference &&
                        data['datingPreference'] == loggedInUserGender;
                  })
                  .map<Map<String, dynamic>>(
                      (doc) => doc.data() as Map<String, dynamic>)
                  .toList();
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> _refreshData() async {
    await fetchData();
  }

  // New method to handle dating preference selection
  void _handleDatingPreferenceSelection(String preference) async {
    // Update the currentDatingPreference in the class
   

    // Update the dating preference in Firestore
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String loggedInUserEmail = prefs.getString('userEmail') ?? '';

      if (loggedInUserEmail.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({'datingPreference': preference});

        fetchData();
      }
    } catch (e) {
      print("Error updating dating preference: $e");
    }

    // Close the right sidebar
    Navigator.of(context).pop();

     if (Navigator.of(context).canPop()) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (BuildContext context) => HomeScreen()),
    );
  }
  }

  void _showDatingPreferenceSidebar() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return DatingPreferenceSelection(
          currentDatingPreference: currentDatingPreference,
          onPreferenceSelected: (preference) {
            _handleDatingPreferenceSelection(preference);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 16, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.person, size: 40),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProfilePage(),
                        ),
                      );
                    },
                    padding: EdgeInsets.only(top: 8, right: 8),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 30.0),
                    child: Image.asset(
                      'assets/images/heart.png',
                      width: 55,
                      height: 55,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 50.0, top: 10),
                    child: Image.asset(
                      'assets/images/logo.png',
                      width: 100,
                      height: 100,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.message, size: 40),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatBoxScreen(),
                        ),
                      );
                    },
                    padding: EdgeInsets.only(top: 8, right: 8),
                  ),
                ],
              ),
            ),

            // User image, name, bio, and additional images
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 12.0, bottom: 12.0),
                child: userData.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(
                        children: [
                          // Background Image
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              image: DecorationImage(
                                image: NetworkImage(
                                  userData[currentIndex]['imageUrls'] != null &&
                                          userData[currentIndex]['imageUrls']
                                              .isNotEmpty
                                      ? userData[currentIndex]['imageUrls'][0]
                                      : 'https://example.com/placeholder_image.jpg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withOpacity(0.7),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        userData[currentIndex]['name'] ??
                                            'Unknown',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 30),
                                        child: IconButton(
                                          icon: Icon(Icons.info_outline,
                                              size: 40, color: Colors.white),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => AboutPage(
                                                    userData:
                                                        userData[currentIndex]),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    userData[currentIndex]['bio'] ??
                                        'No bio available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: List.generate(
                                      userData[currentIndex]['imageUrls'] !=
                                              null
                                          ? userData[currentIndex]['imageUrls']
                                              .length
                                          : 0,
                                      (index) => Padding(
                                        padding:
                                            const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            _openImageZoom(
                                              context,
                                              userData[currentIndex]
                                                  ['imageUrls'][index],
                                            );
                                          },
                                          child: Image.network(
                                            userData[currentIndex]['imageUrls']
                                                [index],
                                            width: 50,
                                            height: 60,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            // Bottom icons
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Container(
                height: 70,
                decoration: BoxDecoration(
                  color:
                      const Color.fromARGB(255, 224, 209, 209).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Container(
                  margin: EdgeInsets.only(left: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.groups,
                          size: 40,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ),
                      Icon(Icons.watch_later),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade50,
                        ),
                        child: IconButton(
                          icon:
                              Icon(Icons.favorite, size: 40, color: Colors.red),
                          onPressed: () {},
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            currentIndex = (currentIndex + 1) % userData.length;
                          });
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.dehaze_rounded,
                            size: 35, color: Colors.black),
                        onPressed: () {
                          _showDatingPreferenceSidebar();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _openImageZoom(BuildContext context, String imageUrl) {
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
              height: 400,
              child: PhotoViewGallery(
                pageController: PageController(),
                backgroundDecoration: BoxDecoration(
                  color: Colors.black,
                ),
                pageOptions: [
                  PhotoViewGalleryPageOptions(
                    imageProvider: NetworkImage(imageUrl),
                    minScale: PhotoViewComputedScale.contained * 2.3,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  ),
                ],
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
          ],
        ),
      );
    },
  );
}
