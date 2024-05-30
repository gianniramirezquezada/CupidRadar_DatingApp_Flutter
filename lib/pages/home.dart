import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:romanceradar/pages/about.dart';
import 'package:romanceradar/pages/chatbox.dart';
import 'package:romanceradar/pages/datingPreference.dart';
import 'package:romanceradar/pages/matchRequest.dart';
import 'package:romanceradar/pages/matchedPopup.dart';

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

          // Fetch the matchRequests collection
          QuerySnapshot matchRequestsSnapshot = await FirebaseFirestore.instance
              .collection('matchRequests')
              .get();

          // Explicitly specify the type of matchRequests
          List<Map<String, dynamic>> matchRequests = matchRequestsSnapshot.docs
              .map<Map<String, dynamic>>(
                  (doc) => doc.data() as Map<String, dynamic>)
              .toList();

          QuerySnapshot querySnapshot =
              await FirebaseFirestore.instance.collection('users').get();

          if (querySnapshot.docs.isNotEmpty) {
            List<Map<String, dynamic>> sortedUserData = querySnapshot.docs
                .where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['email'] != loggedInUserEmail &&
                      data['gender'] == loggedInUserDatingPreference &&
                      data['datingPreference'] == loggedInUserGender;
                })
                .where((doc) {
                  // Check if there is no match request between the logged-in user and the current user
                  return !isMatched(
                      loggedInUserEmail, doc['email'], matchRequests);
                })
                .map<Map<String, dynamic>>(
                    (doc) => doc.data() as Map<String, dynamic>)
                .toList();

            sortedUserData.sort((a, b) {
              bool aPendingMatch = matchRequests.any((matchRequest) =>
                  matchRequest['sender'] == a['email'] &&
                  matchRequest['receiver'] == loggedInUserEmail &&
                  matchRequest['status'] == 'pending');

              bool bPendingMatch = matchRequests.any((matchRequest) =>
                  matchRequest['sender'] == b['email'] &&
                  matchRequest['receiver'] == loggedInUserEmail &&
                  matchRequest['status'] == 'pending');

              if (aPendingMatch && !bPendingMatch) {
                return -1; // a comes before b
              } else if (!aPendingMatch && bPendingMatch) {
                return 1; // b comes before a
              } else {
                return 0; // no change
              }
            });

            setState(() {
              userData = sortedUserData;
            });
          }
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  bool isMatched(String sender, String receiver,
      List<Map<String, dynamic>> matchRequests) {
    // Check if there is any match request between sender and receiver with a status of 'matched'
    var matchingRequest = matchRequests.firstWhere(
      (matchRequest) =>
          ((matchRequest['sender'] == sender &&
                  matchRequest['receiver'] == receiver) ||
              (matchRequest['sender'] == receiver &&
                  matchRequest['receiver'] == sender)) &&
          matchRequest['status'] == 'matched',
      orElse: () => {},
    );

    // If there is a matching request with 'matched' status, consider it as a match
    return matchingRequest.isNotEmpty;
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

  void _swipeLeft() {
    setState(() {
      _updateMatchRequest(userData[currentIndex]['email']);

      currentIndex = (currentIndex + 1) % userData.length;
    });
  }

  void _swipeRight() {
    setState(() {
      _updateMatchRequest(userData[currentIndex]['email']);

      currentIndex = (currentIndex - 1) % userData.length;
    });
  }

  Future<void> _updateMatchRequest(String receiverEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String senderEmail = prefs.getString('userEmail') ?? '';

      if (senderEmail.isNotEmpty) {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('matchRequests')
            .where('sender', isEqualTo: receiverEmail)
            .where('receiver', isEqualTo: senderEmail)
            .where('status', isEqualTo: 'pending')
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          // If there's a pending match request, update its status
          for (var doc in querySnapshot.docs) {
            await doc.reference.update({'status': 'pendingDone'});
          }
        }
      }
    } catch (e) {
      print("Error updating match request: $e");
    }
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
                    padding: EdgeInsets.only(top: 40, right: 8), // Adjusted padding
                  ),
                  Container(
                    margin: EdgeInsets.only(right: 10.0, top: 20), // Adjusted margin
                    child: Center(
                      child: Text(
                        'POCHI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.message, size: 40),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatBox(),
                        ),
                      );
                    },
                    padding: EdgeInsets.only(top: 50, right: 8), // Adjusted padding
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
                    : GestureDetector(
                        onHorizontalDragEnd: (details) {
                          if (details.primaryVelocity! > 0) {
                            _swipeRight();
                          } else if (details.primaryVelocity! < 0) {
                            _swipeLeft();
                          }
                        },
                        child: User(
                          userData: userData,
                          currentIndex: currentIndex,
                        ),
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MatchRequestsPage(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.watch_later),
                        onPressed: () {
                          _waitUserRequest(userData[currentIndex]['email']);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('User Saved'),
                              duration: Duration(
                                  seconds: 2), // Optional: Set the duration
                            ),
                          );
                        },
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade50,
                        ),
                        child: IconButton(
                          icon:
                              Icon(Icons.pets_outlined, size: 40, color: Colors.black),
                          onPressed: () {
                            _sendMatchRequest(
                                context, userData[currentIndex]['email']);
                          },
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () {
                          setState(() {
                            _updateMatchRequest(
                                userData[currentIndex]['email']);
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

Future<void> _waitUserRequest(String receiverEmail) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String senderEmail = prefs.getString('userEmail') ?? '';

    if (senderEmail.isNotEmpty) {
      // Store sender and receiver emails in 'waitUsers' collection
      await FirebaseFirestore.instance.collection('waitUsers').add({
        'sender': senderEmail,
        'receiver': receiverEmail,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  } catch (e) {
    print("Error updating match request: $e");
  }
}

void _sendMatchRequest(BuildContext context, String receiverEmail) async {
  try {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String senderEmail = prefs.getString('userEmail') ?? '';

    if (senderEmail.isNotEmpty) {
      // Check if a match request already exists
      QuerySnapshot existingRequestsSnapshot = await FirebaseFirestore.instance
          .collection('matchRequests')
          .where('sender', isEqualTo: receiverEmail)
          .where('receiver', isEqualTo: senderEmail)
          .where('status', whereIn: ['pending', 'pendingDone']).get();

      if (existingRequestsSnapshot.docs.isNotEmpty) {
        // If a match request exists, update the status to 'matched'
        for (var doc in existingRequestsSnapshot.docs) {
          await doc.reference.update({'status': 'matched'});
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return MatchPopup();
          },
        );
      } else {
        // If no match request exists, send a new request
        await FirebaseFirestore.instance.collection('matchRequests').add({
          'sender': senderEmail,
          'receiver': receiverEmail,
          'status': 'pending',
          'timestamp': FieldValue.serverTimestamp(), // Use server timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Match request sent'),
            duration: Duration(seconds: 2), // Optional: Set the duration
          ),
        );
      }
    }
  } catch (e) {
    print("Error sending match request: $e");
    // Handle the error, e.g., show an error message to the user
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

class User extends StatelessWidget {
  final List<Map<String, dynamic>> userData;
  final int currentIndex;

  User({required this.userData, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              image: DecorationImage(
                image: NetworkImage(
                  userData[currentIndex]['imageUrls'] != null &&
                          userData[currentIndex]['imageUrls'].isNotEmpty
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
                        userData[currentIndex]['name'] ?? 'Unknown',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 30),
                        child: IconButton(
                          icon: Icon(
                            Icons.info_outline,
                            size: 40,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AboutPage(
                                  userData: userData[currentIndex],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Text(
                    userData[currentIndex]['bio'] ?? 'No bio available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(
                      userData[currentIndex]['imageUrls'] != null
                          ? userData[currentIndex]['imageUrls'].length
                          : 0,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: GestureDetector(
                          onTap: () {
                            _openImageZoom(
                              context,
                              userData[currentIndex]['imageUrls'][index],
                            );
                          },
                          child: Image.network(
                            userData[currentIndex]['imageUrls'][index],
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
    );
  }
}
