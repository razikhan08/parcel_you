
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/mainScreens/search_places_screen.dart';
import 'package:parcel_you/mainScreens/send_package_screen.dart';

class ParcelInfo extends StatefulWidget {

  @override
  _ParcelInfoState createState() => _ParcelInfoState();
}

class _ParcelInfoState extends State<ParcelInfo> {
  late DatabaseReference receiversRef;



  // validate form for the fields//
  validateForm() async {
    if(receiversNameTextController.text.isEmpty &&  receiversPhoneNumber.text.isEmpty ) {
      Fluttertoast.showToast(msg: 'Please fill in all the required fields');
    }
    else if(receiversNameTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must enter your name");
    }
    else if(receiversNameTextController.text.length < 3) {
      Fluttertoast.showToast(msg: "You must enter a valid name");
    }
    else if(receiversPhoneNumber.text.isEmpty) {
      Fluttertoast.showToast(msg: "You must enter a valid number");
    }
    else {
      //obtainReceiversInfo();
       await Navigator.push(context, MaterialPageRoute(builder: (c) => SendPackageScreen(
        receiversName: receiversNameTextController.text.toString(),
        receiversPhoneNumber: receiversPhoneNumber.text.toString(),
         specialInstructions: specialInstructions.text.trim(),
       )));
    }
  }

  String isoCode = "+1";

  TextEditingController specialInstructions = TextEditingController();
  TextEditingController receiversPhoneNumber = TextEditingController();

  TextEditingController receiversNameTextController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  void obtainReceiversInfo(){

    receiversRef = FirebaseDatabase.instance.ref().child("receiversRef").push();

    Map receiversMap ={
      'user_id': fbAuth.currentUser!.uid,
      'receiver_name': receiversNameTextController.text,
      'receiver_number': receiversPhoneNumber.text,

    };
    receiversRef.set(receiversMap);


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        actions:<Widget> [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                side: BorderSide(color: Colors.grey.shade100),
                shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(0))
              ),
                onPressed: (){
                _openBottomSheetDrawer();
                },
                icon: Icon(Icons.info, color: Colors.black,),
                label: Text('Parcel Guidelines',
                style: TextStyle( color: Colors.black, fontSize: 13),
                )
            ),
          )
        ],
        leadingWidth: 75,
        iconTheme: IconThemeData(color: Colors.black),

        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Text('Who\'s the receiver?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10,),
            Text('The driver may contact the receiver.',
            style: TextStyle(fontSize: 16,),
            ),
            SizedBox(height:20),
            Form(
              child: SizedBox(
                width: 350,
                child:  TextFormField(
                    keyboardType: TextInputType.text,
                    controller: receiversNameTextController,
                    autofocus: true,
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
            SizedBox(height: 2,),

            //Phone number textfield//
            Row(
              children:<Widget> [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.black87)
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

                SizedBox(width:5,),

                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Form(
                      key: _formKey,
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        controller: receiversPhoneNumber,
                        autofocus: true,
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

            SizedBox(height: 10),

            Container(
              width: 350,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                border: Border.all(
                  color: Colors.grey.shade200,
                )
              ),
              child: TextField(
                controller: specialInstructions,
                maxLines: 12,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(4),
                  hintText: "Any special instructions",
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade200
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade200
                    )
                  )
                ),


              ),

            ),

            SizedBox(height: 10,),

            //continue button//
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,0),
              child: ElevatedButton (
                onPressed: () {
                  validateForm();
                },
                child: const Text('Continue',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 130,vertical: 15),
                  primary: Colors.black,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                  elevation:0,
                  shadowColor: Colors.black,
                ),
              ),
            ),

          ],
        ),
      ),
      
    );
  }
  void _openBottomSheetDrawer(){
    showModalBottomSheet(context: context, builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
           const Center(
             child: Padding(
               padding: EdgeInsets.all(16.0),
               child: Text("Conditions & Guidelines",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold
                ),
                ),
             ),
           ),
          Row(
            children: const [
              Expanded(child: Divider(height: 10, thickness: 1,)),
            ],
          ),
          SizedBox(height: 10,),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('Read the following guidelines:',
            style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 15,),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('Parcel is sealed and secured correctly',
            style: TextStyle(fontSize: 16)

            )
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('Parcel does not contain any prohibited or illegal items',
              style: TextStyle(fontSize: 16)
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('Parcel does not contain firearms, explosives material, illegal substances or recreational drugs',
              style: TextStyle(fontSize: 16)
          ),
      ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('Continuing to send with ParcelYou, you are agreeing to the mentioned above',
              style: TextStyle(fontSize: 16)
          ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
            child: Text('For any violations, authorities maybe involved',
                style: TextStyle(fontSize: 16)
            ),
          ),
          SizedBox(height: 30,),
          Padding(
            padding:  const EdgeInsets.all(8),
            child: Center(
              child: ElevatedButton (
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('I Understand',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontWeight: FontWeight.normal,
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
            ),
          ),
        ],



      );


    });

  }
}


