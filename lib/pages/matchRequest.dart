import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: Text('Match Requests'),
      ),
      body: loggedInUserEmail.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('matchRequests')
                  .where('receiver', isEqualTo: loggedInUserEmail)
                  .where('status', isEqualTo: 'pending')
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
                    child: Text('No pending match requests.'),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> data =
                        doc.data() as Map<String, dynamic>;
                    return MatchRequestCard(
                      senderEmail: data['sender'],
                      status: data['status'],
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
  final String status;

  MatchRequestCard({
    required this.senderEmail,
    required this.status,
  });

  @override
  _MatchRequestCardState createState() => _MatchRequestCardState();
}

class _MatchRequestCardState extends State<MatchRequestCard> {
  late String senderName = '';
  late String senderDpUrl = '';

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
              icon: Icon(Icons.check, color: Colors.green),
              onPressed: () {
                _updateStatus('matched');
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
    //     // builder: (context) => AboutPage(userData: userData[currentIndex]),
    //   ),
    // );
  }

  void _updateStatus(String newStatus) {
    // Update the status to 'matched'
    FirebaseFirestore.instance
        .collection('matchRequests')
        .where('sender', isEqualTo: widget.senderEmail)
        .where('status', isEqualTo: 'pending')
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'status': newStatus}).then((value) {
          print('Status updated to $newStatus');
          // You can add further logic after updating the status
        }).catchError((error) {
          print('Error updating status: $error');
        });
      });
    }).catchError((error) {
      print('Error getting documents: $error');
    });
  }

  void _deleteUser() {
    // Delete the user from matchRequests collection using a unique identifier
    FirebaseFirestore.instance
        .collection('matchRequests')
        .where('sender', isEqualTo: widget.senderEmail)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete().then((value) {
          print('User deleted successfully');
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
