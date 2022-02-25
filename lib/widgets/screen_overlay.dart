import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/splashscreen/splash_screen.dart';


class ScreenOverlay extends StatefulWidget {


  String? message;
  ScreenOverlay({this.message});

  @override
  State<ScreenOverlay> createState() => _ScreenOverlayState();
}

class _ScreenOverlayState extends State<ScreenOverlay> {




  startTimer(){
    Timer(const Duration(seconds: 3), () async {

      if (await fbAuth.currentUser != null) {
       Navigator.push(context, MaterialPageRoute(builder: (c) => const MySplashScreen()));

      } else {

        //navigate to Mainscreen
        currentFirebaseUser = fbAuth.currentUser;
    //    Navigator.push(context, MaterialPageRoute(builder: (c) =>  HomePage()));

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
    return Dialog(
      child: Container(
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),

        child:Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget> [
              SizedBox(width: 6),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),

              SizedBox(width: 26),

              Text(widget.message!,
                style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15
                ),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
