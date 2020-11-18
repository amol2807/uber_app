import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uber_app/Widgets/TaxiButton.dart';
import 'package:uber_app/Widgets/progressdialogue.dart';
import 'package:uber_app/screens/loginpage.dart';

import '../brand_colors.dart';
import 'mainpage.dart';

class RegistrationPage extends StatefulWidget {
  static const String id = 'register';

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var fullNameController = TextEditingController();
  var phoneController = TextEditingController();
  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  void registerUser() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => ProgressDialogue(
        status: 'Logging you in',
      ),
    );

    final User user = (await _auth
            .createUserWithEmailAndPassword(
      email: emailController.text,
      password: passwordController.text,
    )
            .catchError((ex) {
      Navigator.pop(context);
      PlatformException thisEx = ex;
      print(thisEx.message.toString());
    }))
        .user;
//    } on FirebaseAuthException catch (e) {
//      if (e.code == 'weak-password') {
//        print('The password provided is too weak.');
//      } else if (e.code == 'email-already-in-use') {
//        print('The account already exists for that email.');
//      }
//    } catch (e) {
//      print(e);
//    }

    Navigator.pop(context);
    if (user != null) {
      DatabaseReference newUserRef =
          FirebaseDatabase.instance.reference().child('users/${user.uid}');

      Map userMap = {
        'fullname': fullNameController.text,
        'email': emailController.text,
        'phone': phoneController.text,
      };

      newUserRef.set(userMap);

      // Take the user to the main page also
      Navigator.pushNamedAndRemoveUntil(context, MainPage.id, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 70.0,
                ),
                Image(
                  alignment: Alignment.center,
                  height: 100.0,
                  width: 100.0,
                  image: AssetImage('images/logo.png'),
                ),
                SizedBox(
                  height: 40.0,
                ),
                Text(
                  'Create a Rider\'s Account',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontFamily: 'Brand-Bold'),
                ),
                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: fullNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: TextStyle(fontSize: 14.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ), //Full Name
                      SizedBox(
                        height: 10.0,
                      ),

                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            labelText: 'Email Address',
                            labelStyle: TextStyle(fontSize: 14.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ), //Email
                      SizedBox(
                        height: 10.0,
                      ),

                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                            labelText: 'Mobile number',
                            labelStyle: TextStyle(fontSize: 14.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ), //Phone number
                      SizedBox(
                        height: 10.0,
                      ),

                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: TextStyle(fontSize: 14.0),
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 10.0,
                            )),
                        style: TextStyle(fontSize: 14.0),
                      ),
                      SizedBox(
                        height: 40.0,
                      ),

                      TaxiButton(
                        title: 'REGISTER',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          // Check for network availabilty
                          var connectivityResult =
                              await Connectivity().checkConnectivity();
                          if (connectivityResult != ConnectivityResult.mobile &&
                              connectivityResult != ConnectivityResult.wifi)
                            print('NET ON KAR!!');
                          registerUser();
                        },
                      ),
                    ],
                  ),
                ),
                FlatButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                          context, LoginPage.id, (route) => false);
                    },
                    child: Text('Already have a Rider Account? Login'))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
