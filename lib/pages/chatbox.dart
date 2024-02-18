import 'package:flutter/material.dart';
import 'package:romanceradar/pages/chat.dart';

class ChatBoxScreen extends StatelessWidget {
  final List<String> users = ['Tripti Dimri', 'Mrunal Thakur'];
  final List<String> profileImages = [
    'assets/images/user11.jpg',
    'assets/images/user22.jpg',
  ];
  final List<String> lastMessages = [
    'Hey, how are you?',
    'I had a great day!',
  ];
  final List<String> lastMessageTimes = [
    '10:30 AM',
    'Yesterday',
  ];
  final List<int> unreadMessages = [3, 1];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Box'),
      ),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundImage: AssetImage(profileImages[index]),
              ),
              title: Text(
                users[index],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                lastMessages[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lastMessageTimes[index],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      unreadMessages[index].toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      userName: users[index],
                      userImage: profileImages[index],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
