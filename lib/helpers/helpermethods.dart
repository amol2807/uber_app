
import 'package:connectivity/connectivity.dart';
import 'package:geolocator/geolocator.dart';
import 'package:uber_app/datamodels/address.dart';
import 'package:uber_app/dataproviders/appdata.dart';
import 'package:uber_app/helpers/requesthelper.dart';
import 'package:provider/provider.dart';

class HelperMethods{

  static Future<String>findCordinateAddress(Position position,context) async{

    String placeAddress='';

    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi)
      return placeAddress;
    String url='https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=AIzaSyCGDOgE33dc-6UHtIAptXSAVZRogFvV8Hs';
    var response=await RequestHelper.getRequest(url);
    if(response!='failed'){
      placeAddress=response['results'][0]['formatted_address'];

      Address pickupAddress=new Address();
      pickupAddress.longitude=position.longitude;
      pickupAddress.latitude=position.latitude;
      pickupAddress.placeName=placeAddress;

      Provider.of<AppData>(context,listen: false).updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }
}