import 'package:parcel_you/models/active_nearby_drivers.dart';

 class GeoFireAssistant {

  static List<ActiveNearbyDrivers> activeNearbyDriversList =[];


  static void deleteOfflineDriver(String driverId){
   int indexNumber = activeNearbyDriversList.indexWhere((element) => element.driverId == driverId);
   activeNearbyDriversList.removeAt(indexNumber);
  }


  static void updateactiveNearbyDriversLocation(ActiveNearbyDrivers driversMovement){

   int indexNumber = activeNearbyDriversList.indexWhere((element) => element.driverId == driversMovement.driverId);

   activeNearbyDriversList[indexNumber].locationLatitude = driversMovement.locationLatitude;
   activeNearbyDriversList[indexNumber].locationLongitude = driversMovement.locationLongitude;
  }

}