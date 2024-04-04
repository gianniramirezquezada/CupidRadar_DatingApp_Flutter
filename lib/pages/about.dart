import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class AboutPage extends StatefulWidget {
  final Map<String, dynamic> userData;

  AboutPage({required this.userData});

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late String userEmail;
  late Map<String, dynamic> userData;
  late List<String> imageUrls;

  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    userEmail = widget.userData['email'] ?? '';
    userData = widget.userData;
    imageUrls = List<String>.from(userData['imageUrls'] ?? []);
  }

  void _openImageZoom(BuildContext context, String imageUrl, int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: Container(
            child: PhotoViewGallery.builder(
              itemCount: imageUrls.length,
              builder: (context, index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(imageUrls[index]),
                  minScale: PhotoViewComputedScale.contained * 1,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes:
                      PhotoViewHeroAttributes(tag: index.toString()),
                );
              },
              backgroundDecoration: BoxDecoration(
                color: Colors.black,
              ),
              pageController: PageController(initialPage: index),
              onPageChanged: (index) {
                setState(() {
                  currentImageIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userData['name']),
        backgroundColor: Colors.pink[100],
      ),
      body: Container(
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
                                    borderRadius: BorderRadius.circular(150.0),
                                    child: Image.network(
                                      imageUrls.first,
                                      height: 150,
                                      width: 150,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(left: 8, top: 8),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: buildInfoField(
                                        'Bio', userData['bio'] ?? ''),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: buildInfoField(
                                      'Hobbies',
                                      userData['hobbies'] != null
                                          ? userData['hobbies'].join(', ')
                                          : 'No hobbies',
                                    ),
                                  ),
                                 
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildInfoField(
                                        'Address', userData['address'] ?? ''),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                   Expanded(
                                    child: buildInfoField(
                                        'Date of Birth', userData['dob'] ?? ''),
                                  ),
                                  
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: buildInfoField(
                                        'Gender', userData['gender'] ?? ''),
                                  ),
                                  SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: buildInfoField('Dating Preference',
                                        userData['datingPreference'] ?? ''),
                                  ),
                                ],
                              ),
                            ],
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
                                      _openImageZoom(context, imageUrl, index);
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Hero(
                                        tag: index.toString(),
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
    );
  }

  Widget buildInfoField(String label, String value) {
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
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}
