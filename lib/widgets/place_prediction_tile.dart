import 'package:flutter/material.dart';
import 'package:parcel_you/global/map_key.dart';
import 'package:parcel_you/infoHandler/app_info.dart';
import 'package:parcel_you/method/request_assistant.dart';
import 'package:parcel_you/models/directions.dart';
import 'package:parcel_you/models/predicted_places.dart';
import 'package:provider/provider.dart';

class PlacePredictionTileDesign extends StatelessWidget {

  final PredictedPlaces? predictedPlaces;

   PlacePredictionTileDesign({this.predictedPlaces});

  getPlaceDirectionDetails(String? placeId, context) async{


    String placeDirectionDetailsUrl = "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey";

   var responseApi =  await RequestAssistant.receiveRequest(placeDirectionDetailsUrl);

   //Navigator.pop(context);

   if(responseApi == "Error Occurred, Failed. No Response.") {
     return;
   }
   if (responseApi["status"] == "OK") {

     Directions directions = Directions();
    directions.locationName = responseApi["result"]["name"];
    directions.locationId = placeId;
    directions.locationLatitude = responseApi["result"]["geometry"]["location"]["lat"];
    directions.locationLongitude = responseApi["result"]["geometry"]["location"]["lng"];

    Provider.of<AppInfo>(context, listen: false).updateDropOffLocationAddress(directions);

    Navigator.pop(context, "obtainedDropoff");

   }

  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: ElevatedButton(
        onPressed: () {
          getPlaceDirectionDetails(predictedPlaces!.place_id, context);
        },

        style: ElevatedButton.styleFrom(
          elevation: 0,
          primary: Colors.white,
        ),

        child: Row(
          children:[
             Icon(Icons.adjust_rounded,
            color: Colors.grey.shade900,
            ),
            const SizedBox(width: 14.0,),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    predictedPlaces!.main_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2,),
                  Text(predictedPlaces!.secondary_text!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8,),
                ],

              ),

            ),
          ],
        ),

 ),
    );
  }
}
