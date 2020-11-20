import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:uber_app/datamodels/address.dart';
import 'package:uber_app/dataprovider/appdata.dart';
import 'package:uber_app/helpers/RequestHelper.dart';

class HelperMethods{

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
       pickUpAddress.longitude = position.latitude;
       pickUpAddress.latitude = position.longitude;
       pickUpAddress.placeName = placeaddress;

       Provider.of<AppData>(context,listen: false).updatePickUpAddress(pickUpAddress);

     }
     return placeaddress;

 //https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Time Square&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs&sessiontoken=123254251&components=country:us



    }
}