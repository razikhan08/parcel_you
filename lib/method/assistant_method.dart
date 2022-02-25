
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/global/map_key.dart';
import 'package:parcel_you/infoHandler/app_info.dart';
import 'package:parcel_you/method/request_assistant.dart';
import 'package:parcel_you/models/directions.dart';
import 'package:parcel_you/models/directions_details.dart';
import 'package:parcel_you/models/model_user.dart';
import 'package:provider/provider.dart';

class AssistantMethods {

  static Future<String> searchAddressForGeographicCoordinates(Position position, context) async {

    String apiUrl = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress ="";

   var requestResponse = await RequestAssistant.receiveRequest(apiUrl);

   if (requestResponse != "Error Occurred, Failed. No Response.") {

    humanReadableAddress = requestResponse["results"][0]["formatted_address"];

    Directions userPickUpAddress = Directions();
    userPickUpAddress.locationLatitude = position.latitude;
    userPickUpAddress.locationLongitude = position.longitude;
    userPickUpAddress.locationName = humanReadableAddress;

    Provider.of<AppInfo>(context, listen: false).updatePickUpLocationAddress(userPickUpAddress);

   }
   return humanReadableAddress;
  }

  static void readCurrentOnlineUserInfo() async {
    currentFirebaseUser = fbAuth.currentUser;

    DatabaseReference userRef = FirebaseDatabase.instance.ref().
    child("User's Information").
    child(currentFirebaseUser!.uid);

    userRef.once().then((snap){

      if (snap.snapshot.value != null)
      {

       userModelCurrentInfo = UserModel.fromSnapShot(snap.snapshot);
      }
    });
  }


  static Future<DirectionsDetailsInfo?> getOriginToDestinationDirections(LatLng originPosition, LatLng destinationPosition) async{

    String urlOriginToDestinationDirections = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";

   var responseDirectionsApi = await RequestAssistant.receiveRequest(urlOriginToDestinationDirections);

   if(responseDirectionsApi == "Error Occurred, Failed. No Response."){

     return null;
   }


   DirectionsDetailsInfo directionsDetailsInfo = DirectionsDetailsInfo();
   directionsDetailsInfo.e_points = responseDirectionsApi["routes"][0]["overview_polyline"]["points"];

  directionsDetailsInfo.distance_text = responseDirectionsApi["routes"][0]["legs"][0]["distance"]["text"];
   directionsDetailsInfo.distance_value = responseDirectionsApi ["routes"][0]["legs"][0]["distance"]["value"];

    directionsDetailsInfo.duration_text = responseDirectionsApi["routes"][0]["legs"][0]["duration"]["text"];
   directionsDetailsInfo.duration_value = responseDirectionsApi["routes"][0]["legs"][0]["duration"]["value"];

   return directionsDetailsInfo;

  }

  static int estimateFares(DirectionsDetailsInfo details){
    // per KM = $0.15,
    // per minute = $0.50,
    // base fare = $2.50,
    // booking fee = $2.10,

    double baseFare = 2.50;
    double distanceFare = (details.distance_value!/1000) * 0.15;
    double durationFare = (details.duration_value!/60) * 0.5;
    double bookingFee = 2.10;

    double totalFare = baseFare + distanceFare + durationFare + bookingFee;

    return totalFare.truncate();

  }

}