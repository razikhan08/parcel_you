import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/global/map_key.dart';
import 'package:parcel_you/infoHandler/app_info.dart';
import 'package:parcel_you/mainScreens/search_places_screen.dart';
import 'package:parcel_you/method/geofire_assistant.dart';
import 'package:parcel_you/models/active_nearby_drivers.dart';
import 'package:parcel_you/models/directions_details.dart';
import 'package:parcel_you/widgets/drawer.dart';
import 'package:provider/provider.dart';

import '../method/assistant_method.dart';

class SendPackageScreen extends StatefulWidget {

  final String receiversName;
  final String receiversPhoneNumber;
  final String specialInstructions;

  SendPackageScreen({required this.receiversName,required this.receiversPhoneNumber, required this.specialInstructions});


  @override
  _SendPackageScreenState createState() => _SendPackageScreenState();
}

class _SendPackageScreenState extends State<SendPackageScreen> with SingleTickerProviderStateMixin {

  final Completer<GoogleMapController> _googleMapController = Completer();

  GoogleMapController? newGoogleMapController;

  // Controller for the Map//


  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  double searchLocationContainerHeight = 250.0;
  double rideDetailsContainerHeight = 0;
  double requestingDriverContainerHeight = 0;

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  double bottomMapPadding = 0;

  List<LatLng> pLineCoordinatesList = [];
  Set<Polyline> polyLineSet = {};

  Set<Marker> markersSet = {};
  Set<Circle> circlesSet = {};

  DirectionsDetailsInfo? tripDirectionsDetails;

  late DatabaseReference rideRef;

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }


  bool drawerCanOpen = true;
  bool activeNearbyDriversKeysLoaded = false;

  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods
        .searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("this is your address =" + humanReadableAddress);

    initializeGeoListener();
  }

  //Show Details for the trip//
  void showDetailsSheet() async {
    await drawPolylineFromSourceToDestination();
    setState(() {
      searchLocationContainerHeight = 0;
      rideDetailsContainerHeight = 250;
      bottomMapPadding = 240;
      drawerCanOpen = false;
    });
  }


//Show details after ride is confirmed - looking for driver//
  void showDriverRequestingSheet() {
    setState(() {
      rideDetailsContainerHeight = 0;
      requestingDriverContainerHeight = 250;
      bottomMapPadding = 240;
    });
    createRideRequest();
  }


  void createRideRequest() {
    rideRef = FirebaseDatabase.instance.ref().child("rideRequest").push();

    var pickup = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;
    var destination = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;

    Map pickupMap = {
      'latitude': pickup!.locationLatitude.toString(),
      'longitude': pickup.locationLongitude.toString()
    };

    Map destinationMap = {
      'latitude': destination!.locationLatitude.toString(),
      'longitude': destination.locationLongitude.toString(),

    };

    Map rideMap = {
      'user_id': fbAuth.currentUser!.uid,
      'created_at': DateTime.now().toString(),
      'user_name': userModelCurrentInfo!.name,
      'user_number': userModelCurrentInfo!.number,
      'pickup_address': pickup.locationName,
      'destination_address': destination.locationName,
      'location': pickupMap,
      'destination': destinationMap,
      'payment_method': 'card',
      'driver_id': 'waiting',
      'receiver\'s_name': widget.receiversName,
      'receiver\'s_number': widget.receiversPhoneNumber,
      'special_instructions': widget.specialInstructions,
    };
    rideRef.set(rideMap);
  }


  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();
    AssistantMethods.readCurrentOnlineUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
          children: <Widget>[
            //Google Map View//
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomMapPadding),
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: GooglePlex,
              polylines: polyLineSet,
              markers: markersSet,
              circles: circlesSet,
              onMapCreated: (GoogleMapController mapController) {
                _googleMapController.complete(mapController);
                newGoogleMapController = mapController;
                setState(() {
                  bottomMapPadding = 250;
                });

                locateUserPosition();
              },
            ),

            // go back button//
            Positioned(
              top: 60,
              left: 10,
              child: GestureDetector(
                onTap: () {
                  if (drawerCanOpen) {
                    Navigator.pop(context);
                  } else {
                    resetApp();
                  }
                },

                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon((drawerCanOpen)
                      ? Icons.arrow_back_ios_new
                      : Icons.close,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // ui for for searching//
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              child: AnimatedSize(
                duration: Duration(milliseconds: 120),
                vsync: this,
                curve: Curves.easeIn,
                child: Container(
                  height: searchLocationContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.zero,
                      boxShadow: const [BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),

                      )
                      ]

                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(height: 5),

                        //Current Location Box/
                        Container(
                          decoration: BoxDecoration(color: Colors.white,
                              borderRadius: BorderRadius.zero,
                              boxShadow: const [BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),

                              )
                              ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.adjust_rounded,
                                  color: Colors.grey.shade900,),
                                SizedBox(width: 10,),
                                Text(Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation != null
                                    ? (Provider
                                    .of<AppInfo>(context)
                                    .userPickUpLocation!
                                    .locationName!).substring(0, 13)
                                    : "Current Location",

                                )


                              ],

                            ),
                          ),
                        ),
                        SizedBox(height: 10,),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                        SizedBox(height: 10,),

                        // Drop off Location Container//
                        GestureDetector(
                          onTap: () async {
                            var responseFromSearchScreen = await Navigator.push(
                                context, MaterialPageRoute(
                                builder: (c) => SearchPlacesScreen()));

                            if (responseFromSearchScreen == "obtainedDropoff") {
                              showDetailsSheet();
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white,
                                borderRadius: BorderRadius.zero,
                                boxShadow: const [BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(0.7, 0.7),

                                )
                                ]
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.adjust_rounded,
                                    color: Colors.grey.shade900,),
                                  SizedBox(width: 10,),
                                  Text(Provider
                                      .of<AppInfo>(context)
                                      .userDropOffLocation != null
                                      ? (Provider
                                      .of<AppInfo>(context)
                                      .userDropOffLocation!
                                      .locationName!)
                                      : "Destination"

                                  )


                                ],

                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                  ),

                ),
              ),


            ),

            // ui for Ride Estimate Panel//
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: Duration(microseconds: 120),
                curve: Curves.easeIn,
                vsync: this,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: rideDetailsContainerHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: <Widget>[
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Column(
                                    children: <Widget>[

                                      Text((tripDirectionsDetails != null)
                                          ? tripDirectionsDetails!
                                          .distance_text!
                                          : '',
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("Parcel U",
                                        style: TextStyle(fontSize: 15,
                                            fontWeight: FontWeight.bold),)


                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                Text((tripDirectionsDetails != null)
                                    ? '\$${AssistantMethods.estimateFares(
                                    tripDirectionsDetails!)}'
                                    : "", style: TextStyle(fontSize: 18,
                                    fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                        ),
                        // Ride Container//
                        Divider(
                          height: 0,
                          thickness: 1,
                          color: Colors.grey.shade300,
                        ),
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Row(
                                    children: const <Widget>[
                                      Icon(Icons.credit_card),
                                      Text("", style: TextStyle(fontSize: 15,
                                          fontWeight: FontWeight.bold),),
                                    ],
                                  ),
                                ),
                                Expanded(child: Container()),
                                Icon(Icons.arrow_forward_ios,
                                  size: 15,

                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 350,
                          child: ElevatedButton(
                              onPressed: () {
                                showDriverRequestingSheet();
                              },
                              child: Text('Confirm',
                                style: TextStyle(
                                  fontSize: 20,
                                ),
                              )
                          ),
                        ),
                      ],
                    ),

                  ),
                ),
              ),
            ),

            //loading analog container - while looking for a driver//
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                duration: Duration(microseconds: 130),
                vsync: this,
                curve: Curves.easeIn,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  height: requestingDriverContainerHeight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 10,),
                        SizedBox(
                          width: double.infinity,
                          child: TextLiquidFill(
                            text: 'Looking for a driver..',
                            waveColor: Colors.blueAccent,
                            boxBackgroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                            boxHeight: 40.0,
                          ),
                        ),
                        SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            cancelRequest();
                            resetApp();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Icon(Icons.close, size: 25),

                          ),
                        ),
                        //close button Icon//

                        const SizedBox(height: 10,),
                        Container(
                          width: double.infinity,
                          child: const Text('Cancel Driver',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),


                        ),

                      ],


                    ),
                  ),


                ),
              ),
            ),


          ],
        ),
      );
  }


  //Draw PolyLine from pickup to dropoff//
  Future<void> drawPolylineFromSourceToDestination() async {
    var sourcePosition = Provider
        .of<AppInfo>(context, listen: false)
        .userPickUpLocation;
    var destinationPosition = Provider
        .of<AppInfo>(context, listen: false)
        .userDropOffLocation;

    var sourceLatLng = LatLng(
        sourcePosition!.locationLatitude!, sourcePosition.locationLongitude!);
    var destinationLatLng = LatLng(destinationPosition!.locationLatitude!,
        destinationPosition.locationLongitude!);


    var directionsDetailsInfo = await AssistantMethods
        .getOriginToDestinationDirections(sourceLatLng, destinationLatLng);

    setState(() {
      tripDirectionsDetails = directionsDetailsInfo;
    });

    // Navigator.pop(context);

    print("These are point = ");
    print(directionsDetailsInfo!.e_points);

    PolylinePoints pLinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResultList = pLinePoints
        .decodePolyline(directionsDetailsInfo.e_points!);

    pLineCoordinatesList.clear();

    if (decodedPolylinePointsResultList.isNotEmpty) {
      decodedPolylinePointsResultList.forEach((PointLatLng pointLatLng) {
        pLineCoordinatesList.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polyLineSet.clear();

    setState(() {
      Polyline polyLine = Polyline(

        color: Colors.black,
        polylineId: const PolylineId("PolylineID"),
        jointType: JointType.round,
        points: pLineCoordinatesList,
        startCap: Cap.squareCap,
        endCap: Cap.squareCap,
        geodesic: true,
      );

      polyLineSet.add(polyLine);
    });

    LatLngBounds boundsLatLng;
    if (sourceLatLng.latitude > destinationLatLng.latitude &&
        sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLng, northeast: sourceLatLng);
    }
    else if (sourceLatLng.longitude > destinationLatLng.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
        northeast: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),

      );
    }
    else if (sourceLatLng.latitude > destinationLatLng.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, sourceLatLng.longitude),
        northeast: LatLng(sourceLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else {
      boundsLatLng =
          LatLngBounds(southwest: sourceLatLng, northeast: destinationLatLng);
    }
    newGoogleMapController!.animateCamera(
        CameraUpdate.newLatLngBounds(boundsLatLng, 65));

    Marker sourceMarker = Marker(
      markerId: MarkerId("sourceID"),
      infoWindow: InfoWindow(
          title: sourcePosition.locationName, snippet: "Source"),
      position: sourceLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),

    );


    Marker destinationMarker = Marker(
      markerId: MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Destination"),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),

    );

    setState(() {
      markersSet.add(sourceMarker);
      markersSet.add(destinationMarker);
    });


    Circle originCircle = Circle(
      circleId: CircleId("sourceID"),
      fillColor: Colors.red,
      radius: 12,
      strokeColor: Colors.blueGrey,
      strokeWidth: 3,
      center: sourceLatLng,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId("destinationID"),
      fillColor: Colors.yellow,
      radius: 12,
      strokeColor: Colors.blueGrey,
      strokeWidth: 3,
      center: destinationLatLng,
    );

    setState(() {
      circlesSet.add(originCircle);
      circlesSet.add(destinationCircle);
    });
  }

  //cancel Driver Request//
  void cancelRequest() {
    rideRef.remove();
  }


  // Cancel Request: things to happen//
  resetApp() {
    setState(() {
      pLineCoordinatesList.clear();
      polyLineSet.clear();
      markersSet.clear();
      circlesSet.clear();
      rideDetailsContainerHeight = 0;
      requestingDriverContainerHeight = 0;
      searchLocationContainerHeight = 250;
      bottomMapPadding = 240;
      drawerCanOpen = true;
    });
    locateUserPosition();
  }


  //Display Nearby Drivers//
  initializeGeoListener() {
    Geofire.initialize("activeDrivers");

    Geofire.queryAtLocation(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered: // when driver becomes active or online//
            ActiveNearbyDrivers activeNearbyDrivers = ActiveNearbyDrivers();
            activeNearbyDrivers.locationLatitude = map['latitude'];
            activeNearbyDrivers.locationLongitude =  map['longitude'];
            activeNearbyDrivers.driverId = map['key'];
            GeoFireAssistant.activeNearbyDriversList.add(activeNearbyDrivers);
            if(activeNearbyDriversKeysLoaded == true){
              displayActiveDriversOnMap();
            }
            break;

          case Geofire.onKeyExited: //when driver goes offline or non-active//
          GeoFireAssistant.deleteOfflineDriver(map['key']);
          displayActiveDriversOnMap();
            break;

          case Geofire.onKeyMoved: // this will be called whenever the driver moves -- update drive location//
            ActiveNearbyDrivers activeNearbyDrivers = ActiveNearbyDrivers();
            activeNearbyDrivers.locationLatitude = map['latitude'];
            activeNearbyDrivers.locationLongitude =  map['longitude'];
            activeNearbyDrivers.driverId = map['key'];
            GeoFireAssistant.updateactiveNearbyDriversLocation(activeNearbyDrivers);
            displayActiveDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:// display online drivers on the map//
          displayActiveDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
  }



//method for displaying active drivers//
  displayActiveDriversOnMap(){

    setState(() {
      markersSet.clear();
      circlesSet.clear();

      Set<Marker> driversMarkerSet = Set<Marker>();

      for(ActiveNearbyDrivers eachDriver in GeoFireAssistant.activeNearbyDriversList){

      LatLng eachDriverActivePosition =   LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);

      Marker marker = Marker(
        markerId: MarkerId(eachDriver.driverId!),
        position: eachDriverActivePosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        rotation: 360,
      );

      driversMarkerSet.add(marker);
      }

      setState(() {
        markersSet = driversMarkerSet;
      });

    });
  }
}

