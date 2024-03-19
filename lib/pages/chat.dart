import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FullScreenImage extends StatelessWidget {
  final String imagePath;

  FullScreenImage({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Hero(
                tag: 'imageHero_$imagePath',
                child: Image.file(File(imagePath)),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 16,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
                color: const Color.fromARGB(255, 0, 0, 0),
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userImage;

  ChatScreen(
      {required this.userName,
      required this.userEmail,
      required this.userImage});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _emojiShowing = false;
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _storeMessage({
        'loggedInUser': loggedInUserEmail,
        'OppositeUser': widget.userEmail,
        'image': pickedFile.path,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _storeMessage(Map<String, dynamic> message) async {
    try {
      await FirebaseFirestore.instance.collection('chats').add(message);
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      print('Error storing message: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _getMessagesStream() async* {
    var query1 = FirebaseFirestore.instance
        .collection('chats')
        .where('loggedInUser', isEqualTo: loggedInUserEmail)
        .where('OppositeUser', isEqualTo: widget.userEmail)
        .orderBy('timestamp', descending: false)
        .limit(50)
        .snapshots();

    var query2 = FirebaseFirestore.instance
        .collection('chats')
        .where('loggedInUser', isEqualTo: widget.userEmail)
        .where('OppositeUser', isEqualTo: loggedInUserEmail)
        .orderBy('timestamp', descending: false)
        .limit(50)
        .snapshots();

    await for (var query1Snapshot in query1) {
      var query2Snapshot = await query2.first;
      var mergedList = [...query1Snapshot.docs, ...query2Snapshot.docs];
      mergedList.sort((a, b) {
        var aTimestamp = (a['timestamp'] as Timestamp?)?.toDate();
        var bTimestamp = (b['timestamp'] as Timestamp?)?.toDate();
        return (aTimestamp ?? DateTime(0)).compareTo(bTimestamp ?? DateTime(0));
      });

      yield mergedList
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.userImage),
            ),
            SizedBox(width: 8),
            Text(widget.userName),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _getMessagesStream(),
              builder: (context,
                  AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                messages.clear();
                messages.addAll(snapshot.data!);

                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    if (messages[index].containsKey('message')) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Align(
                          alignment: messages[index]['loggedInUser'] ==
                                  loggedInUserEmail
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            constraints: BoxConstraints(
                              maxWidth: 300.0,
                            ),
                            decoration: BoxDecoration(
                              color: messages[index]['loggedInUser'] ==
                                      loggedInUserEmail
                                  ? Colors.blue
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              messages[index]['message'],
                              style: TextStyle(
                                color: messages[index]['loggedInUser'] ==
                                        loggedInUserEmail
                                    ? Colors.white
                                    : Colors.black,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      );
                    } else if (messages[index].containsKey('image')) {
                      return Container(
                        height: 300,
                        width: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Hero(
                            tag: 'imageHero_${messages[index]['image']}',
                            child: Align(
                              alignment: messages[index]['loggedInUser'] ==
                                      loggedInUserEmail
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImage(
                                        imagePath: messages[index]['image'],
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: messages[index]['loggedInUser'] ==
                                            loggedInUserEmail
                                        ? Colors.blue
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Image.file(
                                      File(messages[index]['image'])),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                  controller: _scrollController,
                );
              },
            ),
          ),
          Container(
            height: 66.0,
            color: Colors.black,
            child: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        _emojiShowing = !_emojiShowing;
                      });
                    },
                    icon: Icon(
                      Icons.emoji_emotions,
                      color: Colors.white,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.attach_file,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.only(
                          left: 16.0,
                          bottom: 8.0,
                          top: 8.0,
                          right: 16.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    onPressed: () {
                      if (_textController.text.isNotEmpty) {
                        _storeMessage({
                          'loggedInUser': loggedInUserEmail,
                          'OppositeUser': widget.userEmail,
                          'message': _textController.text,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        _textController.clear();
                      }
                    },
                    icon: Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_emojiShowing)
            Expanded(
              child: EmojiPicker(
                onEmojiSelected: (Category? category, Emoji? emoji) {
                  if (category != null && emoji != null) {
                    _textController.text = _textController.text + emoji.emoji;
                  }
                },
                onBackspacePressed: () {
                  _textController.text = _textController.text.substring(
                    0,
                    _textController.text.length - 1,
                  );
                },
                textEditingController: _textController,
                scrollController: _scrollController,
                config: Config(
                  columns: 7,
                  emojiSizeMax: 32 *
                      (foundation.defaultTargetPlatform == TargetPlatform.iOS
                          ? 1.30
                          : 1.0),
                  verticalSpacing: 0,
                  horizontalSpacing: 0,
                  gridPadding: EdgeInsets.zero,
                  initCategory: Category.RECENT,
                  bgColor: Color(0xFFF2F2F2),
                  indicatorColor: Colors.blue,
                  iconColor: Colors.grey,
                  iconColorSelected: Colors.blue,
                  backspaceColor: Colors.blue,
                  skinToneDialogBgColor: Colors.white,
                  skinToneIndicatorColor: Colors.grey,
                  enableSkinTones: true,
                  recentTabBehavior: RecentTabBehavior.RECENT,
                  recentsLimit: 28,
                  noRecents: const Text(
                    'No Recents',
                    style: TextStyle(fontSize: 20, color: Colors.black26),
                    textAlign: TextAlign.center,
                  ),
                  loadingIndicator: const SizedBox.shrink(),
                  tabIndicatorAnimDuration: kTabScrollDuration,
                  categoryIcons: const CategoryIcons(),
                  buttonMode: ButtonMode.MATERIAL,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
