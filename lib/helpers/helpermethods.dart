import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/datamodels/address.dart';
import 'package:uber_app/datamodels/user.dart';
import 'package:uber_app/datamodels/directiondetails.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/globalvariables.dart';
import 'package:uber_app/helpers/RequestHelper.dart';

class HelperMethods{
  static void getCurrentUserInfo() async{
    currentFirebaseUser = FirebaseAuth.instance.currentUser;
    String userid=currentFirebaseUser.uid;

    DatabaseReference userRef=FirebaseDatabase().reference().child('users/$userid');
    userRef.once().then((DataSnapshot snapshot){

      if(snapshot.value!=null){
        currentUserInfo=CabUser.fromSnapshot(snapshot);
        print('my name is ${currentUserInfo.fullName}');
      }
    });
  }
  static Future<String> findCoordinateAddress(Position position, context) async{

    String placeaddress = '';

    var connectivityResult =
    await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi)
    return placeaddress;

String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';

     var response = await RequestHelper.getRequest(url);
     if(response!='failed'){

       placeaddress = response['results'][0]['formatted_address'];

       Address pickUpAddress = new Address();
       pickUpAddress.longitude = position.longitude;
       pickUpAddress.latitude = position.latitude;
       pickUpAddress.placeName = placeaddress;

       Provider.of<AppData>(context,listen: false).updatePickUpAddress(pickUpAddress);

     }
     return placeaddress;

 //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Time Square&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs&sessiontoken=123254251&components=country:us
    }
    static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {
   String url =
'https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';

      var response = await RequestHelper.getRequest(url);
      if (response == 'failed')
      {
        print("failed");
        return null;
      }
      DirectionDetails directionDetails=DirectionDetails();
      directionDetails.durationText=response['routes'][0]['legs'][0]['duration']['text'];
      directionDetails.durationValue=response['routes'][0]['legs'][0]['duration']['value'];
      directionDetails.distanceText=response['routes'][0]['legs'][0]['distance']['text'];
      directionDetails.distanceValue=response['routes'][0]['legs'][0]['distance']['value'];
      directionDetails.encodedPoints=response['routes'][0]['overview_polyline']['points'];
      return directionDetails;
    }
    static int estimateFares(DirectionDetails details)
    {
      //per km = 0.3$
      //per min = 0.2$
      //base fare = 3$
      double baseFare = 3;
      double distanceFare = (details.distanceValue/1000)*0.3;
      print('Distant to Pune is ${details.distanceValue}');
      print('TIME to Pune is ${details.durationValue}');
      double timeFare = (details.durationValue/60)*0.2;
      double totalFare = baseFare + distanceFare + timeFare;
      print('BaseFare is ${baseFare}');
      print(timeFare);
      print(distanceFare);
      print(totalFare);

      return totalFare.truncate();

    }

}