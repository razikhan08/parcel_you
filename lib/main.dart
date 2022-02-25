import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:parcel_you/infoHandler/app_info.dart';
import 'package:parcel_you/splashscreen/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> main() async {


  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
     ParcelYou(
        child: ChangeNotifierProvider(
          create: (context) => AppInfo(),
          child: const MaterialApp(
            home: MySplashScreen(),
            debugShowCheckedModeBanner: false,

          ),
        ),
    ),
  );
}

class ParcelYou extends StatefulWidget {

  final Widget? child;
  
    ParcelYou({this.child});
  
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_ParcelYouState>()!.restartApp();
  }
  
  
  
  @override
  _ParcelYouState createState() => _ParcelYouState();
}

class _ParcelYouState extends State<ParcelYou> {
  
  Key key = UniqueKey();
  void restartApp()
  {
    setState(() {
      key = UniqueKey();
    });
  }
  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
        child: widget.child!,

    );
  }
}

 

