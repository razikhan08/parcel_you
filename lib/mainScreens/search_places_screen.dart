import 'package:flutter/material.dart';
import 'package:parcel_you/global/map_key.dart';
import 'package:parcel_you/method/request_assistant.dart';
import 'package:parcel_you/models/predicted_places.dart';
import 'package:parcel_you/widgets/place_prediction_tile.dart';
import 'package:provider/provider.dart';

import '../infoHandler/app_info.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({Key? key}) : super(key: key);

  @override
  _SearchPlacesScreenState createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {

  List<PredictedPlaces> placePredictedList = [];

  void findPlaceAutoCompleteSearch(String inputText) async {

    if(inputText.length > 1) {

      String urlAutoCompleteSearch = "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$inputText&key=$mapKey";
     var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

     if(responseAutoCompleteSearch == "Error Occurred, Failed. No Response.")
     {
       return;
     }
     if(responseAutoCompleteSearch["status"] == "OK") {
       var  placesPredictions = responseAutoCompleteSearch["predictions"];

      var placePredictionList = (placesPredictions as List).map((jsonData) => PredictedPlaces.fromJson(jsonData)).toList();

      setState(() {
        placePredictedList = placePredictionList;
      });
     }

      }
  }

  var pickupController = TextEditingController();

  var focusDestination = FocusNode();

  bool focused = false;
  void setFocus(){
    if(!focused) {
      FocusScope.of(context).requestFocus(focusDestination);
      focused= true;
    }

  }

  @override
  Widget build(BuildContext context) {
    setFocus();
    String userPickUpLocation = Provider.of<AppInfo>(context).userPickUpLocation!.locationName ?? 'Current Location';
    pickupController.text = userPickUpLocation;
    return Scaffold(
      body: Column(
        children: [
          //search place ui
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 8,
                  spreadRadius: 0.5,
                  offset: Offset(
                    0.7,
                    0.7,
                  ),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 24, top: 48, right: 24, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children:<Widget> [
                  Stack(
                    children:  [
                      GestureDetector(
                        onTap: (){Navigator.pop(context);
                          },
                          child: Icon(Icons.arrow_back_ios_new)),
                      Center(
                        child: Text("Enter Destination",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                        ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 10,),
                  Row(
                    children: [
                      Icon(Icons.adjust_sharp,
                      color: Colors.black
                      ),
                      SizedBox(width: 2,),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: TextField(
                            controller: pickupController,

                            decoration:  InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.zero,
                                borderSide: BorderSide(color: Colors.grey.shade400)
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11,
                                top: 8,
                                bottom: 8,

                              ),
                            ),


                          ),
                        ),
                      ),


                    ],
                  ),
                  Row(
                    children:  [
                      Icon(Icons.adjust_sharp,
                        color: Colors.black,
                      ),
                      SizedBox(width: 2,),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
                          child: TextField(
                            focusNode: focusDestination,
                            onChanged: (valueTyped) {
                              findPlaceAutoCompleteSearch(valueTyped);
                            },
                            decoration:  InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.zero,
                                  borderSide: BorderSide(color: Colors.grey.shade400)
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.zero
                              ),
                              hintText: "Enter Destination",
                              fillColor: Colors.white,
                              filled: true,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.only(
                                left: 11,
                                top: 8,
                                bottom: 8,

                              ),
                            ),


                          ),
                        ),
                      ),


                    ],
                  ),
                ],

              ),
            ),
          ),
          
         (placePredictedList.length > 0)
             ? Expanded(
           child: ListView.separated(
             itemCount: placePredictedList.length,
               physics: ClampingScrollPhysics(),
             itemBuilder: (context, index){
               return PlacePredictionTileDesign(predictedPlaces: placePredictedList[index]
               );
             },
             separatorBuilder: (BuildContext context, int index) {

                return  Divider(
                  color: Colors.grey.shade200,
                 height: 1,
                 thickness: 1,
               );
             }
           ),

         )
             : Container(),
          // Display place predictions results
        ],
      ),
    );
  }
}
