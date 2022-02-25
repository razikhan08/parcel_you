import 'package:flutter/material.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/widgets/progress_dialog.dart';

import '../authenticationScreens/welcome_screen.dart';

class MyDrawer extends StatefulWidget {

  String? name;

  MyDrawer({this.name});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  logoutButtonDialog(BuildContext context) {

    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel')
    );
    Widget logOutButton = TextButton(
        onPressed: () {
          ProgressDialog();
          fbAuth.signOut();
          Navigator.push(context, MaterialPageRoute(builder: (c) => const WelcomeScreen()));
        },
        child: const Text('Log out')
    );

    AlertDialog alert = AlertDialog(
      content: const Text("Are you sure you want to log out?"),
      actions: [
        cancelButton,
        logOutButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },

    );

  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
        width: 270,
        child: Drawer(
          backgroundColor: Colors.white,
          child: ListView(
              children:<Widget>[
                Container(height: 165,
                color: Colors.grey,
                    child: DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ) ,
                      child: Row(
                        children:  [
                          Icon(Icons.person,
                            size: 40,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 16),

                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(widget.name.toString().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],

                          ),
                        ],
                      ),
                    ),
                  ),
                GestureDetector(
                  onTap: (){},
                  child:const ListTile(
                    title: Text('Parcel History'),
                    leading: Icon(Icons.history,color: Colors.black,),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    title: Text('My Rating'),
                    leading: Icon(Icons.star,color: Colors.black,),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    title: Text('Payment'),
                    leading: Icon(Icons.payment,color: Colors.black,),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    title: Text('Help'),
                    leading: Icon(Icons.help,color: Colors.black,),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    title: Text('Settings'),
                    leading: Icon(Icons.settings,color: Colors.black,),
                  ),
                ),
                GestureDetector(
                  onTap: (){},
                  child: const ListTile(
                    title: Text('Legal'),
                    leading: Icon(Icons.info,color: Colors.black,),
                  ),
                ),
                SizedBox(height: 200,),
                GestureDetector(
                  onTap: (){
                    logoutButtonDialog(context);
                  },
                  child:const ListTile(
                    title: Text('Log Out',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold
                    ),
                    ),
                    leading: Icon(Icons.logout,color: Colors.black,),
                  ),
                ),
              ],
            ),
        ),
      );
  }
}
