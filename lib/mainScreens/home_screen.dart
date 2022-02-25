import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:parcel_you/mainScreens/parcel_sender_or_receiver_info.dart';
import 'package:parcel_you/global/global.dart';
import 'package:parcel_you/method/assistant_method.dart';
import '../widgets/drawer.dart';

class HomeScreen extends StatefulWidget {

  String? name;

  HomeScreen({this.name});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Completer<GoogleMapController> _googleMapController = Completer();

  GoogleMapController? newGoogleMapController;
  // Controller for the Map//

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Position? userCurrentPosition;
  var geoLocator = Geolocator();

  LocationPermission? _locationPermission;

  String userName = "";

  checkIfLocationPermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();

    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    }
  }


  locateUserPosition() async {
    Position cPosition =  await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);

    CameraPosition cameraPosition = CameraPosition(target: latLngPosition, zoom: 14);

    newGoogleMapController!.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String humanReadableAddress = await AssistantMethods.searchAddressForGeographicCoordinates(userCurrentPosition!, context);
    print("this is your address =" + humanReadableAddress);

    userName = userModelCurrentInfo!.name!;
  }


  @override
  void initState() {
    super.initState();

    checkIfLocationPermissionAllowed();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      endDrawer: MyDrawer(name: userName), //username
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Circle Avatar - Open Drawer//
          Positioned(
            top: 60,
            right: 10,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState!.openEndDrawer();
              },
              child: const CircleAvatar(
                backgroundColor: Colors.blueGrey,
                child: Icon(Icons.person,
                  color: Colors.white,
                ),
              ),
            ),
          ),

         // Rest of the Screen//
          Positioned(
            top: 50,
            bottom: 0,
            right: 20,
            left: 20,
            child: Column(
              children:<Widget> [
                SizedBox(height: 15,),

                // Welcome $USER//
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      child: Text("Welcome " + userName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black

                        ),
                      ),
                    ),
                  ],
                ),

               SizedBox(height: 20,),

               // What to send container//
               Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(8),
                   color: Colors.black,
                   boxShadow: const [BoxShadow(
                     color: Colors.black,
                     offset: Offset(0.0, 1.0), //(x,y)
                     blurRadius: 1.0,
                   ),
                   ],
                 ),
                 height: 50,
                 width: 350,
                 child: TextButton.icon(
                   onPressed: () {
                     _openBottomSheetDrawer();
                   }, //will add this later //
                     icon: Icon(Icons.info, color: Colors.white,),
                     label: Text('Parcel Guidelines',
                       style: TextStyle( color: Colors.white, fontSize: 18),
                     )

                 ),
               ),



               SizedBox(height: 30,),

               //Google Map Container//
               Container(
                 decoration: BoxDecoration(
                   borderRadius: BorderRadius.circular(0),
                   boxShadow: const [BoxShadow(
                     color: Colors.white,
                     offset: Offset(0.0, 1.0), //(x,y)
                     blurRadius: 0.0,
                   ),
                   ],
                 ),
                 height: 300,
                 width: 400,
                 child: GoogleMap(
                   trafficEnabled: true,
                   mapType: MapType.normal,
                   myLocationEnabled: true,
                   zoomGesturesEnabled: true,
                   zoomControlsEnabled: true,
                   initialCameraPosition: _kGooglePlex,
                   onMapCreated: (GoogleMapController mapController) {
                     _googleMapController.complete(mapController);
                     newGoogleMapController = mapController;
                     locateUserPosition();
                   },
                 ),
               ),

                SizedBox(height: 30,),

                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:<Widget> [

                      //navigate to parcel info screen//
                      GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (c) => ParcelInfo ()));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow:  const [BoxShadow(
                              color: Colors.black,
                              offset: Offset(0.0, 1.0), //(x,y)
                            ),
                            ],
                          ),
                          height: 100,
                          width: 165,
                          child: Center(child: Text('Send a Parcel',
                          style: TextStyle(fontSize: 18,
                          fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15,),

                      // navigate to "Parcel Info" screen
                      GestureDetector(
                        onTap: () { Navigator.push(context, MaterialPageRoute(builder: (c) =>  ParcelInfo()));},
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: const [BoxShadow(
                                color: Colors.blueGrey,
                                offset: Offset(0.0, 1.0), //(x,y)
                              ),
                              ],
                            ),
                            height: 100,
                            width: 165,
                            child: Center(
                              child: Text('Receive a Parcel',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ),
                        ),
                      ),

                      // navigate to "receive a parcel" screen
                    ],
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  void _openBottomSheetDrawer(){
    showModalBottomSheet(context: context, builder: (context) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget> [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
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
