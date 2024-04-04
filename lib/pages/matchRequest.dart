import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romanceradar/pages/matchedPopup.dart';
// import 'package:romanceradar/pages/about.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchRequestsPage extends StatefulWidget {
  @override
  _MatchRequestsPageState createState() => _MatchRequestsPageState();
}

class _MatchRequestsPageState extends State<MatchRequestsPage> {
  late String loggedInUserEmail = "";

  @override
  void initState() {
    super.initState();
    _getLoggedInUserEmail();
  }

  Future<void> _getLoggedInUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserEmail = prefs.getString('userEmail') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liked Users'),
      ),
      body: loggedInUserEmail.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('waitUsers')
                  .where('sender', isEqualTo: loggedInUserEmail)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No Users'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return MatchRequestCard(
                      senderEmail: data['receiver'],
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}

class MatchRequestCard extends StatefulWidget {
  final String senderEmail;

  MatchRequestCard({
    required this.senderEmail,
  });

  @override
  _MatchRequestCardState createState() => _MatchRequestCardState();
}

class _MatchRequestCardState extends State<MatchRequestCard> {
  late String senderName = '';
  late String senderDpUrl = '';
  late String userEmail = '';

  @override
  void initState() {
    super.initState();
    _fetchSenderDetails();
  }

  Future<void> _fetchSenderDetails() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.senderEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            userSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          senderName = userData['name'] ?? 'Unknown';
          userEmail = userData['email'] ?? 'Unknown';
          senderDpUrl =
              userData['imageUrls'] != null && userData['imageUrls'].isNotEmpty
                  ? userData['imageUrls'][0]
                  : 'https://example.com/placeholder_image.jpg';
        });
      }
    } catch (e) {
      print("Error fetching sender details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ListTile(
        title: Row(
          children: [
            senderDpUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(senderDpUrl),
                  )
                : Container(),
            SizedBox(width: 10),
            Text(senderName),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.add, color: Colors.green),
              onPressed: () {
                checkDocuments(userEmail);

                // Handle accept action
                // You can implement the logic here
              },
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _deleteUser();

                // Handle decline action
                // You can implement the logic here
              },
            ),
          ],
        ),
        onTap: () {
          _navigateToUserProfile(context, widget.senderEmail);
        },
      ),
    );
  }

  void _navigateToUserProfile(BuildContext context, String userEmail) {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => AboutPage(userData: userData[currentIndex]),
    //   ),
    // );
  }

  Future<void> checkDocuments(String receiverEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String senderEmail = prefs.getString('userEmail') ?? '';
      // Reference to Firestore collection
      CollectionReference matchRequestsCollection =
          FirebaseFirestore.instance.collection('matchRequests');

      // Query for receiver's document
      QuerySnapshot Snapshot = await matchRequestsCollection
          .where('receiver', isEqualTo: receiverEmail)
          .where('sender', isEqualTo: senderEmail)
          .limit(1)
          .get();

      // Check if both sender and receiver documents exist
      if (Snapshot.docs.isNotEmpty) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request already sended'),
            duration: Duration(seconds: 2), // Optional: Set the duration
          ),
        );
         _deleteWaitUser(senderEmail, receiverEmail);
      } else {
        _sendMatchRequest(receiverEmail);
      }
    } catch (e) {
      print('Error checking documents: $e');
    }
  }

  void _sendMatchRequest(String receiverEmail) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String senderEmail = prefs.getString('userEmail') ?? '';

      if (senderEmail.isNotEmpty) {
        // Check if a match request already exists
        QuerySnapshot existingRequestsSnapshot = await FirebaseFirestore
            .instance
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
        _deleteWaitUser(senderEmail, receiverEmail);
       
      }
    } catch (e) {
      print("Error sending match request: $e");
      // Handle the error, e.g., show an error message to the user
    }
  }

  Future<void> _deleteWaitUser(String senderEmail, String receiverEmail) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('waitUsers')
          .where('sender', isEqualTo: senderEmail)
          .where('receiver', isEqualTo: receiverEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Delete the document
        await querySnapshot.docs.first.reference.delete();
          setState(() {
            _fetchSenderDetails();
            // Update any state variables here if needed
          });
      }
    } catch (e) {
      print("Error deleting waitUser document: $e");
    }
  }

  void _deleteUser() {
    // Delete the user from matchRequests collection using a unique identifier
    FirebaseFirestore.instance
        .collection('waitUsers')
        .where('receiver', isEqualTo: widget.senderEmail)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          print('User deleted successfully');
          setState(() {
            _fetchSenderDetails();
            // Update any state variables here if needed
          });
          // You can add further logic after deleting the user
        }).catchError((error) {
          print('Error deleting user: $error');
        });
      });
    }).catchError((error) {
      print('Error getting documents: $error');
    });
  }
}
