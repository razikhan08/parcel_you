import 'package:flutter/material.dart';
import 'get_started_page.dart';

//Disabling this screen, will use it in the future

class NewNumberPage extends StatefulWidget {
  const NewNumberPage({Key? key}) : super(key: key);

  @override
  _NewNumberPageState createState() => _NewNumberPageState();
}

class _NewNumberPageState extends State<NewNumberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Recover your account',
        style: TextStyle(color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children:  <Widget> [
          Padding(
            padding: EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.email),
                  contentPadding: EdgeInsets.all(10),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.zero,
                  )
                  ),
              ),
            ),
          ElevatedButton (onPressed: () => {
            Navigator.push(context, MaterialPageRoute(builder: (context) => GetStartedPage()))
          },
            child: Text('Continue',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 130,vertical: 15),
              primary: Colors.black,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
              elevation: 0,
              shadowColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
