import 'package:flutter/cupertino.dart';
import 'package:uber_app/datamodels/address.dart';

class AppData extends ChangeNotifier{
  Address pickupAddress;
  void updatePickupAddress(Address pickup){
    pickupAddress=pickup;
    notifyListeners();
  }
}