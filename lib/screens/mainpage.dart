import 'dart:async';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:platform/platform.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/Widgets/BrandDivider.dart';
import 'package:uber_app/Widgets/TaxiButton.dart';
import 'package:uber_app/Widgets/progressdialogue.dart';
import 'package:uber_app/brand_colors.dart';
import 'package:uber_app/datamodels/directiondetails.dart';
import 'package:uber_app/datamodels/nearbydriver.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/globalvariables.dart';
import 'package:uber_app/helpers/firehelper.dart';
import 'package:uber_app/helpers/helpermethods.dart';
import 'package:uber_app/screens/searchpage.dart';
import 'package:uber_app/styles/styles.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class MainPage extends StatefulWidget {
  static const String id = 'mainpage';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double rideDetailsSheetHeight = 0;//(Platform.isAndroid)?235:260
  double searchDetailsSheetHeight = 275;//(Platform.isIOS)?300:275
  double requestingSheetHeight=0;//(Platform.isAndroid)?195:220

  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;

  List<LatLng> polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  Set<Marker> _Markers = {};
  Set<Circle> _Circles = {};

  BitmapDescriptor nearbyIcon;

  var geoLocator = Geolocator();
  Position currentPosition;

  DirectionDetails tripDirectionDetails;

  bool drawerCanOpen = true;

  DatabaseReference rideRef;

  bool nearbyDriverKeyIsLoaded=false;

  void setUpPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(target: pos, zoom: 14.0);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await HelperMethods.findCoordinateAddress(position, context);
    startGeofireListener();
  }

  void showDetailSheet() async {
    await getDirection();

    setState(() {
      searchDetailsSheetHeight = 0;
      rideDetailsSheetHeight = 235;
      mapBottomPadding = 240;
      drawerCanOpen = false;
    });
  }

  void showRequestingSheet(){
    setState(() {
      rideDetailsSheetHeight=0;
      requestingSheetHeight=195;
      mapBottomPadding=200;
      drawerCanOpen=true;
    });
    createRideRequest();
  }

  void createMarker(){
    if(nearbyIcon==null)
      {
        ImageConfiguration imageConfiguration=createLocalImageConfiguration(context,size:Size(2,2));
        BitmapDescriptor.fromAssetImage(imageConfiguration,
            'images/car_android.png'
            /*(Platform.isIos)
            ?'images/car_ios.png'
            :'images/car_android.png'*/
          ).then((icon) {
            nearbyIcon=icon;
        });

      }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

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
            initialCameraPosition: googlePlex,
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
                if (drawerCanOpen)
                  scaffoldKey.currentState.openDrawer();
                else
                  resetApp();
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
                    (drawerCanOpen) ? Icons.menu : Icons.arrow_back,
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
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                height: searchDetailsSheetHeight,
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
                        onTap: () async {
                          var response = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()));

                          if (response == 'getDirection') {
                            await showDetailSheet();
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
            ),
          ),

          //Ride Details Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              duration: new Duration(milliseconds: 150),
              vsync: this,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ]),
                height: rideDetailsSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: <Widget>[
                              Image(
                                height: 70.0,
                                width: 70.0,
                                image: AssetImage('images/taxi.png'),
                              ),
                              SizedBox(
                                width: 16,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Taxi',
                                    style: TextStyle(
                                        fontSize: 18.0,
                                        fontFamily: 'Brand-Bold'),
                                  ),
                                  Text(
                                    (tripDirectionDetails != null)
                                        ? tripDirectionDetails.distanceText
                                        : '',
                                    style: TextStyle(
                                        fontSize: 16.0,
                                        color: BrandColors.colorTextLight),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                (tripDirectionDetails != null)
                                    ? '\$ ${HelperMethods.estimateFares(tripDirectionDetails)}'
                                    : '',
                                style: TextStyle(
                                    fontSize: 18.0, fontFamily: 'Brand-Bold'),
                              ),
                            ],
                          ),
                        ),
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: <Widget>[
                            Icon(
                              FontAwesomeIcons.moneyBillAlt,
                              size: 18,
                              color: BrandColors.colorTextLight,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Text('Cash'),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: BrandColors.colorTextLight,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: TaxiButton(
                          title: 'REQUEST CAB',
                          color: BrandColors.colorGreen,
                          onPressed: () {
                            showRequestingSheet();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),

          //Ride Requesting Sheet
          Positioned(
            left:0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        spreadRadius: 0.5,
                        offset: Offset(0.7, 0.7),
                      )
                    ],
                ),
                height: requestingSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical:18 ,horizontal:24 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: 10,),

                      //Animated text
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Ride...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: BrandColors.colorText,
                            fontSize: 22.0,
                            fontFamily: 'Brand-Bold',
                          ),
                          boxHeight: 40.0,
                        ),
                      ),

                      SizedBox(height: 20,),

                      //cancel ride icon
                      GestureDetector(
                        onTap: (){
                          cancelRequest();
                          resetApp();
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(width: 1.0,color: BrandColors.colorLightGrayFair),
                          ),
                          child: Icon(Icons.close,size: 25,),
                        ),
                      ),

                      SizedBox(height: 10,),

                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel Ride',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),


                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> getDirection() async {
    var pickup = Provider.of<AppData>(context, listen: false).pickUpAddress;
    var destination =
        Provider.of<AppData>(context, listen: false).destinationAddress;

    var pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    var destinationLatLng = LatLng(destination.latitude, destination.longitude);

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialogue(
              status: "Please Wait",
            ));

    var thisDetails =
        await HelperMethods.getDirectionDetails(pickLatLng, destinationLatLng);
        print('AMOL PI ${pickLatLng.latitude}');
        print(pickLatLng.longitude);
        print(destinationLatLng.latitude);
        print(destinationLatLng.longitude);

    setState(() {
      tripDirectionDetails = thisDetails;
    });

    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results =
        polylinePoints.decodePolyline(thisDetails.encodedPoints);

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

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds =
          LatLngBounds(southwest: destinationLatLng, northeast: pickLatLng);
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
          southwest: LatLng(pickLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickLatLng.longitude));
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
          southwest: LatLng(destinationLatLng.latitude, pickLatLng.longitude),
          northeast: LatLng(pickLatLng.latitude, destinationLatLng.longitude));
    } else {
      bounds =
          LatLngBounds(southwest: pickLatLng, northeast: destinationLatLng);
    }
    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: pickup.placeName, snippet: 'My Location'),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow:
          InfoWindow(title: destination.placeName, snippet: 'Destination'),
    );

    setState(() {
      _Markers.add(pickupMarker);
      _Markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
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

  void startGeofireListener() {
    
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 1).listen((map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyDriver nearbyDriver=NearbyDriver();
            nearbyDriver.key=map['key'];
            nearbyDriver.latitude=map['latitude'];
            nearbyDriver.longitude=map['longitude'];
            FireHelper.nearbyDriverList.add(nearbyDriver);

            if(nearbyDriverKeyIsLoaded)
              {
                updateDriversOnMap();
              }
            break;

          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDriversOnMap();
            break;

          case Geofire.onKeyMoved:
          // Update your key's location
            NearbyDriver nearbyDriver=NearbyDriver();
            nearbyDriver.key=map['key'];
            nearbyDriver.latitude=map['latitude'];
            nearbyDriver.longitude=map['longitude'];
            FireHelper.updateNearbyLocation(nearbyDriver);
            updateDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
          // All Intial Data is loaded
           // print('FireHelper length :${FireHelper.nearbyDriverList.length}');
          nearbyDriverKeyIsLoaded=true;
          updateDriversOnMap();
            break;
        }
      }
    });
  }

  void updateDriversOnMap() {
    setState(() {
      _Markers.clear();
    });

    Set<Marker> tempMarkers= {};
    for(NearbyDriver driver in FireHelper.nearbyDriverList){
      LatLng driverPosition=LatLng(driver.latitude,driver.longitude);
      Marker thisMarker=Marker(
          markerId: MarkerId('driver ${driver.key}'),
        position: driverPosition,
        icon:nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );
      tempMarkers.add(thisMarker);
    }
    setState(() {
      _Markers=tempMarkers;
    });
  }

  void createRideRequest(){
    rideRef=FirebaseDatabase.instance.reference().child('rideRequest').push();

    var pickup=Provider.of<AppData>(context,listen: false).pickUpAddress;
    var destination=Provider.of<AppData>(context,listen: false).destinationAddress;

    Map pickupMap={
      'latitude':pickup.latitude.toString(),
      'longitude':pickup.longitude.toString(),
    };
    Map destinationMap={
      'latitude':destination.latitude.toString(),
      'longitude':destination.longitude.toString(),
    };
    Map rideMap={
      'created_at':DateTime.now().toString(),
      'rider_name':currentUserInfo.fullName,
      'rider_phone':currentUserInfo.phone,
      'pickup_address':pickup.placeName,
      'destination_address':destination.placeName,
      'location':pickupMap,
      'destination':destinationMap,
      'payment_method':'card',
      'driver_id':'waiting',
    };
    rideRef.set(rideMap);

  }

  void cancelRequest(){
    rideRef.remove();

  }

  resetApp() {
    setState(() {
      polylineCoordinates.clear();
      _polylines.clear();
      _Markers.clear();
      _Circles.clear();
      rideDetailsSheetHeight = 0;
      requestingSheetHeight=0;
      searchDetailsSheetHeight = 275;
      mapBottomPadding = 280;
      drawerCanOpen = true;
    });
    setUpPositionLocator();
  }
}
