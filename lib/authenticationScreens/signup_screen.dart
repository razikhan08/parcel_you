import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parcel_you/authenticationScreens/welcome_screen.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/splashscreen/splash_screen.dart';
import 'package:parcel_you/widgets/progress_dialog.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);


  @override
  _SignupScreenState createState() => _SignupScreenState();

}

class _SignupScreenState extends State<SignupScreen> {

  String isoCode = "+1";
  TextEditingController phoneNumber = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  showAlertDialog(BuildContext context) {
    Widget cancelButton = TextButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child: const Text('Cancel')
    );
    Widget logOutButton = TextButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (c) => WelcomeScreen()));

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

  TextEditingController nameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();
  TextEditingController confirmPasswordTextController = TextEditingController();

  validateForm(){
    if(nameTextController.text.isEmpty && emailTextController.text.isEmpty && phoneNumber.text.isEmpty && passwordTextController.text.isEmpty &&
        confirmPasswordTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please fill in all the required fields');
    }
    else if(nameTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must enter your name");
    }
    else if(nameTextController.text.length < 3) {
      Fluttertoast.showToast(msg: "You must enter a valid name");
    }
    else if(emailTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must enter your email");

    }
    else if(!emailTextController.text.contains("@")) {
      Fluttertoast.showToast(msg: "You must enter a valid email");
    }
    else if(passwordTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must enter your password");
    }
    else if(passwordTextController.text.length < 8) {
      Fluttertoast.showToast(msg: "Your password must be minimum 8 characters");
    }
    else if(confirmPasswordTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must confirm your password");
    }
    else if(!confirmPasswordTextController.text.contains(passwordTextController.text)) {
      Fluttertoast.showToast(msg: "Passwords do not match");
    }
    else {
      saveUserInfo();
    }
  }

  saveUserInfo() async  {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c)
        {
          return ProgressDialog(message: 'Please wait');
        }

    );

    final User? firebaseUser = (
        await fbAuth.createUserWithEmailAndPassword(

          email: emailTextController.text.trim(), password: passwordTextController.text.trim(),
        ).catchError((msg){
          Navigator.pop(context);
          Fluttertoast.showToast(msg: "Error" + msg.toString());
        })
    ).user;

    await fbAuth.currentUser?.sendEmailVerification();

    if (firebaseUser != null) {

      Map userMap = {

        "id": firebaseUser.uid,
        "name": nameTextController.text.trim(),
        "email": emailTextController.text.trim(),
        "password": passwordTextController.text.trim(),
        "number": phoneNumber.text.trim(),
      };

      DatabaseReference userInfo =  FirebaseDatabase.instance.ref().child("User's Information");
      userInfo.child(firebaseUser.uid).set(userMap);

      Fluttertoast.showToast(msg: "Please wait while we setup your experience");
      currentFirebaseUser = firebaseUser;
      Navigator.push(context, MaterialPageRoute(builder: (c) => MySplashScreen()));


    }
    else{
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Account has not been created");
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              const SizedBox(height: 20,),
              const Center(
                child: Text('Enter details to continue',
                  style: TextStyle(fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Center(
                child: Form(
                  child: SizedBox(
                    width: 350,

                    //name field//
                    child:  TextFormField(
                        keyboardType: TextInputType.text,
                        controller: nameTextController,
                        decoration: const InputDecoration(
                          hintText: 'Name',
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                            borderRadius: BorderRadius.zero,
                          ),
                          focusedErrorBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.zero,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(color: Colors.black)
                          ),

                        )
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Center(
                child: Form(
                  child: SizedBox(
                    width: 350,

                    //email field
                    child: TextFormField(
                        controller: emailTextController,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedErrorBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.zero,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(color: Colors.black)
                          ),

                        )

                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                children:<Widget> [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),

                    //iso code field//
                    child: Container(
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)
                      ),
                      width: 100,
                      child: CountryCodePicker(
                        onChanged: (country){
                          setState(() {
                            isoCode = country.dialCode!;
                          });
                        },
                        initialSelection: "CA",
                        showFlagMain: true,
                        showOnlyCountryWhenClosed: false,

                        favorite: const ["+1", "USA", "+1", "CA"],
                      ),
                    ),
                  ),

                  //phone number field//
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: phoneNumber,
                          inputFormatters: [LengthLimitingTextInputFormatter(15)],
                          decoration: InputDecoration(
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.zero,
                              ),
                              focusedErrorBorder:  const OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.zero,
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                              focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: Colors.black)
                              ),
                              hintText: 'Phone number',
                              prefix: Padding(
                                padding: EdgeInsets.all(4),
                                child: Text(isoCode),
                              )
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Center(
                child: Form(
                  child: SizedBox(
                    width: 350,

                    //password field//
                    child: TextFormField(
                        controller: passwordTextController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: const InputDecoration(
                          hintText: 'Password',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedErrorBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.zero,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(color: Colors.black)
                          ),

                        )

                    ),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Center(
                child: Form(
                  child: SizedBox(
                    width: 350,
                    //confirm password field//
                    child: TextFormField(
                        controller: confirmPasswordTextController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: const InputDecoration(
                          hintText: 'Confirm Password',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedErrorBorder:  OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.zero,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.zero,
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.zero,
                              borderSide: BorderSide(color: Colors.black)
                          ),

                        )

                    ),
                  ),
                ),
              ),
              SizedBox(height: 30,),

              //continue button//
              ElevatedButton (
                onPressed: () {
                  validateForm();
                },
                child: const Text('Continue',
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
                  elevation:0,
                  shadowColor: Colors.black,
                ),
              ),
            ],

          ),
        )
    );

  }
}
