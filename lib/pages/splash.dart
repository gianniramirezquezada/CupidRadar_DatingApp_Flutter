import 'dart:async';
import 'package:flutter/material.dart';
import 'package:romanceradar/pages/loginpage.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
            alignment: Alignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 100),
                child: Image.asset(
                  'assets/images/heart.png',
                  height: 110,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 80),
                child: Image.asset(
                  'assets/images/logo.png',
                  height: 150,
                ),
              ),
            ],
          ),
              
            ],
          ),
        ),
      ),
    );
  }
}
