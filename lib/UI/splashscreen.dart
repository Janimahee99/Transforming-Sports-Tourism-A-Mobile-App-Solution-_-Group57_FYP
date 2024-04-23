import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sportswander/Services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Use a Timer to navigate after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        CupertinoPageRoute(builder: (ctx) => AuthPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 232, 228),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: Image(
                  image: AssetImage('assets/logo.png'),
                  height: 300,
                  width: 300,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
          SizedBox(height: 100),
          SpinKitSquareCircle(
            color: Color(0xFFFBB03B),
            size: 50.0,
          ),
        ],
      ),
    );
  }
}
