import 'package:flutter/material.dart';
import 'package:romanceradar/pages/chatbox.dart';

class MatchPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          width: 300,
          padding:
              EdgeInsets.only(top: 16.0, left: 16.0, right: 16.0, bottom: 16.0),
          margin: EdgeInsets.only(top: 16.0),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black, offset: Offset(0, 10), blurRadius: 10.0),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'Congratulations!',
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16.0),
              Text(
                'You have a new match!',
                style: TextStyle(fontSize: 18.0),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.0),
              Image.asset('assets/gifs/matched.gif',
                  width: 200.0, height: 200.0),
              SizedBox(height: 24.0),
              TextButton(
                child: Text('Chat now!', style: TextStyle(fontSize: 18.0)),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatBox(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        Positioned(
          left: 245.0,
          top: 20,
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Align(
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 16.0,
                backgroundColor: Colors.blue,
                child: Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
