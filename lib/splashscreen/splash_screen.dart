import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parcel_you/mainScreens/home_screen.dart';
import 'package:parcel_you/authenticationScreens/welcome_screen.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/mainScreens/send_package_screen.dart';

import '../method/assistant_method.dart';


class MySplashScreen extends StatefulWidget {
  const MySplashScreen({Key? key}) : super(key: key);

  @override
  _MySplashScreenState createState() => _MySplashScreenState();
}

class _MySplashScreenState extends State<MySplashScreen> {

  startTimer() {

    fbAuth.currentUser != null ?  AssistantMethods.readCurrentOnlineUserInfo() : null;

    Timer(const Duration(seconds: 3), () async {
      if (await fbAuth.currentUser != null) {
        //navigate to HomePage if user is logged in//
        currentFirebaseUser = fbAuth.currentUser;
        Navigator.push(context, MaterialPageRoute(builder: (c) => HomeScreen()));

      } else {
        //navigate to WelcomeScreen if user not logged in//

        Navigator.push(context, MaterialPageRoute(builder: (c) =>  WelcomeScreen()));

      }

    });
  }

  @override
  void initState() {
    super.initState();

    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.green.shade200,
        child: const Center(child: Text('ParcelYou',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 40
          ),

        ),
        ),
      ),
    );
  }
}

