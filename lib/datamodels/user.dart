

import 'package:firebase_database/firebase_database.dart';

class CabUser{
  String fullName;
  String email;
  String phone;
  String id;

  CabUser({this.email,this.phone,this.fullName,this.id});
  CabUser.fromSnapshot(DataSnapshot snapshot){
    id=snapshot.key;
    phone=snapshot.value['phone'];
    email=snapshot.value['email'];
    fullName=snapshot.value['fullname'];
  }
}