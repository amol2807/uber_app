import 'package:flutter/material.dart';
import 'package:uber_app/brand_colors.dart';

class ProgressDialogue extends StatelessWidget {
  final String status;

  ProgressDialogue({this.status});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 5.0,
              ),
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(BrandColors.colorAccent),
              ),
              SizedBox(
                width: 25.0,
              ),
              Text(
                status,
                style: TextStyle(
                  fontSize: 15.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
