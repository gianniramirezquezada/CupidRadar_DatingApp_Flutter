import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:romanceradar/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:romanceradar/pages/chat.dart';

class ChatBox extends StatefulWidget {
  @override
  _ChatBoxState createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  late String loggedInUserEmail = "";

  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }

  Future<void> _getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      loggedInUserEmail = prefs.getString('userEmail') ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat With Your Date',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          },
        ),
      ),
      body: loggedInUserEmail.isEmpty
          ? Center(
              child: CircularProgressIndicator(),
            )
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('matchRequests')
                  .where('status', isEqualTo: 'matched')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.data == null || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No pending match requests.',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                return ListView(
                  children: snapshot.data!.docs.map((doc) {
                    Map<String, dynamic> requestData =
                        doc.data() as Map<String, dynamic>;

                    String senderEmail = requestData['sender'];
                    String receiverEmail = requestData['receiver'];

                    // Check if loggedInUserEmail is either sender or receiver
                    if (senderEmail == loggedInUserEmail ||
                        receiverEmail == loggedInUserEmail) {
                      String oppositeUserEmail =
                          senderEmail == loggedInUserEmail
                              ? receiverEmail
                              : senderEmail;

                      return UserCard(
                        oppositeUserEmail: oppositeUserEmail,
                      );
                    }

                    return SizedBox.shrink();
                  }).toList(),
                );
              },
            ),
    );
  }
}

class UserCard extends StatefulWidget {
  final String oppositeUserEmail;

  UserCard({
    required this.oppositeUserEmail,
  });

  @override
  _UserCardState createState() => _UserCardState();
}

class _UserCardState extends State<UserCard> {
  late String oppositeUserName = '';
  late String oppositeUserDpUrl = '';
  late String oppositeUserEmail = widget.oppositeUserEmail;

  @override
  void initState() {
    super.initState();
    _fetchOppositeUserDetails();
  }

  Future<void> _fetchOppositeUserDetails() async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: widget.oppositeUserEmail)
          .limit(1)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> userData =
            userSnapshot.docs.first.data() as Map<String, dynamic>;
        setState(() {
          oppositeUserName = userData['name'] ?? 'Unknown';

          oppositeUserDpUrl =
              userData['imageUrls'] != null && userData['imageUrls'].isNotEmpty
                  ? userData['imageUrls'][0]
                  : 'https://example.com/placeholder_image.jpg';
        });
      }
    } catch (e) {
      print("Error fetching opposite user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: 5.0, // Add elevation for a card-like appearance
      child: ListTile(
        title: Row(
          children: [
            oppositeUserDpUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(oppositeUserDpUrl),
                  )
                : Container(),
            SizedBox(width: 10),
            Text(
              oppositeUserName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ],
        ),
        onTap: () {
          _navigateToChatScreen(context, widget.oppositeUserEmail);
        },
      ),
    );
  }

  void _navigateToChatScreen(BuildContext context, String userEmail) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          userName: oppositeUserName,
          userEmail: oppositeUserEmail,
          userImage: oppositeUserDpUrl,
        ),
      ),
    );
  }
}
