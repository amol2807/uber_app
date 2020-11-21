import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Widgets/BrandDivider.dart';
import 'package:uber_app/Widgets/progressdialogue.dart';
import 'package:uber_app/brand_colors.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/helpers/helpermethods.dart';
import 'package:uber_app/screens/searchpage.dart';
import 'package:uber_app/styles/styles.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates=[];
  Set<Polyline> _polylines={};
  Set<Marker> _Markers={};
  Set<Circle> _Circles={};

  var geoLocator = Geolocator();
  Position currentPosition;

  void setUpPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 14.0);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await HelperMethods.findCoordinateAddress(position, context);
    print(address);
  }
  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: Container(
        width: 250.0,
        color: Colors.white,
        child: Drawer(
          child: ListView(
            padding: EdgeInsets.all(0),
            children: <Widget>[
              Container(
                height: 160.0,
                color: Colors.white,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: <Widget>[
                      Image(
                        height: 60.0,
                        width: 60.0,
                        image: AssetImage('images/user_icon.png'),
                      ),
                      SizedBox(
                        width: 20.0,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Amol',
                            style: TextStyle(
                                fontSize: 20, fontFamily: 'Brand-Bold'),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text('View Profile'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              BrandDivider(),

              SizedBox(
                height: 10.0,
              ),

              ListTile(
                leading: Icon(OMIcons.cardGiftcard),
                title: Text(
                  'Free Rides',
                  style: kDrawerItemStyle,
                ),
              ), // Free Rides
              ListTile(
                leading: Icon(OMIcons.creditCard),
                title: Text(
                  'Payments',
                  style: kDrawerItemStyle,
                ),
              ), // Payments
              ListTile(
                leading: Icon(OMIcons.history),
                title: Text(
                  'Ride History',
                  style: kDrawerItemStyle,
                ),
              ), //Ride History
              ListTile(
                leading: Icon(OMIcons.contactSupport),
                title: Text(
                  'Support',
                  style: kDrawerItemStyle,
                ),
              ), //
              ListTile(
                leading: Icon(OMIcons.info),
                title: Text(
                  'About',
                  style: kDrawerItemStyle,
                ),
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapBottomPadding),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: _polylines,
            markers: _Markers,
            circles: _Circles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              setState(() {
                mapBottomPadding = 275;
              });

              setUpPositionLocator();
            },
          ),

          //Menu Button
          Positioned(
            top: 44,
            left: 20,
            child: GestureDetector(
              onTap: () {
                scaffoldKey.currentState.openDrawer();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      spreadRadius: 0.5,
                      offset: Offset(0.7, 0.7),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 20.0,
                  child: Icon(
                    Icons.menu,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),

          // Search Sheet
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 275.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.6,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 5.0,
                    ),
                    Text(
                      'Nice to see you!',
                      style: TextStyle(
                        fontSize: 10.0,
                      ),
                    ),
                    Text(
                      'Where are you going?',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontFamily: 'Brand-Bold',
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    GestureDetector(
                      onTap: () async{
                        var response=await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SearchPage()));

                        if(response=='getDirection'){
                          await getDirection();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 5.0,
                              spreadRadius: 0.5,
                              offset: Offset(
                                7.0,
                                7.0,
                              ),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: <Widget>[
                              Icon(
                                Icons.search,
                                color: Colors.blueAccent,
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Text('Search Destination'),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 22.0,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          OMIcons.home,
                          color: BrandColors.colorDimText,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Add Home'),
                            Text(
                              'Your residential address',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: BrandColors.colorDimText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    BrandDivider(),
                    SizedBox(
                      height: 16.0,
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          OMIcons.workOutline,
                          color: BrandColors.colorDimText,
                        ),
                        SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Add Work'),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              'Your office address',
                              style: TextStyle(
                                fontSize: 11.0,
                                color: BrandColors.colorDimText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection()async {
    var pickup = Provider
        .of<AppData>(context, listen: false)
        .pickUpAddress;
    var destination = Provider
        .of<AppData>(context, listen: false)
        .destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(barrierDismissible: false,
        context: context,
        builder: (BuildContext context) =>
            ProgressDialogue(status: "Please Wait",)
    );


    var thisDetails = await HelperMethods.getDirectionDetails(
        pickLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(
        thisDetails.encodedPoints);

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      //loop through all PointLatLng points and convert them to a list of LatLng, required by the Polyline

      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }
    _polylines.clear();

    setState(() {
      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polylines.add(polyline);
    });

    //make polyline to fit into the map
    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude && pickLatLng.longitude > destinationLatLng.longitude) {
      bounds=LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    }
    else if(pickLatLng.longitude > destinationLatLng.longitude){
      bounds=LatLngBounds(
          southwest: LatLng(pickLatLng.latitude,destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude,pickLatLng.longitude));
    }
    else if(pickLatLng.latitude > destinationLatLng.latitude){
      bounds=LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude,pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude,destinationLatLng.longitude));
    }
    else{
      bounds=LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker=Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName,snippet: 'My Location'),
    );

    Marker destinationMarker=Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(title: destination.placeName,snippet: 'Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle=Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle=Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _Circles.add(pickupCircle);
      _Circles.add(destinationCircle);
    });
  }
}
