import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:parcel_you/future_use_screens/recover_account_page.dart';
import 'package:parcel_you/future_use_screens/otp_screen.dart';

//Disabling this page for now -- will use it in future//


class GetStartedPage extends StatefulWidget {
  const GetStartedPage({Key? key}) : super(key: key);
  @override
  _GetStartedPageState createState() => _GetStartedPageState();

}

class _GetStartedPageState extends State<GetStartedPage> {

  String isoCode = "+1";
  TextEditingController phoneNumber = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget> [
                Text('Provide your number',
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20),
                ),
                SizedBox(height: 10),
                Text('We will verify your phone number'),
                SizedBox(height: 20,),
                Row(
                  children:<Widget> [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
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

                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 0, 20, 0),
                        child: Form(
                          key: _formKey,
                          child: TextFormField(
                            validator: (value) {
                              if (value!.isNotEmpty && value.length > 5) {
                                return null;
                              } else if (value.isEmpty && value.length < 10) {
                                return 'Please enter a valid phone number';
                              } else {
                                return 'Please make sure the phone number provided is correct';
                              }
                            },
                            keyboardType: TextInputType.number,
                            controller: phoneNumber,
                            autofocus: true,
                            inputFormatters: [LengthLimitingTextInputFormatter(15)],
                            decoration: InputDecoration(
                              focusedErrorBorder:  OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                                borderRadius: BorderRadius.zero,
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: const BorderSide(color: Colors.red),
                              ),
                                contentPadding: EdgeInsets.symmetric(vertical: 12),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.zero,
                                    borderSide: const BorderSide(color: Colors.black)
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
                SizedBox(height: 50,),
                ElevatedButton (
                  onPressed: () =>
                  {
                    if (_formKey.currentState!.validate()) {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (c) =>
                              OTPScreen(
                                phone: phoneNumber.text,
                                isoCode: isoCode,
                              ),
                          ))
                    },
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
                    elevation:0,
                    shadowColor: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) => NewNumberPage()));},
                  child: Text('Have a new number?',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),
          ),
        )
    );
  }
}
