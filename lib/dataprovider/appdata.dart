import 'package:flutter/material.dart';
import 'package:uber_app/datamodels/address.dart';

class AppData extends ChangeNotifier{

  Address pickUpAddress;
  Address destinationAddress;

  void updatePickUpAddress(Address pickUp)
  {
    pickUpAddress = pickUp;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination)
  {
    destinationAddress = destination;
    notifyListeners();
  }




}