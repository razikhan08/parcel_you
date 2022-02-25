import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:pinput/pin_put/pin_put.dart';

// Disabling this screen -- wil use it in the future//

class OTPScreen extends StatefulWidget {

  final String phone;
  final String isoCode;

  OTPScreen({required this.phone, required this.isoCode});

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController otpCodeController = TextEditingController();
  final FocusNode otpCodeFocus = FocusNode();
  String? verificationId;

  final BoxDecoration pinOTPCodeDecoration = BoxDecoration(
    color: Colors.grey.shade100,
    borderRadius: BorderRadius.zero,
    border: Border.all(
      color: Colors.transparent,
    )
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    verifyPhoneNumber();
  }

  verifyPhoneNumber() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "${widget.isoCode + widget.phone}",
      verificationCompleted: (PhoneAuthCredential credential) async {

        await FirebaseAuth.instance.signInWithCredential(credential).then((value){
          if(value.user != null){

      //      Navigator.of(context).push(MaterialPageRoute(builder: (c) => HomePage()));
          }

        });
      },

      verificationFailed: (FirebaseAuthException e)
        {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message.toString()),
                duration: Duration(seconds: 3),
              )
          );
        },
      codeSent: (String vID, int? resentToken)
        {
          setState(() {
            verificationId = vID;
          });
        },
      codeAutoRetrievalTimeout: (String vID)
        {
          setState(() {
            verificationId = vID;
          });
        },

        timeout: Duration(seconds: 10),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: _scaffoldKey,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children:  <Widget>[
          Center(
            child: Text('Enter the code',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            ),
          ),
          SizedBox(height: 10,),
          Text("Enter the code sent to ${widget.isoCode} ${widget.phone}"),
          SizedBox(height: 20,),
          Padding(
            padding: EdgeInsets.fromLTRB(40, 10, 40, 40),
            child: PinPut(
              autofocus: true,
              fieldsCount: 6,
              textStyle: TextStyle(fontSize: 25,color: Colors.black),
              eachFieldHeight: 30.0,
              eachFieldWidth: 20.0,
              focusNode: otpCodeFocus,
              controller: otpCodeController,
              submittedFieldDecoration: pinOTPCodeDecoration,
              selectedFieldDecoration: pinOTPCodeDecoration,
              followingFieldDecoration: pinOTPCodeDecoration,
              onSubmit: (pin) async
              {
                try{
                  await FirebaseAuth.instance.
                  signInWithCredential(PhoneAuthProvider.
                  credential(verificationId: verificationId!,
                      smsCode: pin))
                      .then((value) {
                    if(value.user != null){

                  //    Navigator.of(context).push(MaterialPageRoute(builder: (c) {
                     //   return HomePage();
               //       }));
                    }
                  });
                }
                catch(e){
                  FocusScope.of(context).unfocus();
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid OTP'),
                        duration: Duration(seconds: 3),
                      )
                  );
                }
              },

            ),
          ),
          GestureDetector(
            onTap: () {
               verifyPhoneNumber();
            },
            child: Text('Did not receive the code?',
              style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15),

            ),
          ),

          SizedBox(height: 20,),

          ElevatedButton (onPressed: () async {
            String pin = otpCodeController.text.trim();
            try{

              await FirebaseAuth.instance.
              signInWithCredential(PhoneAuthProvider.
              credential(verificationId: verificationId!,
                  smsCode: pin))
                  .then((value) {
                if(value.user != null){

               //   Navigator.of(context).push(MaterialPageRoute(builder: (c) => HomePage()));
                }
              });
            }
            catch(e){
              FocusScope.of(context).unfocus();
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter the correct code'),
                    duration: Duration(seconds: 3),
                  )
              );
            }
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
